-- 定義「符文充能」資源。
--
-- 呼叫時機必須在任何 actor 被建立之前：engine/interface/ActorResource.lua:127-130
-- 的 init() 會依 resources_def 把 min_/max_ 欄位寫進 actor。我們在 ToME:load hook
-- 裡 dofile 本檔，那時模組已載入完但還沒到創角，時機正確。
--
-- 存取器命名規則（engine/interface/ActorResource.lua:68-73）：
--   "inc" .. short_name:lower():capitalize()   →  incRunecharge
--   "get" .. short_name:lower():capitalize()   →  getRunecharge
-- 所以 short_name 必須是單一個字（"rune_charge" 會生成醜陋的 getRune_charge）。

local ActorResource = require "engine.interface.ActorResource"
local ActorTalents = require "engine.interface.ActorTalents"

ActorResource:defineResource(
    "Rune Charge",              -- name
    "runecharge",               -- short_name → self.runecharge / getRunecharge / incRunecharge
    ActorTalents.T_RUNE_CHARGE_POOL, -- talent：沒學會這個天賦，getter 一律回 0
    "runecharge_regen",         -- regen_prop：每回合加到本體（我們刻意留 0，見下）
    "符文充能代表你銘刻於自身的盧恩之力。觸發任何銘文都會累積充能。它不會自然回復——不使用銘文，就沒有充能。",
    0,                          -- min
    10,                         -- max（由 spell/runic-mastery 的被動提高）
    {
        color = "#B9A05B#",
        wait_on_rest = false,   -- 不會自然回復，休息等它是無意義的
    }
)
