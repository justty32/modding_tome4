### 完整實作：`mod/dialogs/SkillLearnDialog.lua`

```lua
-- mod/dialogs/SkillLearnDialog.lua
-- 自訂技能學習界面
-- 保留舊版 UseTalents Dialog，此為獨立新界面

require "engine.class"
local Dialog    = require "engine.ui.Dialog"
local TreeList  = require "engine.ui.TreeList"
local Textzone  = require "engine.ui.Textzone"
local Button    = require "engine.ui.Button"
local Separator = require "engine.ui.Separator"

module(..., package.seeall, class.inherit(Dialog))

-- ── 建構函式 ─────────────────────────────────────────────────
function _M:init(actor)
    self.actor = actor

    Dialog.init(self, "技能學習", game.w * 0.75, game.h * 0.8)

    -- 右側區域的寬度
    local right_w = math.floor(self.iw * 0.45)
    -- 左側 TreeList 的寬度
    local left_w  = self.iw - right_w - 20  -- 20 是中間 Separator 的空間

    -- 右側：天賦說明區域（可捲動）
    self.c_desc = Textzone.new{
        width       = right_w,
        height      = self.ih - 60,
        auto_height = false,
        scrollbar   = true,
        text        = "#GREY#選擇一個天賦以查看說明。",
    }

    -- 右側底部：學習按鈕 + 點數顯示
    self.c_learn_btn = Button.new{
        text = "學習（消耗 1 點）",
        fct  = function() self:doLearn() end,
    }
    self.c_points_label = Textzone.new{
        width       = right_w,
        height      = 30,
        auto_height = false,
        text        = self:getPointsText(),
    }

    -- 建立左側 TreeList 資料
    self:buildTree()

    self.c_tree = TreeList.new{
        width    = left_w,
        height   = self.ih - 10,
        scrollbar = true,
        -- 欄位定義
        columns  = {
            {name = "天賦名稱", width = 65, display_prop = "name"},
            {name = "等級",     width = 17, display_prop = "level_str"},
            {name = "狀態",     width = 18, display_prop = "status_str"},
        },
        tree     = self.tree,
        -- 點擊展開/收合
        fct      = function(item) if not item.sub then self:onSelect(item) end end,
        select   = function(item, sel) if sel and not item.sub then self:onSelect(item) end end,
    }

    -- 佈局
    self:loadUI{
        -- 左側：TreeList（0 偏移，頂對齊）
        {left = 0, top = 0, ui = self.c_tree},
        -- 中間：垂直分隔線
        {left = left_w + 5, top = 5,
         ui = Separator.new{dir = "vertical", size = self.ih - 10}},
        -- 右側頂：天賦說明
        {right = 0, top = 0, ui = self.c_desc},
        -- 右側底：可用點數
        {right = 0, bottom = self.c_learn_btn.h + 5, ui = self.c_points_label},
        -- 右側最底：學習按鈕
        {right = 0, bottom = 0, ui = self.c_learn_btn},
    }

    self:setupUI()
    self:setFocus(self.c_tree)

    -- 鍵盤綁定
    self.key:addBinds{
        EXIT = function() game:unregisterDialog(self) end,
    }
end

-- ── 可用點數文字 ──────────────────────────────────────────────
function _M:getPointsText()
    local pts = self.actor.unused_talents or 0
    if pts == 0 then
        return "#RED#可用天賦點數：0（無法學習）"
    else
        return ("#LIGHT_GREEN#可用天賦點數：%d"):format(pts)
    end
end

-- ── 建立 TreeList 資料 ────────────────────────────────────────
-- TreeList 期望的資料結構：
--   {
--     { name="分類名稱", sub={...子項目...} },  ← 分類節點（可展開）
--     { name="天賦名稱", talent_id=..., ... },  ← 葉節點（可選中）
--   }
function _M:buildTree()
    self.tree = {}
    self.talent_items = {}  -- 用於 doLearn 查找當前選中的天賦

    local actor = self.actor

    for i, tt in ipairs(actor.talents_types_def or {}) do
        -- 只顯示玩家已解鎖的分類（known = true）
        if tt.known then
            local sub_items = {}
            local cat_display = tt.type:gsub(".*/", ""):capitalize()

            for j, t in ipairs(tt.talents or {}) do
                local cur_lv  = actor:getTalentLevelRaw(t.id) or 0
                local max_lv  = t.points or 1
                local can, why = actor:canLearnTalent(t)

                -- 狀態文字
                local status
                if cur_lv >= max_lv then
                    status = "#GREY#已滿"
                elseif can then
                    status = "#LIGHT_GREEN#可學"
