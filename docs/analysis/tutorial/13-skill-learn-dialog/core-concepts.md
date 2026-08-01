### TE4 Dialog 的生命週期

```lua
-- 開啟 Dialog
game:registerDialog(MyDialog.new(args))
-- → 加入 game.dialogs 列表
-- → 下一幀開始渲染
-- → Dialog 的 key/mouse 接管輸入

-- 關閉 Dialog
game:unregisterDialog(self)
-- → 從 game.dialogs 移除
-- → 輸入控制返還給前一個 Dialog 或遊戲本身
```

### `loadUI` 佈局系統

Dialog 的 `loadUI` 接受一個表格，每個元素描述一個 UI 元件的位置：

```lua
self:loadUI{
    {left=0,   top=0,    ui=left_widget},   -- 距左邊 0，距頂部 0
    {right=0,  top=0,    ui=right_widget},  -- 距右邊 0，距頂部 0
    {left=0,   bottom=0, ui=bottom_btn},    -- 距左邊 0，距底部 0
    {hcenter=0, vcenter=0, ui=center_widget}, -- 水平+垂直置中
}
-- left/right/top/bottom 是相對於 Dialog 內容區域（iw × ih）的偏移
```

### 天賦資料結構

```lua
-- actor.talents_types_def → {tt1, tt2, ...}（天賦分類列表）
-- 每個分類：
tt = {
    type    = "generic/speed",   -- 分類 ID
    name    = "速度技巧",         -- 顯示名稱
    talents = {t1, t2, ...},     -- 此分類中的天賦列表
    known   = true,              -- 玩家是否解鎖此分類
    mastery = 1.0,               -- 熟練度
}

-- actor.talents_def[T_FIREBALL] → 天賦定義
t = {
    id      = T_FIREBALL,
    name    = "火球術",
    type    = {"spell/fire", 1},  -- {分類ID, 分類中的排序位置}
    require = {level={2}},        -- 等級需求
    points  = 5,                  -- 最大等級
    mode    = "activated",        -- "activated" / "sustained" / "passive"
}

-- 玩家天賦狀態
actor:getTalentLevelRaw(t.id)  -- 當前等級（0 = 未學習）
actor:canLearnTalent(t)        -- 返回 true 或 false, "錯誤訊息"
actor:learnTalent(t.id)        -- 學習 / 升級（消耗 unused_talents 點數）
actor.unused_talents           -- 可用天賦點數
actor:getTalentFullDescription(t)  -- 完整說明文字
```

---
