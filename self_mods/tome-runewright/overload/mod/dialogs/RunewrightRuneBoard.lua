-- 符文盤 —— 資料收集委託 data.lib.rune_board_data；判定全走 resonance.lua 純函數。

require "engine.class"
local Dialog, ListColumns = require "engine.ui.Dialog", require "engine.ui.ListColumns"
local TextzoneList, Textzone = require "engine.ui.TextzoneList", require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"
-- ⚠️ 同 data/lib/resonance.lua 的理由：addon 的 data/ 在 /data-runewright/，
-- require 只認 package.path 的 /?.lua，搆不到私有掛載點。只能絕對路徑 dofile。
local Data = dofile("/data-runewright/lib/rune_board_data.lua")

module(..., package.seeall, class.inherit(Dialog))

function _M:init(actor)
	self.actor, self.lib = actor, _G.__runewright_resonance
	Dialog.init(self, "符文盤", math.floor(game.w * 0.8), math.floor(game.h * 0.8))
	self:gather()
	self:buildUI()
	self.key:addBinds{ EXIT = function() game:unregisterDialog(self) end }
end

function _M:gather()
	self.slots, self.current, self.candidates, self.active = Data.gather(self.actor, self.lib)
	self.list = {}
	for _, s in ipairs(self.slots) do
		self.list[#self.list + 1] = { row = "slot", slot = s,
			where = ("槽 %d"):format(s.slot),
			nametxt = s.empty and "（空）" or s.name,
			hint = s.empty and "-" or self:slotHint(s), }
	end
	for _, c in ipairs(self.candidates) do
		self.list[#self.list + 1] = { row = "cand", cand = c,
			where = "背包", nametxt = c.name, hint = self:candHint(c), }
	end
end

function _M:buildUI()
	self.c_status = Textzone.new{ width = self.iw, height = 1, auto_height = true, text = self:statusText() }
	local sh = (self.c_status.h or 60) + 10
	local vsep = Separator.new{ dir = "horizontal", size = self.ih - sh }
	self.c_desc = TextzoneList.new{ width = math.floor(self.iw / 2 - 10), height = self.ih - sh, scrollbar = true }
	self.c_list = ListColumns.new{
		width = math.floor(self.iw / 2 - vsep.w / 2), height = self.ih - sh, scrollbar = true,
		columns = {
			{ name = "位置", width = 20, display_prop = "where" },
			{ name = "銘文", width = 52, display_prop = "nametxt" },
			{ name = "共鳴", width = 28, display_prop = "hint" },
		},
		list = self.list, fct = function(item) end,
		select = function(item, sel) self:select(item) end,
	}
	self:loadUI{
		{ left = 0, top = 0, ui = self.c_status },
		{ left = 0, top = self.c_status, ui = self.c_list },
		{ right = 0, top = self.c_status, ui = self.c_desc },
		{ hcenter = 0, top = self.c_status, ui = vsep },
	}
	self:setFocus(self.c_list)
	self:setupUI()
	self:select(self.list[1])
end

--------------------------------------------------------------------------- 計算

function _M:slotHint(s)
	local without = {}
	for _, v in ipairs(self.current) do
		if v.id ~= s.id then without[#without + 1] = v end
	end
	local _, lost = self.lib.diff(self.current, without)
	return #lost == 0 and "-" or ("支撐 %d 個"):format(#lost)
end

function _M:candHint(c)
	local best
	for _, opt in ipairs(self:candOptions(c)) do
		local net = #opt.gained - #opt.lost
		if not best or net > best then best = net end
	end
	return (not best or best <= 0) and "-" or ("+%d"):format(best)
end

function _M:candOptions(c)
	local opts = {}
	for _, s in ipairs(self.slots) do
		if s.empty then
			local after = self.lib.withReplacement(self.current, nil, c)
			local gained, lost = self.lib.diff(self.current, after)
			opts[#opts + 1] = { slot = s.slot, empty = true, gained = gained, lost = lost }
		else
			local idx
			for i, v in ipairs(self.current) do if v.id == s.id then idx = i break end end
			local after = self.lib.withReplacement(self.current, idx, c)
			local gained, lost = self.lib.diff(self.current, after)
			opts[#opts + 1] = { slot = s.slot, replaces = s.name, gained = gained, lost = lost }
		end
	end
	return opts
end

--------------------------------------------------------------------------- 顯示

local function names(defs)
	local t = {}
	for _, d in ipairs(defs) do t[#t + 1] = d.name end
	return table.concat(t, "、")
end

function _M:statusText()
	local out = {}
	if not self.actor:knowTalent(self.actor.T_RW_RESONANT_MIND) then
		out[#out + 1] = "#LIGHT_RED#尚未學會「共鳴之心」——下面的共鳴都不會實際生效。#LAST#"
	end
	for _, d in ipairs(self.lib.defs) do
		out[#out + 1] = (self.active[d.id] and "#LIGHT_GREEN#● %s#LAST#　%s" or "#GREY#○ %s　%s#LAST#"):format(d.name, d.desc)
	end
	return table.concat(out, "\n")
end

function _M:select(item)
	if not item then return end
	local txt
	if item.row == "slot" then
		local s = item.slot
		if s.empty then
			txt = "#GOLD#空的銘文槽#LAST#\n\n從背包裡選一個銘文，右邊會告訴你刻上去之後共鳴會怎麼變。"
		else
			local without = {}
			for _, v in ipairs(self.current) do if v.id ~= s.id then without[#without + 1] = v end end
			local _, lost = self.lib.diff(self.current, without)
			txt = ("#GOLD#%s#LAST#\n#GREY#%s / %s#LAST#\n\n"):format(s.name, ("槽 %d"):format(s.slot), s.kind)
			txt = txt .. (#lost > 0 and ("#LIGHT_RED#拆掉它會失去：#LAST#%s"):format(names(lost)) or "#GREY#拆掉它不會影響任何共鳴。#LAST#")
		end
	elseif item.row == "cand" then
		local c = item.cand
		local lines = { ("#GOLD#%s#LAST#\n#GREY#背包 / %s#LAST#\n"):format(c.name, c.kind) }
		for _, opt in ipairs(self:candOptions(c)) do
			local head = (opt.empty and "#AQUAMARINE#刻進空的槽 %d#LAST#" or "#AQUAMARINE#取代槽 %d（%s）#LAST#"):format(opt.slot, opt.replaces)
			local body = {}
			if #opt.gained > 0 then body[#body + 1] = ("#LIGHT_GREEN#獲得 %s#LAST#"):format(names(opt.gained)) end
			if #opt.lost > 0 then body[#body + 1] = ("#LIGHT_RED#失去 %s#LAST#"):format(names(opt.lost)) end
			if #body == 0 then body[1] = "#GREY#共鳴不變#LAST#" end
			lines[#lines + 1] = head .. "\n    " .. table.concat(body, "\n    ")
		end
		txt = table.concat(lines, "\n")
	end
	self.c_desc:switchItem(item, txt)
end
