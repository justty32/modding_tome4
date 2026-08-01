# 教學 13：自訂技能學習界面

## 目標

新技能學習 Dialog + HUD 按鈕：
- 左欄 TreeList：天賦分類（可展開）| 等級 | 狀態
- 右欄：選中天賦說明 + 學習按鈕
- 保留舊 `UseTalents` Dialog，原快捷鍵不受影響

---

## Dialog 生命週期

```lua
game:registerDialog(MyDialog.new(args))  -- 加入 game.dialogs，下一幀開始渲染
game:unregisterDialog(self)              -- 從 game.dialogs 移除，輸入返還
```

## `loadUI` 佈局

```lua
-- 每個元素描述 UI 元件位置，偏移量相對於內容區域（iw × ih）
self:loadUI{
    {left=0,   top=0,    ui=w},    -- 左上
    {right=0,  top=0,    ui=w},    -- 右上
    {left=0,   bottom=0, ui=w},    -- 左下
    {hcenter=0, vcenter=0, ui=w},  -- 置中
}
```

## 天賦資料結構

```lua
-- actor.talents_types_def → {tt1, tt2, ...}，每個分類：
tt = { type="generic/speed", name="速度技巧", talents={...},
       known=true, mastery=1.0 }

-- actor.talents_def[T_FIREBALL] → 天賦定義
t = { id=T_FIREBALL, name="火球術", type={"spell/fire",1},
      require={level={2}}, points=5, mode="activated" }

-- 玩家天賦狀態
actor:getTalentLevelRaw(t.id)          -- 當前等級（0=未學）
actor:canLearnTalent(t)                -- → true/false, "原因"
actor:learnTalent(t.id)                -- 學習/升級（消耗點數）
actor.unused_talents                   -- 可用點數
actor:getTalentFullDescription(t)      -- 完整說明
```

---

## 檔案結構

```
mod/
  dialogs/SkillLearnDialog.lua        ← 主 Dialog
  class/uiset/GameUI.lua              ← 自訂 UISet，技能書按鈕
  class/Game.lua                      ← 鍵綁定 SHOW_SKILL_TREE
  data/keybinds/interface.lua         ← 鍵位宣告
```

---

## 步驟一：技能學習 Dialog

### `mod/dialogs/SkillLearnDialog.lua`

```lua
require "engine.class"
local Dialog    = require "engine.ui.Dialog"
local TreeList  = require "engine.ui.TreeList"
local Textzone  = require "engine.ui.Textzone"
local Button    = require "engine.ui.Button"
local Separator = require "engine.ui.Separator"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(actor)
    self.actor = actor
    Dialog.init(self, "技能學習", game.w * 0.75, game.h * 0.8)
    local right_w = math.floor(self.iw * 0.45)
    local left_w  = self.iw - right_w - 20

    self.c_desc = Textzone.new{width=right_w, height=self.ih-60,
        auto_height=false, scrollbar=true,
        text="#GREY#選擇一個天賦以查看說明。"}

    self.c_learn_btn = Button.new{text="學習（消耗 1 點）",
        fct=function() self:doLearn() end}
    self.c_points_label = Textzone.new{width=right_w, height=30,
        auto_height=false, text=self:getPointsText()}

    self:buildTree()
    self.c_tree = TreeList.new{width=left_w, height=self.ih-10,
        scrollbar=true,
        columns={
            {name="天賦名稱", width=65, display_prop="name"},
            {name="等級",     width=17, display_prop="level_str"},
            {name="狀態",     width=18, display_prop="status_str"},
        },
        tree=self.tree,
        fct=function(item) if not item.sub then self:onSelect(item) end end,
        select=function(item,sel)
            if sel and not item.sub then self:onSelect(item) end end,
    }

    self:loadUI{
        {left=0, top=0, ui=self.c_tree},
        {left=left_w+5, top=5,
         ui=Separator.new{dir="vertical", size=self.ih-10}},
        {right=0, top=0, ui=self.c_desc},
        {right=0, bottom=self.c_learn_btn.h+5, ui=self.c_points_label},
        {right=0, bottom=0, ui=self.c_learn_btn},
    }
    self:setupUI()
    self:setFocus(self.c_tree)
    self.key:addBinds{EXIT = function() game:unregisterDialog(self) end}
end

function _M:getPointsText()
    local pts = self.actor.unused_talents or 0
    if pts==0 then return "#RED#可用天賦點數：0（無法學習）"
    else return ("#LIGHT_GREEN#可用天賦點數：%d"):format(pts) end
end
```

---（續 part2）---