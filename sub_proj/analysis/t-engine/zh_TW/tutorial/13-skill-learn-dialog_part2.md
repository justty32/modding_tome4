# 教學 13：自訂技能學習界面（續）

### buildTree — 建立 TreeList 資料

```lua
function _M:buildTree()
    self.tree = {}
    self.talent_items = {}
    local actor = self.actor
    for i, tt in ipairs(actor.talents_types_def or {}) do
        if tt.known then
            local sub_items = {}
            for j, t in ipairs(tt.talents or {}) do
                local cur_lv  = actor:getTalentLevelRaw(t.id) or 0
                local max_lv  = t.points or 1
                local can, why = actor:canLearnTalent(t)
                local status
                if cur_lv >= max_lv then
                    status = "#GREY#已滿"
                elseif can then
                    status = "#LIGHT_GREEN#可學"
                elseif (actor.unused_talents or 0) == 0 then
                    status = "#RED#無點數"
                else
                    status = "#YELLOW#未達需求"
                end
                local item = {name=t.name, talent=t, talent_id=t.id,
                    level_str=("%d/%d"):format(cur_lv, max_lv),
                    status_str=status, _can_learn=can, _why=why}
                sub_items[#sub_items+1] = item
                self.talent_items[t.id] = item
            end
            if #sub_items > 0 then
                self.tree[#self.tree+1] = {
                    name=("#GOLD#%s"):format(tt.name:capitalize()),
                    sub=sub_items, shown=true}
            end
        end
    end
end
```

### onSelect — 選中天賦更新說明

```lua
function _M:onSelect(item)
    if not item or not item.talent then return end
    self.selected_talent = item.talent
    local desc = self.actor:getTalentFullDescription(item.talent)
    local cur_lv = self.actor:getTalentLevelRaw(item.talent_id) or 0
    local max_lv = item.talent.points or 1
    local header = ("#GOLD#%s#LAST#\n#GREY#等級：%d / %d  |  類型：%s\n\n"):format(
        item.talent.name, cur_lv, max_lv,
        item.talent.type and item.talent.type[1] or "?")
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
    self.c_points_label:setText(self:getPointsText())
end
```

### doLearn — 學習按鈕邏輯

```lua
function _M:doLearn()
    local t = self.selected_talent
    if not t then self:simplePopup("提示","請先選擇一個天賦。") return end
    local actor = self.actor
    local cur_lv = actor:getTalentLevelRaw(t.id) or 0
    local max_lv = t.points or 1
    if cur_lv >= max_lv then
        self:simplePopup("無法學習",
            ("「%s」已達最高等級（%d/%d）。"):format(t.name,cur_lv,max_lv))
        return
    end
    if (actor.unused_talents or 0) <= 0 then
        self:simplePopup("無法學習","沒有可用的天賦點數。\n升級後可獲得天賦點數。")
        return
    end
    local can, why = actor:canLearnTalent(t)
    if not can then
        self:simplePopup("無法學習",
            ("「%s」不符合學習條件：\n%s"):format(t.name, why or "未知原因"))
        return
    end
    actor:learnTalent(t.id)
    actor.unused_talents = (actor.unused_talents or 1) - 1
    actor.changed = true
    game.logPlayer(actor, "#LIGHT_GREEN#學會了 %s（等級 %d）！",
        t.name, actor:getTalentLevelRaw(t.id))
    self:buildTree()
    self.c_tree:setList(self.tree)
    local updated_item = self.talent_items[t.id]
    if updated_item then self:onSelect(updated_item) end
    self.c_points_label:setText(self:getPointsText())
end
```

---

## 步驟二：HUD 技能書圖示按鈕

UISet 管理 HUD 繪製與滑鼠事件。標準流程：
1. `displayUI()` 繪製按鈕圖示
2. `_setupSkillButton()` 記錄位置 + 註冊 mouse zone
3. `clickIcon()` 座標判斷後開啟 Dialog

### `mod/class/uiset/GameUI.lua`

```lua
require "engine.class"
local UISet = require "engine.game.GameUI"
local LogDisplay = require "engine.LogDisplay"
local FontPackage = require "engine.FontPackage"
module(..., package.seeall, class.inherit(UISet))

local _skill_icon, _skill_icon_w, _skill_icon_h

function _M:init() UISet.init(self) end

function _M:activate()
    UISet.activate(self)
    _skill_icon, _skill_icon_w, _skill_icon_h =
        core.display.loadImage("/data/gfx/ui/talents-icon.png"):glTexture()
    local font, size = FontPackage:getFont("default")
    local f = core.display.newFont(font, size)
    self.hud_font, self.hud_font_h = f, f:lineSkip()
    self.logdisplay = LogDisplay.new(0, game.h-self.hud_font_h*5,
        game.w, self.hud_font_h*5, nil, font, size)
    game.log = function(style, ...)
        if type(style)=="number" then self.logdisplay(...)
        else self.logdisplay(style,...) end
    end
    game.logPlayer = function(e, style, ...)
        if e==game.player or e==game.party then game.log(style,...) end
    end
    self:_setupSkillButton()
end

function _M:_setupSkillButton()
    local btn_w, btn_h = _skill_icon_w or 32, _skill_icon_h or 32
    self.skill_btn = {x=game.w-btn_w-8, y=game.h-btn_h-8, w=btn_w, h=btn_h}
    if game.mouse then
        game.mouse:registerZone(self.skill_btn.x, self.skill_btn.y,
            self.skill_btn.w, self.skill_btn.h,
            function(button,mx,my,xrel,yrel,bx,by,event)
                if event=="button" and button=="left" then
                    self:openSkillDialog()
                elseif event=="motion" then
                    game:tooltipDisplayAtMap(game.w,game.h,
                        "#GOLD#技能學習\n#LAST#點擊開啟技能學習界面。")
                end
            end)
    end
end
```

---（續 part3）---