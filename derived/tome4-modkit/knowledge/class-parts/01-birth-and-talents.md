# 引擎事實：職業、天賦、資源、i18n

> 路徑代號 `E` / `M` / `R` 見 [README.md](README.md)。
> addon 怎麼被載入見 [addon-loading.md](addon-loading.md)——**所有定義都要手動 `loadDefinition`**。

## 1. `newBirthDescriptor`

`E/Birther.lua:64-80`。`assert` 三個必填：`name`、`type`、`desc`。

- `short_name` 未填時由 `name` 大寫底線化生成。
- `display_name` 預設 `_t(t.name, "birth descriptor name")`。
- **同名同 type 會靜默覆蓋**（`:76-79`），與 `newTalent` 撞名 assert 崩潰的行為不一致。

### 新增子職業到既有 class

`type="class"` 的描述子用 `descriptor_choices.subclass` 白名單控制可選項。
addon 直接改那張全域表即可（`R/arcanum/data/birth/classes/mage.lua:324-326`）：

```lua
newBirthDescriptor{ type = "subclass", name = "Arcanist", desc = {...}, ... }
getBirthDescriptor("class", "Mage").descriptor_choices.subclass.Arcanist = "allow"
```

`getBirthDescriptor` 只是讀寫全域表（`E/Birther.lua:86-89`），沒有任何重掃機制。

### `type="subclass"` 的欄位如何被套用

`Birther:apply()` 於 `E/Birther.lua:370-446`：

| 欄位 | 行號 | 作用 |
|---|---|---|
| `copy` | `:377-386` | 陣列部分逐個 `table.insert` 進 actor，其餘 `table.merge` |
| `stats` | `:398-402, :440` | 呼叫 `incStat` |
| `talents_types` | `:408-421` | `{已知?, mastery}` → `learnTalentType` |
| `talents` | `:422-429` | → `learnTalent` |
| `experience` | `:430` | 設 `actor.exp_mod` 倍率 |

`copy` 的**陣列部分是 append 不是覆蓋**（`:379-383` 的 `while #copy > 0 do table.insert(self.actor, ...)`）。
所以 class 與 subclass 各自的 `resolvers.*` 不會互相蓋掉——它們會全部被保留下來執行。

**`power_source` 在 `Birther:apply()` 完全沒被讀取**。唯一有實證的自動複製路徑是多重職業流程（`M/mod/class/Actor.lua:3592`）。單一主職業要自己塞進 `copy = { power_source = {...} }`。

`unlockable_talents_types` **不是引擎欄位**，是 ToME 模組層自訂（`M/mod/class/Actor.lua:3616-3627`、`M/mod/dialogs/Birther.lua:260-261`）。

`descriptor_choices` 的值，裸引擎只認 4 種（`E/Birther.lua:236-243`）；ToME superload 過的 Birther 另支援 `"nolore"`、`"allow-nochange"`（`M/mod/dialogs/Birther.lua:760-789`）。

## 2. `newTalentType` / `newTalent`

`E/interface/ActorTalents.lua:49-98`。

- `newTalentType`：必填 `name`、`type`（`:51-52`）。**同 type 重覆定義靜默覆蓋**（`:59-60`）。
- `newTalent`：必填 `name`、`type`、`info`（`:67,68,76`）。`mode` 只接受 `activated`/`sustained`/`passive`（`:73,75`）。
  `id` 由 `"T_"..short_name` 生成，**撞名直接 assert 崩潰**（`:92`）。

其後被讀取的欄位：

| 欄位 | 讀取處 |
|---|---|
| `require`（`.stat`/`.level`/`.special`/`.talent`/`.birth_descriptors`） | `canLearnTalent`，`:742-793` |
| `learn_lists` / `on_learn` / `passives` / `no_auto_hotkey` | `learnTalent`，`:562-625` |
| `action` / `activate` / `deactivate` / `onAIGetTarget` | `useTalent`，`:141-200` |

**ToME 模組層額外讀取、但不在引擎介面裡的欄位**（教學常漏）：
`is_spell`（`M/mod/class/Actor.lua:732, 5138, 5767, 5886`）、
`no_energy`（`:5800, 5875, 5889`，經 `util.getval` 取值 → **可以是函式**）、
`hide`、`no_unlearn_last`。

### 一律明確指定 `short_name`

不指定的話會由 `name` 大寫底線化生成——中文天賦名會產生非 ASCII 的天賦 id。
建議加專屬前綴（如 `RW_`）避免與其他 addon 撞名（撞名是 assert 崩潰）。

### 動態的被動效果不能寫在 `passives`

`passives` 只在 `learnTalent` 時計算一次（`E/interface/ActorTalents.lua:562-625`）。
效果會隨遊戲狀態浮動的被動（例如「每個啟動中的 X 給 +N」），要用**回呼**：

```lua
callbackOnActBase = function(self, t) ... end   -- 每回合，M/mod/class/Actor.lua:646 fireTalentCheck
```

回呼名稱總表在 `M/mod/class/Actor.lua:6050-6060`（`callbackOnActBase` / `callbackOnHit` /
`callbackOnTeleport` / `callbackOnMove` / …）。只有學會該天賦的 actor 才會觸發。

在回呼裡重算時，記得先 `removeTemporaryValue` 舊值再 `addTemporaryValue` 新值，
並在集合沒變時提早返回，否則每回合都在重建 temporary value。

## 3. 沒有 hook 時：superload

ToME 只在少數地方 `triggerHook`。`M/mod/class/Actor.lua` 裡 `Actor:*` 系列的 hook 只有
`preUseTalent`（`:5946`）——**沒有 `postUseTalent`**。要攔截它只能 superload：

```lua
local _M = loadPrevious(...)
local base = _M.postUseTalent
function _M:postUseTalent(ab, ret, silent)
    local r = base(self, ab, ret, silent)
    -- 你的邏輯
    return r
end
return _M
```

**動手前先 grep 確認你要掛的函式真的有人呼叫。**
反例：`M/mod/class/interface/ActorInscriptions.lua:149` 的 `usedInscription()` 看起來就是
「銘文被使用」的掛點，但 **全庫沒有任何呼叫者**，是死代碼。
真正能識別銘文的是天賦上的 `is_inscription` 旗標（`M/data/talents/misc/inscriptions.lua:60`）。
