# 引擎事實：addon 怎麼被載入

> 路徑代號 `E` / `M` / `R` 見 [README.md](README.md)。

## 0. 最重要的一件事：addon 的 `data/` 不會被自動掃描

```lua
-- E/Module.lua:498-503
if add.data then
    fs.mount(base.."/data", "/data-"..add.short_name, true)   -- ← 私有掛載點
end
```

掛的是 `/data-<short_name>/`，**不是**合併進 `/data/`。所以放在 `data/birth/classes/mage.lua` 的職業定義，遊戲根本不會去讀。

必須在 `hooks/load.lua` 用 `ToME:load` hook 手動載入（`R/arcanum/hooks/load.lua:47-54` 實證）：

```lua
class:bindHook("ToME:load", function(self, data)
    DamageType:loadDefinition("/data-arcanum/damage_types.lua")
    ActorTalents:loadDefinition("/data-arcanum/talents/spells/spells.lua")
    Birther:loadDefinition("/data-arcanum/birth/classes/mage.lua")
    ActorTemporaryEffects:loadDefinition("/data-arcanum/timed_effects.lua")
end)
```

hook 執行時機在**所有** addon 的 superload/overload 掛載完之後（`E/Module.lua:684-701`）。
模組自己的 birth 定義在 `M/mod/load.lua:239` 先載入，`:267` 才 `triggerHook{"ToME:load"}`——所以 hook 裡一定看得到 `Mage` 等既有 class。

**唯一例外**：locale 檔會自動載入（`E/Module.lua:505-508`），`data/locales/<locale>.lua` 不需手動呼叫。

### ⚠️⚠️ `/data-<short_name>/` **不在 `package.path` 上——`require` 一定失敗**

`E/Module.lua:498-503` 只做 `fs.mount(..., "/data-"..short_name, true)`，
**沒有任何一處把它加進 `package.path`**（`grep -rn package.path E/` 零命中，2026-08-01 複驗）。
`package.path` 只有 `/?.lua`，所以：

```lua
require("data.lib.mylib")     -- ✗ 去找「模組自己的」/data/lib/mylib.lua → not found
```

addon 自己 `data/` 底下的東西**只能用絕對 VFS 路徑**取：

| 要載什麼 | 用什麼 |
|---|---|
| 純資料／純函式模組 | `dofile("/data-<addon>/lib/x.lua")` |
| 天賦定義檔串接 | `load("/data-<addon>/talents/.../x.lua")` |

`load` 是 `loadDefinition` 注入到 env 裡的那個（`E/interface/ActorTalents.lua:40`），
**必須沿用同一份 env 才拿得到 `newTalent`**；原版 `M/data/talents.lua:300-311` 就是這個寫法。

`overload/` 底下的檔案**一樣適用**：`overload/mod/dialogs/X.lua` 掛到 `/mod/dialogs/`，
但它要讀 addon 自己的 `data/` 時仍然只能 `dofile` 絕對路徑。

**這個 bug 特別陰**，兩種症狀都不好認：

- 失敗點被 `pcall` 包住 → 只有某個 selfcheck 印 FAIL，**沒有 Lua Error**。
- 沒包 `pcall` → **在 hook 中途炸掉，之後所有 `loadDefinition` 都不執行**，整個職業靜默消失。

`lint.sh` **抓不到**（語法完全正確），只有 `verify.sh` 抓得到。
2026-08-01 在 `tome-runewright` 實際踩到：`resonance.lua:20` 的 `require` 讓 hook 第 19 行就爆，
技能樹／共鳴／符文盤／Birther 條目**全部沒註冊**。

### ⚠️ 把單一天賦檔拆成目錄後，要同步改 `hooks/load.lua`

`loadDefinition` **不認目錄、不會自動找 `init.lua`**——`E/interface/ActorTalents.lua:42`
直接 `util.loadfilemods(file, env)` → `loadfile`。

`futhark-freyr.lua` 拆成 `futhark-freyr/init.lua` 之後，`load.lua` 還指著已不存在的單檔，
結果同上：hook 炸在半路。**重構天賦檔時務必回頭改 hook。**

### ⚠️ `ActorTalents` / `Birther` 這些**不是全域**

在 `M/mod/load.lua:60-70`，它們是 `local`。hook 函式的閉包看不到，
當全域用會得到 `attempt to index global 'ActorTalents' (a nil value)`。
**必須在 hook 檔頂端自己 require**（`R/arcanum/hooks/load.lua:1-8`、`R/nullpack/hooks/load.lua:19-22`）：

```lua
local class = require "engine.class"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local ActorResource = require "engine.interface.ActorResource"
local Birther = require "engine.Birther"
local DamageType = require "engine.DamageType"
```

`tools/lua/check_init.lua` 會擋下這個錯。

## 1. `init.lua` 欄位

| 欄位 | 必要性 | 語意與行號 |
|---|---|---|
| `long_name` | 必填 | 顯示名 |
| `short_name` | 必填 | 決定掛載點 `/data-<short_name>/` 與 `addons.cfg` 的 key |
| `for_module` | 必填 | 必須等於宿主模組 short_name（`E/Module.lua:390`） |
| `version` | 必填 | 見下方相容性規則 |
| `addon_version` | 必填 | 只用於顯示（`E/Module.lua:396-400`） |
| `description` | 必填 | — |
| **`weight`** | **必填** | `E/Module.lua:437` 直接 `a.weight < b.weight`。**nil 會讓整個 addon 清單的 `table.sort` 拋錯，拖垮使用者所有 addon** |
| `data` | 選 | 掛 `data/` → `/data-<short_name>/`（`:498-503`） |
| `hooks` | 選 | 掛 `hooks/` → `/hooks/<short_name>/`（`:526-533`） |
| `superload` | 選 | 疊加既有 class 檔，可 `loadPrevious()`（`:510-518`） |
| `overload` | 選 | **整檔取代**，直接掛到 VFS 根（`:519-524`） |
| `requires_addons` | 選 | 遞迴剔除到不動點；A/B 互相依賴會被一起剔除且只印 missing（`:652-675`） |
| `cheat_only` | 選 | 需 `config.settings.cheat`（`:574`） |
| `tags`, `author`, `homepage` | 選 | 顯示用 |

## 2. 資料夾名

必須是 `<for_module>-<short_name>`，即 `tome-runewright`。
`E/Module.lua:409` 用 `short_name:find("^"..mod.short_name.."%-")` 篩選；不符**靜默忽略**，無錯誤訊息。

## 3. 版本相容性（最常見的鬼打牆）

```lua
-- E/version.lua:90-97   engine.version_nearly_same(v = 模組版本, ev = addon 版本)
if v[1] == ev[1] then
    if v[2] == ev[2] and v[3] >= ev[3] then return true
    elseif v[2] >= ev[2] then return true end
end
return false
```

對模組 `{1,7,6}`：addon 主版號須為 `1`，次版號 ≤ `7`，若次版號 `== 7` 則修訂號 ≤ `6`。
`{1,7,7}` 或 `{1,8,0}` → `natural_compatible = false`（`E/Module.lua:390`）→ 在 `:595` 被 `table.remove`，
**全程沒有任何錯誤訊息，addon 就是不見了**。

## 4. 預設啟用

未列在 `addons.cfg` 的 addon 走 `E/Module.lua:583` 的 else 分支，只檢查 `natural_compatible`。
換言之**佈署完就啟用**，不需要手動開。

## 坑清單

1. **`data/` 是私有掛載點**，birth/talents 要手動 `loadDefinition`（見 §0）。檔案在、東西卻不存在。
2. **`weight` 漏填會拖垮所有 addon**（`E/Module.lua:437` 的 `table.sort` 對 nil 比較）。
3. **版本不相容 → 靜默移除**，沒有任何訊息（`E/Module.lua:390, 595`）。
4. **資料夾名前綴不符 → 靜默忽略**（`E/Module.lua:409`）。
5. **hook 檔裡 `ActorTalents` / `Birther` 不是全域**，要自己 require，否則 runtime nil index。
6. `requires_addons` 循環依賴會被一起剔除，只印 missing，容易誤判成缺檔（`E/Module.lua:652-675`）。
7. **`require("data.…")` 取自己 addon 的檔一定失敗**——私有掛載點不在 `package.path`（見 §0）。
   用 `dofile("/data-<addon>/…")` 或 `load(...)`。`lint.sh` 抓不到，只有 `verify.sh` 抓得到。
8. **天賦檔拆成目錄後忘了改 `hooks/load.lua` 的路徑** → hook 炸在半路，整個職業消失（見 §0）。

> 以上第 1–5 條全部由 `tools/lua/check_init.lua` 自動擋下。
