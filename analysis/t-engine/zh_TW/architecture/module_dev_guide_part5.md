## 8. 實體定義模式

### 8.1 基礎定義

```lua
newEntity{
    define_as = "FLOOR",           -- 全域唯一 ID，用於 zone.lua 映射
    name = "floor",
    image = "terrain/marble_floor.png",
    display = '.',                 -- ASCII 字元表示
    color_r = 255, color_g = 255, color_b = 255,
    back_color = colors.DARK_GREY,
}
```

### 8.2 繼承（base）

```lua
-- 定義基底模板
newEntity{
    define_as = "BASE_NPC_KOBOLD",
    type = "humanoid", subtype = "kobold",
    display = "k",
    ai = "dumb_talented_simple",
    ai_state = { talent_in = 3 },
    stats = { str = 5, dex = 5, con = 5 },
}

-- 繼承基底，只覆寫差異
newEntity{ base = "BASE_NPC_KOBOLD",
    name = "kobold warrior",
    color = colors.GREEN,
    level_range = {1, 4},
    exp_worth = 1,
    rarity = 4,                    -- 生成稀有度（越大越少見）
    max_life = resolvers.rngavg(5, 9),
    combat = { dam = 2 },
}
```

### 8.3 Resolver 使用

```lua
newEntity{ base = "BASE_NPC_KOBOLD",
    name = "kobold chief",
    max_life = resolvers.rngavg(20, 30),       -- 隨機生命值
    combat = { dam = resolvers.rngrange(3, 6) }, -- 隨機攻擊力
    resolvers.equip{                              -- 隨機裝備
        {type = "weapon", subtype = "longsword"},
    },
    resolvers.talents{                            -- 學習技能
        [ActorTalents.T_KICK] = 1,
    },
    resolvers.drops{                              -- 死亡掉落
        chance = 50,
        nb = 1,
        {type = "potion"},
    },
}
```

---

## 9. 粒子特效 (`data/gfx/particles/*.lua`)

```lua
-- data/gfx/particles/acid.lua
return {
    base = 1000,                   -- 最大粒子數
    angle    = { 0, 360 },        -- 初始角度範圍
    anglev   = { 2000, 4000 },    -- 角速度
    anglea   = { 200, 600 },      -- 角加速度
    life     = { 5, 10 },         -- 粒子壽命（frame）
    size     = { 3, 6 },          -- 粒子大小
    sizev    = { 0, 0 },
    r = {0, 0}, rv = {0, 0}, ra = {0, 0},       -- 紅色通道
    g = {80, 200}, gv = {0, 10}, ga = {0, 0},   -- 綠色通道
    b = {0, 0}, bv = {0, 0}, ba = {0, 0},       -- 藍色通道
    a = {255, 255}, av = {0, 0}, aa = {0, 0},   -- 透明度
}, function(self)
    -- 發射控制函數（每幀呼叫）
    self.nb = (self.nb or 0) + 1
    if self.nb < 4 then
        self.ps:emit(100)  -- 發射 100 個粒子
    end
end
```

使用方式：`actor:addParticles(engine.Particles.new("acid", 1))`

---

## 10. 對話框

```lua
-- dialogs/DeathDialog.lua
require "engine.class"
require "engine.ui.Dialog"
local List = require "engine.ui.List"

module(..., package.seeall, class.inherit(engine.ui.Dialog))

function _M:init(actor)
    self.actor = actor
    engine.ui.Dialog.init(self, "Death!", 400, 200)

    local list = List.new{
        width = 350,
        list = {
            {name = "Resurrect", action = "resurrect"},
            {name = "Exit to menu", action = "exit"},
        },
        fct = function(item)
            if item.action == "resurrect" then
                self:resurrect()
            elseif item.action == "exit" then
                util.showMainMenu()
            end
        end,
    }

    self:loadUI{ {left = 3, top = 3, ui = list} }
    self:setupUI(true, true)
end

function _M:resurrect()
    self.actor.life = self.actor.max_life
    game:unregisterDialog(self)
end
```

---

## 11. 在地化 (`data/locales/`)

```lua
-- data/locales/ja_JP.lua
locale "ja_JP"

-- 指定來源檔案（用於管理翻譯完整性）
section "mod-example/class/Actor.lua"
t("You do not have enough power to activate %s.",
  "　%sを起動するリソースがない。",
  "logPlayer")

section "mod-example/data/damage_types.lua"
t("physical", "物理")
t("fire", "火焰")
```

啟用：在 `load.lua` 中呼叫 `I18N:loadLocale("/data/locales/ja_JP.lua")`，之後 `_t"physical"` 自動回傳翻譯。

---

## 12. Addon 開發

Addon 以 `.teaa` 壓縮包發佈，放入 `game/addons/` 目錄。

### 12.1 Addon 結構

```
my-addon.teaa (zip)
└── my-addon/
    ├── init.lua               # Addon 元資料
    ├── superload/             # 覆蓋/擴充模組檔案
    │   └── mod/
    │       └── class/
    │           └── Actor.lua  # 攔截並修改 Actor 類別
    ├── hooks/                 # Hook 註冊
    ├── data/                  # Addon 專用資料
    └── overload/              # 資源覆蓋（圖片、音效…）
```

### 12.2 Superload 機制

引擎在 `game/loader/init.lua` 註冊了自訂 `package.loaders`。當模組 `require "mod.class.Actor"` 時：

1. 先載入原始 `/mod/class/Actor.lua`
2. 依 `__addons_superload_order` 順序，檢查每個 addon 是否有 `/mod/addons/<addon>/superload/mod/class/Actor.lua`
3. 若有，執行 superload 檔案，傳入原始模組結果
4. Superload 函數可呼叫 `loadPrevious()` 取得原始模組

```lua
-- superload/mod/class/Actor.lua
local _M = loadPrevious(...)  -- 取得原始 Actor 類別

-- 保存原方法
local old_init = _M.init

-- 覆寫方法
function _M:init(t, no_default)
    old_init(self, t, no_default)
    -- 加入 addon 專用邏輯
    self.my_addon_data = {}
end

return _M
```

### 12.3 Hook 機制

Addon 可透過 hook 系統注入邏輯，而不需覆寫整個方法：

```lua
-- hooks/my_hooks.lua
class:bindHook("Actor:act", function(self, data)
    -- 在每個 Actor 行動時觸發
    if self:hasEffect(self.EFF_MY_CUSTOM_EFFECT) then
        -- 做某些事
    end
end)
```

引擎/模組端使用 `self:triggerHook{"Actor:act", ...}` 觸發所有已註冊的 hook handler。

---

## 13. 虛擬檔案系統路徑對照

| 虛擬路徑 | 實體來源 |
|----------|---------|
| `/engine/` | `game/engines/te4-1.7.6.teae` 解壓 |
| `/mod/` | `game/modules/<模組名>/` 或 `.team` 解壓 |
| `/mod/addons/<name>/` | `game/addons/<name>.teaa` 解壓 |
| `/data/` | 當前模組的 `data/` 子目錄 |
| `/save/` | 使用者存檔目錄 |
| `/settings/` | 使用者設定目錄 |

所有路徑透過 PhysFS 統一存取，不區分磁碟檔案或 zip 壓縮包。

---

## 14. 從範例模組開始

最快的開發方式：

1. 複製 `game/modules/example/` 為 `game/modules/mymod/`
2. 修改 `init.lua` 中的 `name`、`short_name`、`version`
3. 修改 `class/interface/Combat.lua` 自訂戰鬥公式
4. 在 `data/` 下新增自訂的傷害類型、技能、效果
5. 在 `data/zones/` 下設計新的區域
6. 在 `data/general/npcs/` 下定義新的怪物
7. 修改 `data/birth/descriptors.lua` 設計職業系統
8. 執行引擎，在模組選單中選擇你的模組

即時制模組只需在 `load.lua` 中加入 `core.game.setRealtime(20)`，其餘結構完全相同。
