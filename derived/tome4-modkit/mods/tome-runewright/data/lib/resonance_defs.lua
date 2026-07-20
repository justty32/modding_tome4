-- 共鳴定義表 —— 只放資料，不放 actor 邏輯。
-- 套用是 mod/class/Actor.lua 的 runewrightApplyResonanceEffects() 用 addTemporaryValue 處理。
--
-- 屬性語意（全部在 modules/tome/mod/class/Actor.lua 複驗過）：
--   shield_factor  百分比   護盾吸收量：amount * (100 + x) / 100   （Actor.lua:8420）
--   healing_factor 分數     治療量倍率加成
--   inc_damage     表       {all = n} → 造成的傷害 +n%
--   resists        表       {all = n} → 抗性 +n%
--   movement_speed 分數     移動速度
--   stun_immune    分數     0~1，1 = 完全免疫
--   pin_immune     分數     同上
--   mana_regen     數值     每回合法力回復
--   combat_spellpower 數值  法術強度
--   inscriptions_stat_multiplier 分數  銘文屬性加成放大（ActorInscriptions.lua:143-144）

local M = {}

M.defs = {
    {
        id = "surge",
        name = "泉湧共鳴",
        -- 盧恩術士的起手銘文就是原版預設的「法力風暴符文 + 回覆紋身」，
        -- 所以這個共鳴第一回合就會亮起。這是刻意的：共鳴是本職業的招牌機制，
        -- 不該讓玩家玩了十層才第一次看到它運作。
        desc = "法力風暴符文 + 回覆紋身：法力回復 +0.5，法術強度 +5。",
        matches = function(counts, list)
            return M.hasId(list, "MANASURGE") and M.hasId(list, "REGENERATION")
        end,
        effects = {
            mana_regen = 0.5,
            combat_spellpower = 5,
        },
    },
    {
        id = "bulwark",
        name = "壁壘共鳴",
        desc = "護盾符文 + 治療或回覆紋身：護盾吸收量 +25%，受到的治療 +15%。",
        matches = function(counts, list)
            return M.hasId(list, "SHIELDING")
                and (M.hasId(list, "HEALING") or M.hasId(list, "REGENERATION"))
        end,
        effects = {
            shield_factor = 25,
            healing_factor = 0.15,
        },
    },
    {
        id = "fleeting",
        name = "迅影共鳴",
        desc = "傳送符文 + 迅捷紋身：移動速度 +20%，暈眩與定身抗性 +30%。",
        matches = function(counts, list)
            return M.hasId(list, "TELEPORTATION") and M.hasId(list, "MOVEMENT")
        end,
        effects = {
            movement_speed = 0.20,
            stun_immune = 0.30,
            pin_immune = 0.30,
        },
    },
    {
        id = "triune",
        name = "三相共鳴",
        desc = "身上有 3 個以上的符文：造成的傷害 +10%，銘文屬性加成 +15%。",
        matches = function(counts, list)
            return (counts.runes or 0) >= 3
        end,
        effects = {
            inc_damage = { all = 10 },
            inscriptions_stat_multiplier = 0.15,
        },
    },
}

--- 銘文清單裡有沒有 short_name 含 needle 的（大小寫不敏感、與語系無關）
function M.hasId(list, needle)
    needle = needle:upper()
    for _, ins in ipairs(list) do
        if ins.id and ins.id:upper():find(needle, 1, true) then return true end
    end
    return false
end

return M
