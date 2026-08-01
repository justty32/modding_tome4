-- 符文盤資料收集 —— 純函數，不依賴 UI 狀態。
local M = {}

--- 目前的銘文槽。空槽也要留一列，玩家才知道自己還有位子。
function M.gatherSlots(actor)
	local slots = {}
	for i = 1, (actor.max_inscriptions or 3) do
		local sname = actor.inscriptions and actor.inscriptions[i]
		if sname then
			local t = actor:getTalentFromId(actor["T_" .. sname])
			if t then
				slots[#slots + 1] = { slot = i, id = t.short_name, name = t.name,
					kind = (t.type and t.type[1] or ""):gsub("^inscriptions/", ""), }
			end
		else
			slots[#slots + 1] = { slot = i, empty = true }
		end
	end
	return slots
end

--- 背包候選銘文。
function M.gatherCandidates(actor)
	local out = {}
	local inven = actor:getInven(actor.INVEN_INVEN)
	for _, o in ipairs(inven or {}) do
		if o.inscription_data and o.inscription_talent then
			out[#out + 1] = { id = o.inscription_talent,
				name = o:getName{ do_color = false, no_count = true },
				kind = (o.subtype or "") .. "s", }
		end
	end
	return out
end

--- 組裝完整資料（不含 hint，hint 由 UI 層填入）。
function M.gather(actor, lib)
	local slots = M.gatherSlots(actor)
	local candidates = M.gatherCandidates(actor)
	local current = {}
	for _, s in ipairs(slots) do
		if not s.empty then current[#current + 1] = { id = s.id, name = s.name, kind = s.kind } end
	end
	local active = {}
	for _, d in ipairs(lib.evaluate(current)) do active[d.id] = true end
	return slots, current, candidates, active
end

return M
