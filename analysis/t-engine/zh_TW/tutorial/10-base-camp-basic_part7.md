## 步驟六：從大地圖進入據點

### 大地圖上的「據點入口」地形

在大地圖（Wilderness）的地形列表中加入一個特殊地形，玩家站上後按 `>` 即可進入：

```lua
-- mod/data/grids/wilderness.lua（在現有檔案中追加）
newEntity{
    define_as = "CAMP_ENTRANCE",
    name = "野外據點入口",
    display = 'C', color_r=0, color_g=255, color_b=150,
    back_color = colors.DARK_GREY,
    notice          = true,
    always_remember = true,

    -- 按下 CHANGE_LEVEL 鍵（預設 >）時：切換到 "camp" Zone 的第 1 層
    change_level = 1,
    change_zone  = "camp",
}
```

在大地圖靜態地圖中用字元 `C` 放置這個格子即可。

### Zone 進入後的玩家位置

`changeLevel` 結束後，玩家的初始位置由 Level 的 `default_up` / `default_down` 決定。Static 地圖產生器會自動把 `startx`/`starty` 設定為 `level.default_up`：

```lua
-- Static 產生器內部邏輯（引擎已實作）
level.default_up   = {x = startx, y = starty}
level.default_down = {x = startx, y = starty}
```

因此在 `camp.lua` 中設定 `startx = 12, starty = 17`（出口附近），進入據點時玩家就會出現在那裡。

---

## 步驟七：切換流程整合

### `Game.lua` 不需要修改

`change_zone` + `change_level` 欄位的觸發由原本的 `CHANGE_LEVEL` 鍵處理（引擎預設行為）：

```lua
-- 引擎 Game:setupCommands() 的 CHANGE_LEVEL 按鍵（原始邏輯示意）
CHANGE_LEVEL = function()
    local e = self.level.map(self.player.x, self.player.y, Map.TERRAIN)
    if self.player:enoughEnergy() and e and e.change_level then
        self:changeLevel(
            e.change_zone and e.change_level
                          or self.level.level + e.change_level,
            e.change_zone
        )
    end
end,
```

**進入 camp 的完整流程：**

```
玩家站在 CAMP_ENTRANCE（change_level=1, change_zone="camp"）按 >
→ game:changeLevel(1, "camp")
→ 若 camp Zone 不存在 → 建立新 Zone，Static 產生器生成地圖
→ 若 camp Zone 已存在（.teaz 檔）→ 從磁碟載入
→ zone:getLevel(1)：優先從 memory_levels[1] 取出
→ 玩家出現在 startx=12, starty=17
```

**離開 camp 的完整流程：**

```
玩家站在 EXIT_TO_WORLD（change_level=1, change_zone="wilderness"）按 >
→ game:changeLevel(1, "wilderness")
→ camp Zone：leaveLevel() 把 Level 物件存入 memory_levels[1]
→ Zone:save() 把整個 Zone（含 memory_levels）寫入 .teaz 磁碟檔
→ wilderness Zone 載入
```
