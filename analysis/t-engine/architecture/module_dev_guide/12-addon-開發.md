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
