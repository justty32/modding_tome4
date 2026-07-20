---

## 步驟六：讓遊戲從大地圖開始

### 修改 `mod/class/Game.lua`

預設情況下，TE4 模組可能從地牢或其他 Zone 開始。要讓玩家**出生在大地圖的起點村莊旁**，修改 `newGame()`：

```lua
-- mod/class/Game.lua

function _M:newGame()
    -- 建立玩家角色（保留原有的 newGame 邏輯）
    self.player = self:createPlayer()
    self.player:resolve()

    -- 初始化 party
    self.party = require("mod.class.Party").new{}
    self.party:addMember(self.player, {
        control = "player",
        type    = "player",
        title   = "英雄",
    })

    -- 初始化據點狀態（Tutorial 10/11）
    self.camp_state = {
        buildings = {farm=false, chest=false, upgraded_fire=false},
        farms     = {},
        workers   = {},
    }

    -- ★ 起始於大地圖（wilderness Zone 的第 1 層）
    -- 玩家出現在 wilderness.lua 中設定的 startx, starty 位置
    self:changeLevel(1, "wilderness")
end
```

> **為什麼不在 `load()` 中設定？**  
> `newGame()` 只在「新遊戲」時呼叫一次；`load()` 在讀取存檔時呼叫。`changeLevel` 只需要在 `newGame()` 執行，存檔記錄了玩家當時所在的 Zone/Level，讀檔後自動恢復。

---

## 步驟七：完整 Zone 連結圖

```
wilderness（大地圖）
│
├─ TOWN_A_ENTRANCE（A）  ──>  town_a Zone (lev 1)
│                                  └─ TOWN_EXIT <  ──> wilderness
│
├─ TOWN_B_ENTRANCE（B）  ──>  town_b Zone (lev 1)
│                                  └─ TOWN_EXIT <  ──> wilderness
│
├─ CAMP_ENTRANCE（C）    ──>  camp Zone (lev 1)      [Tutorial 10]
│                                  └─ EXIT_TO_WORLD < ──> wilderness
│
├─ DUNGEON_FOREST（D）   ──>  dungeon_forest Zone
│                                  ├─ lev 1  >─────> lev 2
│                                  ├─ lev 2  >─────> lev 3
│                                  ├─ lev 3（Boss）
│                                  └─ lev 1  <（from lev 1）──> wilderness
│
└─ DUNGEON_FORTRESS（F） ──>  dungeon_fortress Zone
                                   └─ ...（同上結構）
```
