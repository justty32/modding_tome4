-- 失落挖掘者的遺物——四件手工神器。
--
-- 這個檔不會被 loadDefinition，而是在 hooks/load.lua 由 Entity:loadList hook 追加進
-- 原版 world-artifacts.lua 的同一個 res 清單。所以這裡的 newEntity 用法與原版一字不差。
--
-- 每件都給了 rarity + level_range，才會進入隨機生成池（engine/Zone.lua:223 兩者缺一不可）。
-- unique=true 是布林，引擎在 resolve 時會把它替換成 self.name（engine/Entity.lua:784-785），
-- 之後以「類別名/名字」為 key 去重（:809）——所以每件的 name 必須各自唯一。

local Talents = require "engine.interface.ActorTalents"
local DamageType = require "engine.DamageType"

-- 1) 拓文之燈 ── 示範 use_power 自訂主動技（who:magicMap）＋ wielder。
-- use_power 的 use 回傳 {id=true, used=true} 表示消耗成功（world-artifacts.lua:376-386 前例）。
newEntity{
    base = "BASE_LITE", define_as = "RELIC_RUBBING_LANTERN",
    power_source = { arcane = true },
    unique = true,
    name = "拓文之燈", unided_name = "沾墨的舊提燈",
    level_range = { 8, 20 }, rarity = 200,
    require = { },
    cost = 300,
    material_level = 2,
    desc = [[挖掘隊用它拓印遺跡牆上的銘文。燈芯燃的不是油，而是某種會隨光散開、
把周遭地形「顯影」到記憶裡的物質。舉燈一照，連暗處的輪廓都浮了出來。]],
    wielder = {
        lite = 3,
        see_invisible = 8,
        infravision = 5,
        max_encumber = 30,
    },
    max_power = 30, power_regen = 1,
    use_power = {
        name = function(self, who) return "拓印周遭地形（半徑 20 揭圖）" end,
        power = 30,
        no_npc_use = function(self, who) return not game.party:hasMember(who) end,
        use = function(self, who)
            who:magicMap(20)
            game.logSeen(who, "%s 舉起拓文之燈，四周的地形在腦中顯影開來。", who:getName():capitalize())
            return { id = true, used = true }
        end,
    },
}

-- 2 & 3) 挖掘者的行頭（套裝）── 示範 set_list / on_set_complete / on_set_broken。
-- 偵測發生在 Actor:onWear（Actor.lua:4549-4626），只掃「已穿戴槽位」，放背包不算數。
-- on_set_complete 裡 self 是物件本身，self:specialSetAdd 加的是破套會自動移除的暫時值
-- （Actor.lua:4761-4777；Garkul 前例 world-artifacts.lua:352-355）。
newEntity{
    base = "BASE_HELM", define_as = "RELIC_EXCAVATOR_GOGGLES",
    power_source = { technique = true },
    unique = true,
    name = "挖掘者的護目鏡", unided_name = "刮花的黃銅護目鏡",
    level_range = { 6, 18 }, rarity = 220,
    cost = 200,
    material_level = 2,
    desc = [[鏡片被磨石與沙塵刮得斑駁，卻仍看得比誰都清。單戴著只是副好眼鏡；
若能配上同一副行頭的手套，據說能在最深的坑道裡看見不該被看見的東西。]],
    wielder = {
        combat_armor = 4,
        see_invisible = 6,
        see_stealth = 6,
        infravision = 4,
    },
    set_list = { {"define_as", "RELIC_EXCAVATOR_GLOVES"} },
    set_desc = {
        excavator = "配上挖掘者的手套，這副行頭才算完整。",
    },
    on_set_complete = function(self, who)
        self:specialSetAdd({"wielder","esp"}, { all = 1 })
        self:specialSetAdd({"wielder","esp_range"}, 10)
        self:specialSetAdd({"wielder","max_encumber"}, 40)
        game.logSeen(who, "#LIGHT_BLUE#你戴齊了挖掘者的行頭，坑道深處的一切彷彿都在感知之內。")
    end,
    on_set_broken = function(self, who)
        game.logPlayer(who, "#LIGHT_BLUE#挖掘者的行頭散了，那份洞察也隨之消退。")
    end,
}

newEntity{
    base = "BASE_GLOVES", define_as = "RELIC_EXCAVATOR_GLOVES",
    power_source = { technique = true },
    unique = true,
    name = "挖掘者的手套", unided_name = "磨破的皮手套",
    level_range = { 6, 18 }, rarity = 220,
    cost = 200,
    material_level = 2,
    desc = [[掌心磨出了厚繭，指節縫著加固的皮革。長年握著鏟與鑿，讓戴著它的人
既卸得下陷阱的機關，也扛得動一整袋出土的重物。]],
    wielder = {
        combat_armor = 2,
        disarm_bonus = 8,
        max_encumber = 30,
        inc_stats = { [require("engine.interface.ActorStats").STAT_CUN] = 3 },
    },
    set_list = { {"define_as", "RELIC_EXCAVATOR_GOGGLES"} },
    set_desc = {
        excavator = "配上挖掘者的護目鏡，這副行頭才算完整。",
    },
    on_set_complete = function(self, who)
        self:specialSetAdd({"wielder","combat_physcrit"}, 5)
        game.logSeen(who, "#LIGHT_BLUE#手套與護目鏡相互呼應，你的手更穩了。")
    end,
    on_set_broken = function(self, who)
    end,
}

-- 4) 銘紀之鎬 ── 示範「可成長物品」（special_on_kill 走 onTakeoff→改欄位→onWear，
-- Corpathus 前例 world-artifacts.lua:3411-3420）＋ talent_on_hit。
-- combat/wielder 的改動會隨物件序列化保存；wielder 是穿戴時一次性 addTemporaryValue，
-- 所以改完必須脫下重穿才生效（Actor.lua:4633-4638）。
newEntity{
    base = "BASE_BATTLEAXE", define_as = "RELIC_CHRONICLE_PICK",
    power_source = { technique = true },
    unique = true,
    name = "銘紀之鎬", unided_name = "刻滿凹痕的重鎬",
    level_range = { 10, 25 }, rarity = 250,
    require = { stat = { str = 28 }, level = 12 },
    cost = 350,
    material_level = 3,
    desc = [[鎬柄上密密麻麻全是刻痕，起初以為是計數，後來才明白每一道都對應一次「收尾」。
它會記錄用它了結的每一個對手，愈是浴血，鋒芒愈利——彷彿在為某部無人讀過的編年史增補。]],
    combat = {
        dam = 34,
        apr = 8,
        physcrit = 3,
        dammod = { str = 1.1 },
        talent_on_hit = { [Talents.T_SUNDER_ARMOUR] = { level = 3, chance = 12 } },
    },
    wielder = {
        combat_dam = 6,
        max_encumber = 20,
    },
    relic_kills = 0,   -- 自訂欄位，隨物件保存；記錄成長次數。
    special_on_kill = { desc = "每次擊殺後永久增強", fct = function(combat, who, target)
        local o, item, inven_id = who:findInAllInventoriesBy("define_as", "RELIC_CHRONICLE_PICK")
        if not o or not inven_id or not who:getInven(inven_id).worn then return end
        if (o.relic_kills or 0) >= 20 then return end   -- 封頂 20 次，避免無限成長。
        who:onTakeoff(o, inven_id, true)
        o.relic_kills = (o.relic_kills or 0) + 1
        o.combat.dam = (o.combat.dam or 0) + 1
        o.combat.physcrit = (o.combat.physcrit or 0) + 0.5
        who:onWear(o, inven_id, true)
        if o.relic_kills % 5 == 0 then
            game.logSeen(who, "#YELLOW#銘紀之鎬又添了一道刻痕，鋒芒更盛了。（已記錄 %d 次）", o.relic_kills)
        end
    end },
}
