### 1. 天賦分頁（Tabs）

把天賦分類改用 `Tabs` 元件顯示，每個 Tab 是一個獨立的 TreeList：

```lua
local Tabs = require "engine.ui.Tabs"
self.c_tabs = Tabs.new{
    width = left_w,
    height = self.ih - 10,
    tabs = {
        {title = "戰鬥",   ui = self:buildTabList("combat")},
        {title = "魔法",   ui = self:buildTabList("spell")},
        {title = "通用",   ui = self:buildTabList("generic")},
    },
}
```

### 2. 即時預覽（學習前預覽效果）

點擊「學習」前，右側額外顯示學習後的下一等級說明：

```lua
-- 在 onSelect 中額外顯示下一級說明
local next_lv = cur_lv + 1
if next_lv <= max_lv then
    local next_desc = self.actor:getTalentFullDescription(t, next_lv)
    self.c_desc:setText(... "\n#YELLOW#──下一級說明──\n" .. next_desc)
end
```

### 3. 支援天賦書 / 捲軸學習

若天賦可以透過道具（天賦書）學習，在 `doLearn()` 中加入判斷，消耗道具而非點數：

```lua
-- 學習天賦書：消耗背包中對應的書
local book = self:findBook(t.id)
if book then
    self.actor:removeObject(self.actor:getInven("INVEN"), book_idx)
    self.actor:learnTalent(t.id)
else
    -- 沒有書，走普通消耗點數流程
end
```

---
