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

---
