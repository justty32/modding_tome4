-- addon 的 data/ 掛在私有的 /data-witch/（engine/Module.lua:498-503），
-- 不會合併進 /data，也不會被自動掃描。所有定義都必須在這裡手動載入。
-- hook 執行時機晚於所有 addon 的 superload/overload 掛載（engine/Module.lua:684-701），
-- 且模組自己的 birth 定義已在 mod/load.lua:239 載入完畢，
-- 所以此時 getBirthDescriptor("world", "Maj'Eyal") 一定拿得到。

-- 這些**必須**在這裡 require。它們在 modules/tome/mod/load.lua:60-70 是 `local`，
-- 不是全域；hook 函式的閉包看不到它們。當成全域用會得到
-- 「attempt to index global 'ActorTalents' (a nil value)」。
-- 實證：arcanum/hooks/load.lua:1-8、nullpack/hooks/load.lua:19-22 都這樣寫。
local class = require "engine.class"
local ActorTalents = require "engine.interface.ActorTalents"
local Birther = require "engine.Birther"

class:bindHook("ToME:load", function(self, data)
    -- 1) 技能樹。必須先於職業——birth 的 talents 表要參照已定義的天賦 id。
    ActorTalents:loadDefinition("/data-witch/talents/spell/herbalism.lua")

    -- 2) 職業。這是**全新 class**（type="class"），不是掛進既有 class 的子職業；
    --    世界白名單（Maj'Eyal/Infinite/Arena 的 class 白名單）在 birth 檔內處理。
    Birther:loadDefinition("/data-witch/birth/classes/witch.lua")

    -- 3) 自我檢查：把可驗證的證據印到 stdout。
    -- 無頭測試（tools/verify.sh）靠 grep 這些行來判定 addon 真的生效，
    -- 而不是靠判讀畫面。任一項失敗就印 FAIL，讓 verify 抓得到。
    local witch_talents = {
        ActorTalents.T_WITCH_HERB_LORE,
        ActorTalents.T_WITCH_BREW,
        ActorTalents.T_WITCH_LIFE_DRAUGHT,
        ActorTalents.T_WITCH_MASTER_HERBALIST,
    }
    local tree_ok = true
    for _, tid in ipairs(witch_talents) do
        if not (tid and ActorTalents.talents_def[tid]) then tree_ok = false end
    end

    local world_ok = true
    for _, world in ipairs { "Maj'Eyal", "Infinite", "Arena" } do
        local w = Birther:getBirthDescriptor("world", world)
        if not w or w.descriptor_choices.class.Witch ~= "allow" then world_ok = false end
    end

    local checks = {
        { "tree",     tree_ok },
        { "class",    Birther:getBirthDescriptor("class", "Witch") ~= nil },
        { "subclass", Birther:getBirthDescriptor("subclass", "Witch") ~= nil },
        { "worlds",   world_ok },
    }
    for _, c in ipairs(checks) do
        print(("[WITCH] selfcheck %s = %s"):format(c[1], c[2] and "OK" or "FAIL"))
    end
    print("[WITCH] hook complete")
end)
