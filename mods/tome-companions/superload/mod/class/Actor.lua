-- 契約夥伴免疫「主人」造成的傷害。
--
-- 基礎遊戲沒有「同隊/同陣營免傷」的全域開關（faction 只管 AI 敵友判定；AOE 預設
-- 仍會打到友軍，除非各技能自己設 friendlyfire=false）。所以「免傷」只能在傷害入口攔。
-- 這裡疊加 onTakeHit，仿原版 invulnerable_others（mod/class/Actor.lua:2418-2420）的寫法：
-- 若受擊者是契約夥伴（有 co_owner）、且傷害來自主人本人或主人的召喚物，直接歸零。
-- 敵人造成的傷害不受影響，夥伴仍會正常受敵傷。

local _M = loadPrevious(...)

local base_onTakeHit = _M.onTakeHit
function _M:onTakeHit(value, src, death_note)
    if value and value > 0 and src and self.co_owner then
        local owner = self.co_owner
        if src == owner or (src.summoner and src.summoner == owner) then
            return 0
        end
    end
    return base_onTakeHit(self, value, src, death_note)
end

-- 給 hooks/load.lua 的 selfcheck 用：確認這個 superload 真的疊上去了。
_M.__companions_immunity = true

return _M
