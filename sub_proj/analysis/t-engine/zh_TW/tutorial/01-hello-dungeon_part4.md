## 11. Actor 基礎類別

`Actor` 是所有可動實體（玩家、NPC）的基底：

```lua
-- game/modules/hellodungeon/class/Actor.lua

require "engine.class"
require "engine.Actor"
require "engine.interface.ActorTemporaryEffects"
require "engine.interface.ActorLife"
require "engine.interface.ActorProject"
require "engine.interface.ActorLevel"
require "engine.interface.ActorStats"
require "engine.interface.ActorTalents"
require "engine.interface.ActorResource"
require "engine.interface.ActorFOV"
require "mod.class.interface.Combat"     -- 自訂戰鬥介面

local Map = require "engine.Map"

-- 繼承引擎 Actor + 所有介面混入
module(..., package.seeall, class.inherit(
    engine.Actor,
    engine.interface.ActorTemporaryEffects,
    engine.interface.ActorLife,
    engine.interface.ActorProject,
    engine.interface.ActorLevel,
    engine.interface.ActorStats,
    engine.interface.ActorTalents,
    engine.interface.ActorResource,
    engine.interface.ActorFOV,
    mod.class.interface.Combat
))

function _M:init(t, no_default)
    self.combat_armor = 0
    t.power_regen = t.power_regen or 1
    t.life_regen = t.life_regen or 0.25
    self.combat = { dam = 1 }

    -- 依序呼叫所有繼承介面的 init
    engine.Actor.init(self, t, no_default)
    engine.interface.ActorTemporaryEffects.init(self, t)
    engine.interface.ActorLife.init(self, t)
    engine.interface.ActorProject.init(self, t)
    engine.interface.ActorTalents.init(self, t)
    engine.interface.ActorResource.init(self, t)
    engine.interface.ActorStats.init(self, t)
    engine.interface.ActorLevel.init(self, t)
    engine.interface.ActorFOV.init(self, t)
end

-- 每「回合」呼叫一次（能量足夠時）
function _M:act()
    if not engine.Actor.act(self) then return end

    self.changed = true

    -- 每回合：冷卻 → 資源回復 → 持續效果
    self:cooldownTalents()
    self:regenLife()
    self:regenResources()
    self:timedEffects()

    if self.energy.value < game.energy_to_act then return false end
    return true
end

-- 移動（帶能量消耗）
function _M:move(x, y, force)
    local moved = false
    local ox, oy = self.x, self.y
    if force or self:enoughEnergy() then
        moved = engine.Actor.move(self, x, y, force)
        if not force and moved and (self.x ~= ox or self.y ~= oy)
                and not self.did_energy then
            self:useEnergy()
        end
    end
    self.did_energy = nil
    return moved
end

-- 滑鼠 Tooltip
function _M:tooltip()
    return ([[%s%s
#00ffff#等級: %d
#ff0000#HP: %d (%d%%)
屬性: STR%d / DEX%d / CON%d]]):format(
        self:getDisplayString(), self.name,
        self.level,
        self.life, self.life * 100 / self.max_life,
        self:getStr(), self:getDex(), self:getCon()
    )
end

-- 受傷時呼叫（可加防禦計算）
function _M:onTakeHit(value, src)
    return value  -- 回傳實際傷害
end

-- 死亡
function _M:die(src)
    engine.interface.ActorLife.die(self, src)
    if src and src.gainExp then
        src:gainExp(self:worthExp(src))
    end
    return true
end

-- 升級
function _M:levelup()
    self.max_life = self.max_life + 2
    self:incMaxPower(3)
    self.life = self.max_life
    self.power = self.max_power
end

-- 屬性變化時
function _M:onStatChange(stat, v)
    if stat == self.STAT_CON then
        self.max_life = self.max_life + 2
    end
end

-- 碰撞攻擊
function _M:attack(target)
    self:bumpInto(target)
end

-- 技能使用前檢查（能量、資源）
function _M:preUseTalent(ab, silent)
    if not self:enoughEnergy() then return false end

    if ab.mode == "sustained" then
        if ab.sustain_power and self.max_power < ab.sustain_power
                and not self:isTalentActive(ab.id) then
            game.logPlayer(self, "沒有足夠能量啟動 %s。", ab.name)
            return false
        end
    else
        if ab.power and self:getPower() < ab.power then
            game.logPlayer(self, "沒有足夠能量使用 %s。", ab.name)
            return false
        end
    end

    if not silent then
        if ab.mode == "sustained" and not self:isTalentActive(ab.id) then
            game.logSeen(self, "%s 啟動了 %s。", self.name:capitalize(), ab.name)
        elseif ab.mode == "sustained" and self:isTalentActive(ab.id) then
            game.logSeen(self, "%s 停用了 %s。", self.name:capitalize(), ab.name)
        else
            game.logSeen(self, "%s 使用了 %s。", self.name:capitalize(), ab.name)
        end
    end
    return true
end

-- 技能使用後處理（消耗資源、冷卻）
function _M:postUseTalent(ab, ret)
    if not ret then return end
    self:useEnergy()

    if ab.mode == "sustained" then
        if not self:isTalentActive(ab.id) then
            if ab.sustain_power then self.max_power -= ab.sustain_power end
        else
            if ab.sustain_power then self.max_power += ab.sustain_power end
        end
    else
        if ab.power then self:incPower(-ab.power) end
    end
    return true
end

-- 能看見目標嗎？（處理隱身）
function _M:canSee(actor, def, def_pct)
    if not actor then return false, 0 end

    if actor:attr("stealth") and actor ~= self then
        local hit, chance = self:checkHit(
            self.level / 2 + self:getCun(25),
            actor:attr("stealth") + (actor:attr("inc_stealth") or 0),
            0, 100)
        if not hit then return false, chance end
    end

    if def ~= nil then return def, def_pct
    else return true, 100 end
end

-- 能否被施加特定效果？
function _M:canBe(what)
    if what == "poison"    and rng.percent(100 * (self:attr("poison_immune") or 0))
        then return false end
    if what == "confusion" and rng.percent(100 * (self:attr("confusion_immune") or 0))
        then return false end
    if what == "blind"     and rng.percent(100 * (self:attr("blind_immune") or 0))
        then return false end
    if what == "stun"      and rng.percent(100 * (self:attr("stun_immune") or 0))
        then return false end
    return true
end

-- 經驗值計算
function _M:worthExp(target)
    if not target.level or self.level < target.level - 3 then return 0 end
    local mult = 2
    if self.unique then mult = 6
    elseif self.egoed then mult = 3 end
    return self.level * mult * self.exp_worth
end
```
