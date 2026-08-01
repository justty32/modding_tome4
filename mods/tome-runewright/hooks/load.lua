-- addon 的 data/ 掛在私有的 /data-runewright/（engine/Module.lua:498-503），
-- 不會合併進 /data，也不會被自動掃描。所有定義都必須在這裡手動載入。
-- hook 執行時機晚於所有 addon 的 superload/overload 掛載（engine/Module.lua:684-701），
-- 且模組自己的 birth 定義已在 mod/load.lua:239 載入完畢，
-- 所以此時 getBirthDescriptor("class", "Mage") 一定拿得到。

-- 這些**必須**在這裡 require。它們在 modules/tome/mod/load.lua:60-70 是 `local`，
-- 不是全域；hook 函式的閉包看不到它們。當成全域用會得到
-- 「attempt to index global 'ActorTalents' (a nil value)」。
-- 實證：arcanum/hooks/load.lua:1-8、nullpack/hooks/load.lua:19-22 都這樣寫。
local class = require "engine.class"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local ActorResource = require "engine.interface.ActorResource"
local Birther = require "engine.Birther"

class:bindHook("ToME:load", function(self, data)
    -- 1) 共鳴判定庫（純函數）。superload 的 Actor 透過 _G.__runewright_resonance 取用。
    _G.__runewright_resonance = dofile("/data-runewright/lib/resonance.lua")

    -- 2) 池天賦必須先於資源定義——resources.lua 會參照 ActorTalents.T_RUNE_CHARGE_POOL。
    ActorTalents:loadDefinition("/data-runewright/talents/misc/pool.lua")

    -- 3) 資源。必須在任何 actor 被建立前定義好
    --    （engine/interface/ActorResource.lua:127-130 的 init 依 resources_def 寫 min_/max_ 欄位）。
    dofile("/data-runewright/resources.lua")

    -- 4) 持續效果，要先於引用它的天賦。
    ActorTemporaryEffects:loadDefinition("/data-runewright/timed_effects.lua")

    -- 5) 技能樹。核心三棵 + 古弗薩克文三族（ættir）。
    ActorTalents:loadDefinition("/data-runewright/talents/spells/runecraft.lua")
    ActorTalents:loadDefinition("/data-runewright/talents/spells/runic-mastery.lua")
    ActorTalents:loadDefinition("/data-runewright/talents/spells/inscription-lore.lua")
    ActorTalents:loadDefinition("/data-runewright/talents/spells/futhark-freyr.lua")
    ActorTalents:loadDefinition("/data-runewright/talents/spells/futhark-heimdall.lua")
    ActorTalents:loadDefinition("/data-runewright/talents/spells/futhark-tyr.lua")

    -- 6) 職業。必須最後——它的 talents 表要參照上面已定義的天賦 id。
    Birther:loadDefinition("/data-runewright/birth/classes/mage.lua")

    -- 7) 自我檢查：把可驗證的證據印到 stdout。
    -- 無頭測試（tools/verify.sh）靠 grep 這些行來判定 addon 真的生效，
    -- 而不是靠判讀畫面。任一項失敗就印 FAIL，讓 verify 抓得到。
    -- 六棵技能樹的每一棵，都抽一個天賦驗證它真的註冊進去了
    local tree_probe = {
        ActorTalents.T_RW_ENGRAVE_RUNE,   -- spell/runecraft
        ActorTalents.T_RW_RUNIC_MASTERY,  -- spell/runic-mastery
        ActorTalents.T_RW_INSCRIPTION_LORE, -- spell/inscription-lore
        ActorTalents.T_RW_FEHU,           -- spell/futhark-freyr
        ActorTalents.T_RW_HAGALAZ,        -- spell/futhark-heimdall
        ActorTalents.T_RW_OTHALA,         -- spell/futhark-tyr
    }
    local trees_ok = true
    for _, tid in ipairs(tree_probe) do
        if not (tid and ActorTalents.talents_def[tid]) then trees_ok = false end
    end

    -- 共鳴：四個定義，且每個都要有宣告式的 effects（沒有 effects 的共鳴不會有任何作用）
    local res = _G.__runewright_resonance
    local resonance_ok = type(res) == "table" and #res.defs == 4
    if resonance_ok then
        for _, d in ipairs(res.defs) do
            if type(d.effects) ~= "table" or next(d.effects) == nil then resonance_ok = false end
        end
    end

    -- 符文盤：檔案在（overload 掛載成功）、require 得到、天賦註冊了、純函數層有 diff。
    -- pcall require 是因為 overload 沒掛上時 require 會直接拋錯，那樣 verify 只會看到
    -- 一個 Lua Error 而不知道是哪裡的問題。
    local board_ok = pcall(require, "mod.dialogs.RunewrightRuneBoard")
        and ActorTalents.talents_def[ActorTalents.T_RW_RUNEBOARD] ~= nil
        and type(_G.__runewright_resonance.diff) == "function"
        and type(_G.__runewright_resonance.withReplacement) == "function"

    local checks = {
        { "resource",  ActorResource.resources_def.runecharge ~= nil },
        { "pool",      ActorTalents.talents_def[ActorTalents.T_RUNE_CHARGE_POOL] ~= nil },
        { "runeboard", board_ok },
        { "trees",     trees_ok },
        { "effects",   ActorTemporaryEffects.tempeffect_def.EFF_RW_INHERITANCE ~= nil },
        { "resonance", resonance_ok },
        { "subclass",  Birther:getBirthDescriptor("subclass", "Runewright") ~= nil },
        { "allowed",   Birther:getBirthDescriptor("class", "Mage")
            .descriptor_choices.subclass.Runewright == "allow" },
    }
    for _, c in ipairs(checks) do
        print(("[RUNEWRIGHT] selfcheck %s = %s"):format(c[1], c[2] and "OK" or "FAIL"))
    end
    print("[RUNEWRIGHT] hook complete")
end)

--- 符文盤的備援入口：Escape 選單。
--
-- 主入口是天賦（建角就會，見 data/birth/classes/mage.lua）。這裡多開一條路，
-- 是因為天賦要佔一個快捷鍵格，而玩家可能把它從快捷鍵拿掉之後就找不到面板了。
--
-- mod/class/Game.lua:2459 的 triggerHook 傳來 {menu=l, unregister=fn}。
-- unregister 是引擎現場建的閉包（指向那個還沒建立的 GameMenu），
-- 所以要先呼叫它把選單關掉，再開自己的 dialog。
-- 第三方前例：zomnibus/hooks/hooks-savefile-note.lua:86-101、select-your-escorts。
class:bindHook("Game:alterGameMenu", function(self, data)
    local p = game.player
    -- 只有盧恩術士（身上有符文充能池）才看得到這一項
    if not p or not p.knowTalent or not p:knowTalent(p.T_RUNE_CHARGE_POOL) then return end
    table.insert(data.menu, 1, { "符文盤", function()
        data.unregister()
        game:registerDialog(require("mod.dialogs.RunewrightRuneBoard").new(p))
    end })
end)
