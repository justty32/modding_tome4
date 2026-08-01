## 12. 輸入系統

### 12.1 KeyCommand (`engine/KeyCommand.lua`)

底層按鍵處理：
- `key:addCommands{...}` 直接綁定 SDL keysym → callback。
- `key:setCurrent()` 讓此 handler 成為當前接收者。

### 12.2 KeyBind (`engine/KeyBind.lua`)

虛擬動作系統（在 KeyCommand 之上）：

```lua
-- 定義虛擬動作（在 /data/keybinds/move.lua）
defineAction{
    type = "MOVE_LEFT",
    name = "Move Left",
    default = { {"left"}, {"numpad4"} },
}

-- 綁定動作 → callback
key:bindToCommand("MOVE_LEFT", function() player:moveDir(4) end)
```

- 玩家可在設定介面重新映射（`dialogs/KeyBinder.lua`）。
- 重映射存入 `/settings/keybinds2.cfg`。

---

## 13. 任務系統 (`engine/Quest.lua`)

```lua
-- 定義任務
local quest = Quest.new({
    name = "Kill the Dragon",
    desc = "...",
    on_grant = function(self, who) ... end,
    on_status_change = function(self, who, status, sub) ... end,
}, player)

-- 更新子目標
quest:setSubCompleted("find_lair")
quest:setCompleted()  -- 完成整個任務
```

**狀態機**：
- `PENDING (0)` → `COMPLETED (1)` → `DONE (100)`
- `PENDING (0)` → `FAILED (101)`

Hook 整合：`triggerHook{"Quest:init"}`, `triggerHook{"Quest:completed"}` 讓模組監聽任務事件。

---

## 14. 玩家自動化功能

### 14.1 PlayerRest (`engine/interface/PlayerRest.lua`)

```lua
player:restInit(turns, "resting", "rested", on_end_callback)
```

每回合呼叫 `:restCheck()` 判斷是否應停止（受傷、敵人出現、HP/MP 滿等），子類別覆寫此方法。

### 14.2 PlayerExplore (`engine/interface/PlayerExplore.lua`)

Flood-fill 自動探索：
1. 以 BFS/Dijkstra 找出所有可達、但未探索的格子。
2. 對最近的未探索目標走 A*。
3. 若有物品/出口在視野內，優先前往撿取。
4. 每步行動後重新計算（處理門、新視野）。

### 14.3 PlayerRun (`engine/interface/PlayerRun.lua`)

直線快速移動：沿指定方向連續移動，遇到岔路口、敵人、物品停止。

---

## 15. 渲染相關系統

### 15.1 Tiles (`engine/Tiles.lua`)

- 維護圖磚材質 repo（`self.repo`），已載入的圖像以路徑為 key 快取。
- `loadTileset(file)`：載入圖磚集定義（大圖切片），批量定義多個圖磚。
- 支援 addon 路徑（`addonname+gfx/image.png` → `/data-addonname/gfx/image.png`）。

### 15.2 Shader (`engine/Shader.lua`)

```lua
local shader = Shader.new("fire_effect", {require_kind="distort"})
-- 找 /data/gfx/shaders/fire_effect.vert + .frag
```

- **延遲載入**：`delay_load = true` 時，第一次存取 `shader.shad` 才實際編譯。
- **LRU 清理**：`cleanup()` 定期刪除長時間未用的 temp shader。
- `core.shader.allow(kind)` 檢查使用者設定（`shaders_kind_distort` 等）。

### 15.3 Particles (`engine/Particles.lua`)

```lua
local p = Particles.new("flame", radius=1, {size=2, density=50})
actor:addParticles(p)
```

- 粒子定義在 `/data/gfx/particles/*.lua`，描述粒子行為、壽命、顏色曲線。
- C 層維護粒子物理計算（`src/particles.c`）。
- `__particles_gl` 弱引用 table 防止 GC 前仍被渲染。

### 15.4 FlyingText (`engine/FlyingText.lua`)

飄字特效（傷害數字、獲得 XP 等）：
- 建立一個短暫的文字動畫，從指定位置浮起並淡出。

---

## 16. 在線與 Profile 系統

### 16.1 PlayerProfile (`engine/PlayerProfile.lua`)

```lua
profile = PlayerProfile.new()
profile:start()   -- 啟動後台 profile thread
```

- 在獨立 thread 處理與 te4.org 的通訊（防止主執行緒阻塞）。
- 功能：登入、排行榜提交、成就同步、角色 vault 上傳、在線聊天。

### 16.2 UserChat (`engine/UserChat.lua`)

全域頻道聊天，使用 LuaSocket 連接 te4.org 伺服器。

### 16.3 MicroTxn (`engine/MicroTxn.lua`)

Steam DLC 微交易整合，透過 `core.steam` API。

---

## 17. 在地化系統 (`engine/I18N.lua`)

```lua
local I18N = require "engine.I18N"
I18N:loadLocale("/data/locales/engine/zh.lua")
I18N:setLocale("zh")

-- 使用
_t"Hello World"   -- 翻譯字串
_t("Hello %s", name)  -- 帶參數
```

- 翻譯資料以 Lua table 形式儲存（`{["Hello World"] = "你好世界"}`）。
- 技能名稱、效果描述等在 `newTalent/newEffect` 時自動呼叫 `_t()`。

---

## 18. 關鍵設計模式總結

| 模式 | 應用 |
|------|------|
| **Mixin 繼承** | `engine/interface/` 所有介面，Actor 按需組合 |
| **Data-driven 定義** | `newTalent`, `newEffect`, `newDamageType` — 資料與邏輯在同一個定義 table |
| **兩階段初始化** | Entity define（原型）→ resolve（實例），支援延遲亂數計算 |
| **命名行為** | AI 系統以字串 key 組合行為，可在執行時動態切換 |
| **弱引用追蹤** | `__uids`, `entities`, `ai_target`，讓 GC 自然清理已死亡實體 |
| **每物件存一檔** | 存檔用 zip 內多 Lua 檔，跨物件引用用 hash 連結，天然支援 graph 結構 |
| **Hook 系統** | 模組可在不修改引擎的情況下，在任何 hook 點注入邏輯 |
| **延遲載入** | Shader、部分存檔物件，首次使用時才真正初始化 |
