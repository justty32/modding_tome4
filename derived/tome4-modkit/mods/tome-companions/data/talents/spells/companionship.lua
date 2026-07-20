-- 契約召募天賦。由 hooks/load.lua 在 ToME:load loadDefinition，並在 ToME:birthDone 教給玩家。
--
-- short_name 明確指定，避免中文名產生非 ASCII 的天賦 id
-- （engine/interface/ActorTalents.lua 由 name 大寫底線化生成 id）。

newTalentType{
    type = "spell/companionship",
    name = "契約",
    description = "與生靈締結契約，收之為伴。",
    generic = true,
    allow_random = false,
}

newTalent{
    name = "契約召募",
    short_name = "CO_RECRUIT",
    type = { "spell/companionship", 1 },
    points = 1,
    mode = "activated",
    no_energy = true,       -- 不耗行動；不設 mana/is_spell，任何職業（含無法力的狂戰士）都能用。
    cooldown = 15,
    range = 10,
    no_npc_use = true,
    image = "talents/arcane_power.png",  -- 借用確定存在的既有圖示，避免顯示 ?

    -- 判定一個 entity 能否被招募：是視線內、非傳奇、rank 不高於精英、尚未入隊的生物。
    canRecruit = function(self, act)
        return act and act ~= self and act.x and act.faction and act.die and not act.dead
            and not act.unique and (act.rank or 1) <= 3
            and not (game.party and game.party:hasMember(act))
    end,

    -- 招募核心：轉陣營、入隊、拉等級、標記免傷。抽成函式方便 console 直接測。
    doRecruit = function(self, t, target)
        target:setTarget(nil)
        target.faction = self.faction
        target.never_anger = true
        if not (game.party and game.party:hasMember(target)) then
            game.party:addMember(target, {
                control = "full", type = "companion", title = "契約夥伴",
                orders = { target = true, leash = true, anchor = true, talents = true, behavior = true },
            })
        end
        -- addMember 可能 replaceWith(PartyMember.new(target))，但保留同一 table identity、欄位合併，
        -- 所以這些標記放在 addMember 之後設，確保不被覆蓋。
        target.co_owner = self               -- superload 的 onTakeHit 靠這個判定「免疫主人傷害」
        target.summoner = self
        target.summoner_gain_exp = false
        -- 野生 NPC 帶自己的等級上限（max_level，例如 25），會擋住「隨主人成長」。
        -- 清掉它，契約夥伴才能跟著你一路升上去（實測：不清就卡在原上限）。
        target.max_level = nil
        target:forceLevelup(math.max(target.level or 1, self.level))
        local nm = (target.getName and target:getName() or target.name or "生物")
        game.logSeen(target, "#LIGHT_GREEN#%s 與你締結契約，成為你的夥伴！", tostring(nm):capitalize())
        return true
    end,

    action = function(self, t)
        local best, bestd
        for _, act in pairs(game.level.entities) do
            if t.canRecruit(self, act) and self:hasLOS(act.x, act.y) then
                local d = core.fov.distance(self.x, self.y, act.x, act.y)
                if d <= self:getTalentRange(t) and (not bestd or d < bestd) then best, bestd = act, d end
            end
        end
        if not best then
            game.logPlayer(self, "#LIGHT_RED#附近沒有可招募的對象（需視線內、非傳奇、rank 不高於精英的生物）。")
            return
        end
        return t.doRecruit(self, t, best)
    end,

    -- 主人升級時，帶動所有契約夥伴一起升到同級（培養＝隨你成長）。
    callbackOnLevelup = function(self, t, new_level)
        if not (game.party and game.party.m_list) then return end
        for _, act in ipairs(game.party.m_list) do
            if act ~= self and act.co_owner == self and not act.dead and act.forceLevelup then
                act:forceLevelup(new_level)
            end
        end
    end,

    info = function(self, t)
        return ([[對準視線內最近的一個非傳奇生物，將其收為契約夥伴：
- 招募：加入你的隊伍、可切換操控，且不會因誤傷而反目。
- 培養：立即提升至你的等級，並隨你日後每次升級一同成長。
- 免傷：契約夥伴免疫你造成的一切傷害（含你的範圍法術），但仍會被敵人攻擊。
招募範圍：%d 格。]]):format(self:getTalentRange(t))
    end,
}
