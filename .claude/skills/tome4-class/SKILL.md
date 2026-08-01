---
name: tome4-class
description: 為 Tales of Maj'Eyal (ToME 4) 新增一個可選職業（subclass）——技能樹、天賦、自訂資源、Birther 整合。當使用者要做 ToME4 新職業、新技能樹、或自訂資源池時使用。
---

# ToME4 新職業

先讀 `tome4-addon` skill 的鐵律。工作區 `~/repo/moddings/tome4/`。
權威細節（含行號）在 `knowledge/class-and-talents.md` 與 `knowledge/addon-loading.md`——**動手前讀它們**。
加特效與音效前另讀 `knowledge/visuals-and-sounds.md`。

## 檔案骨架

```
mods/tome-<name>/
├── init.lua                          # data/hooks/superload 旗標；weight 必填
├── hooks/load.lua                    # ToME:load → 手動 loadDefinition 全部定義
├── data/
│   ├── birth/classes/mage.lua        # newBirthDescriptor + 加進母 class 白名單
│   ├── talents/misc/pool.lua         # 資源池天賦（若有自訂資源）
│   ├── talents/spells/*.lua          # newTalentType + newTalent
│   ├── timed_effects.lua             # newEffect
│   ├── resources.lua                 # defineResource（若有自訂資源）
│   └── locales/zh_hant.lua           # 自動載入，不必手動 loadDefinition
└── superload/mod/class/Actor.lua     # 只有要攔截既有行為時才需要
```

## `hooks/load.lua` 的載入順序（會互相依賴，順序錯就爆）

```lua
local class = require "engine.class"
class:bindHook("ToME:load", function(self, data)
    ActorTalents:loadDefinition("/data-<name>/talents/misc/pool.lua")   -- 1. 池天賦
    dofile("/data-<name>/resources.lua")                               -- 2. 資源（引用池天賦 id）
    ActorTemporaryEffects:loadDefinition("/data-<name>/timed_effects.lua") -- 3. 效果
    ActorTalents:loadDefinition("/data-<name>/talents/spells/foo.lua")  -- 4. 技能（引用效果）
    Birther:loadDefinition("/data-<name>/birth/classes/mage.lua")       -- 5. 職業（引用技能 id）
end)
```

## 掛進既有 class

`Mage` 的子職業白名單預設 `__ALL__ = "disallow"`，必須明確 allow：

```lua
newBirthDescriptor{ type = "subclass", name = "Runewright", desc = {...}, ... }
getBirthDescriptor("class", "Mage").descriptor_choices.subclass.Runewright = "allow"
```

`getBirthDescriptor` 只是讀寫全域表，沒有重掃機制。

## 必須知道的七件事

1. **天賦一律明確指定 `short_name`。** 不指定的話會由 `name` 大寫底線化生成——中文職業名會產生非 ASCII 的天賦 id。天賦 id 撞名會 **assert 崩潰**（`engine/interface/ActorTalents.lua:92`）。建議加專屬前綴（如 `RW_`）。
2. **職業的 `name` 必須 ASCII**（`short_name` 由它生成），中文走 locale，tag 是 `"birth descriptor name"`。
   天賦與技能樹的 `name` 可以直接寫中文（只要明確指定 `short_name`），代價是無法再被翻成其他語系。
   走 locale 的話 tag 要對：天賦名 `"talent name"`、技能樹名 `"talent type"`。tag 錯了翻譯靜默失效。
3. **自訂資源的 `short_name` 必須是單一個字。** 存取器由 `short_name:lower():capitalize()` 生成，`"rune_charge"` 會變成醜陋的 `getRune_charge`。用 `"runecharge"` → `getRunecharge`/`incRunecharge`。
4. **資源的 getter 在沒學會池天賦時恆回 0**（`engine/interface/ActorResource.lua:87-94`）。子職業的 `talents` 表必須包含 `[ActorTalents.T_<POOL>] = 1`。
5. **`power_source` 在 `Birther:apply()` 沒有被讀取**（`engine/Birther.lua:370-446`）。單一主職業要自己塞進 `copy = { power_source = {...} }`。
6. **遊戲邏輯不准比對 `t.name`**——它被 `_t()` 翻譯過。一律比對 `t.short_name`。
7. **動態的被動效果不能寫在 `passives`**（只算一次），要用 `callbackOnActBase` 之類的回呼。

## 沒有 hook 可用時

ToME 只在少數地方 `triggerHook`。要攔截 `postUseTalent` 之類的東西，只能 superload：

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

**動手前先 grep 確認你要掛的函式真的有人呼叫。** 例如 `ActorInscriptions:usedInscription()`
（`mod/class/interface/ActorInscriptions.lua:149`）看起來很像掛點，但全庫**沒有任何呼叫者**，是死代碼。

## 收工

```bash
tools/lint.sh <name> && tools/deploy.sh <name> && tools/verify.sh <name>
```

**verify 綠燈只證明載入成功，不證明遊戲邏輯是對的。** 職業與技能一定觸及遊戲邏輯，
所以還要 `tools/playtest.sh start <name>` 實際建角、施放，並貼出截圖或 log 佐證。

新學到的引擎行為，**附行號**補進 `knowledge/` 對應的那份。
需要人眼確認的（手感、平衡）記進 `WAIT_USER.md`。
