                elseif (actor.unused_talents or 0) == 0 then
                    status = "#RED#無點數"
                else
                    status = "#YELLOW#未達需求"
                end

                local item = {
                    name       = t.name,
                    level_str  = ("%d/%d"):format(cur_lv, max_lv),
                    status_str = status,
                    talent     = t,
                    talent_id  = t.id,
                    _can_learn = can,
                    _why       = why,
                }
                sub_items[#sub_items+1] = item
                self.talent_items[t.id] = item
            end

            if #sub_items > 0 then
                self.tree[#self.tree+1] = {
                    name      = ("#GOLD#%s"):format(tt.name:capitalize()),
                    -- TreeList 用 sub 欄位識別分類節點
                    sub       = sub_items,
                    -- 預設展開
                    shown     = true,
                }
            end
        end
    end
end

-- ── 選中天賦時更新說明 ────────────────────────────────────────
function _M:onSelect(item)
    if not item or not item.talent then return end

    self.selected_talent = item.talent

    -- 更新說明文字
    local desc = self.actor:getTalentFullDescription(item.talent)
    local cur_lv = self.actor:getTalentLevelRaw(item.talent_id) or 0
    local max_lv = item.talent.points or 1

    local header = ("#GOLD#%s#LAST#\n#GREY#等級：%d / %d  |  類型：%s\n\n"):format(
        item.talent.name,
        cur_lv, max_lv,
        item.talent.type and item.talent.type[1] or "?"
    )

    -- 若有前置需求，顯示
    local req_text = ""
    if item.talent.require then
        req_text = "#YELLOW#前置需求：\n"
        local req = item.talent.require
        if req.level then
            req_text = req_text .. ("  等級 %d 以上\n"):format(req.level[1] or 0)
        end
        if req.talent then
            for _, rv in ipairs(req.talent) do
                local req_t = self.actor:getTalentFromId(rv[1])
                req_text = req_text .. ("  需要：%s Lv.%d\n"):format(
                    req_t and req_t.name or tostring(rv[1]), rv[2] or 1)
            end
        end
        req_text = req_text .. "\n"
    end

    self.c_desc:setText(header .. req_text .. (desc or "（無說明）"))

    -- 更新可用點數文字
    self.c_points_label:setText(self:getPointsText())
end

-- ── 學習按鈕邏輯 ─────────────────────────────────────────────
function _M:doLearn()
    local t = self.selected_talent
    if not t then
        self:simplePopup("提示", "請先選擇一個天賦。")
        return
    end

    local actor = self.actor
    local cur_lv = actor:getTalentLevelRaw(t.id) or 0
    local max_lv = t.points or 1

    -- 1. 已達上限
    if cur_lv >= max_lv then
        self:simplePopup("無法學習", ("「%s」已達最高等級（%d/%d）。"):format(
            t.name, cur_lv, max_lv))
        return
    end

    -- 2. 沒有可用點數
    if (actor.unused_talents or 0) <= 0 then
        self:simplePopup("無法學習", "沒有可用的天賦點數。\n升級後可獲得天賦點數。")
        return
    end

    -- 3. 不符合前置需求
    local can, why = actor:canLearnTalent(t)
    if not can then
        self:simplePopup("無法學習",
            ("「%s」不符合學習條件：\n%s"):format(t.name, why or "未知原因"))
        return
    end

    -- 4. 學習
    actor:learnTalent(t.id)
    actor.unused_talents = (actor.unused_talents or 1) - 1
    actor.changed = true

    game.logPlayer(actor, "#LIGHT_GREEN#學會了 %s（等級 %d）！",
        t.name, actor:getTalentLevelRaw(t.id))

    -- 5. 刷新列表（等級和狀態可能改變）
    self:buildTree()
    self.c_tree:setList(self.tree)

    -- 6. 更新右側說明和點數
    local updated_item = self.talent_items[t.id]
    if updated_item then
        self:onSelect(updated_item)
    end

    self.c_points_label:setText(self:getPointsText())
end
```

---
