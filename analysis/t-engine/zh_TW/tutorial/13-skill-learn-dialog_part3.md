# 教學 13：自訂技能學習界面（續）

### displayUI — 每幀繪製 HUD

```lua
function _M:displayUI()
    -- 訊息日誌背景（半透明黑）
    core.display.drawQuad(0, game.h-self.hud_font_h*5-2,
        game.w, self.hud_font_h*5+2, 0,0,0,180)
    -- 技能書圖示
    if _skill_icon and self.skill_btn then
        local b = self.skill_btn
        local mx, my = core.mouse.get()
        local hover = mx>=b.x and mx<=b.x+b.w and my>=b.y and my<=b.y+b.h
        core.display.drawQuad(b.x-2, b.y-2, b.w+4, b.h+4,
            20,20,20, hover and 200 or 150)
        local alpha = hover and 1.0 or 0.8
        _skill_icon:toScreenFull(b.x, b.y, b.w, b.h,
            _skill_icon_w, _skill_icon_h,
            alpha,alpha,alpha,alpha)
        local label = "技能"
        local lw = self.hud_font:size(label)
        self.hud_font:drawColorString(core.display.glMatrix(), label,
            b.x+(b.w-lw)/2, b.y+b.h+2,
            hover and 1 or 0.7, hover and 1 or 0.9,
            hover and 0 or 0.7, true)
    end
end

function _M:openSkillDialog()
    if not game.player then return end
    game:registerDialog(
        require("mod.dialogs.SkillLearnDialog").new(game.player))
end
```

> `glTexture:toScreenFull(x,y,w,h,tex_w,tex_h,r,g,b,a)`：r/g/b/a 為顏色乘數（1.0=原色）。

---

## 步驟三：鍵盤快捷鍵

### `mod/class/Game.lua → setupCommands()`

```lua
function _M:setupCommands()
    -- 原有指令...
    self.key:addBinds{
        SHOW_SKILL_TREE = function()
            game:registerDialog(
                require("mod.dialogs.SkillLearnDialog").new(self.player))
        end,
        -- 保留舊版 UseTalents（預設 T 鍵）
        USE_TALENTS = function()
            game:registerDialog(
                require("engine.dialogs.UseTalents").new(self.player))
        end,
    }
end
```

### `data/keybinds/interface.lua`

```lua
defineKeyBind{
    default = {{key="_k"}},   -- 預設 K 鍵
    id      = "SHOW_SKILL_TREE",
    name    = "開啟技能學習界面",
    type    = "interface",
}
```

---

## 步驟四：載入 UISet

### `mod/class/Game.lua → init()`

```lua
function _M:init(zone, level, player)
    -- ... 原有初始化 ...
    self.uiset = require("mod.class.uiset.GameUI").new()
    self.uiset:activate()
end
```

---

## 佈局一覽

| 區塊 | 元件 | 內容 |
|------|------|------|
| 左欄 | TreeList（天賦名稱/等級/狀態） | 依天賦樹分組可摺疊，如「戰鬥」下：近戰攻擊 `2/5 可學`、防禦姿態 `0/5 未達` |
| 右欄上 | TextzoneList（選中天賦說明） | 名稱、等級、類型、前置需求、說明文字 |
| 右欄下 | 資訊列 + Button | 可用點數 + 〔學習〕按鈕 |
| 底部 | Button（自動） | 〔關閉〕 |

狀態四值：**可學**（滿足條件）、**未達**（前置不足）、**已滿**（達上限）、**無點**（點數不足）。

---

## 步驟五：simplePopup

`Dialog:simplePopup(title, text)` 由引擎基礎類別提供，不需額外實作。極簡 UI 可用 log 替代：

```lua
function _M:doLearn()
    -- ...（省略前置檢查）
    local can, why = actor:canLearnTalent(t)
    if not can then
        game.logPlayer(actor,"#RED#無法學習「%s」：%s", t.name, why or "未知原因")
        return
    end
    -- ...
end
```

---

## 常見問題

| 現象 | 原因 | 解法 |
|------|------|------|
| TreeList 空白 | 無 known= true 分類 | 確認 `talents_types_def` 已填充且 `known=true` |
| 學習後等級未更新 | 未重建列表 | `doLearn()` 末尾呼叫 `self.c_tree:setList(self.tree)` |
| `canLearnTalent` 始終 false | `unused_talents` 為 0 | `newGame()` 設 `player.unused_talents = 3` |
| 按鈕無反應 | `game.mouse` 尚未初始化 | 將 `_setupSkillButton` 延遲到 `setupMouse` 完成後 |
| `toScreenFull` 參數錯誤 | TE4 glTexture 簽名需精確 | `tex:toScreenFull(x,y,w,h,tex_w,tex_h)`（基礎版不帶顏色） |
| `loadUI` 佈局錯亂 | `right=0`/`bottom=0` 相對於 `iw`/`ih` 非 `w`/`h` | 確認 `Dialog.init` 已正確設定 `iw`/`ih` |
| 舊 UseTalents 消失 | 誤刪 `USE_TALENTS` 綁定 | `setupCommands` 保留兩個綁定 |

---

## 進階擴展

### 1. 分頁 Tabs

```lua
local Tabs = require "engine.ui.Tabs"
self.c_tabs = Tabs.new{width=left_w, height=self.ih-10, tabs={
    {title="戰鬥", ui=self:buildTabList("combat")},
    {title="魔法", ui=self:buildTabList("spell")},
    {title="通用", ui=self:buildTabList("generic")},
}}
```

### 2. 預覽下一級

```lua
-- onSelect 中額外顯示下一級說明
if next_lv <= max_lv then
    local nd = self.actor:getTalentFullDescription(t, next_lv)
    self.c_desc:setText(... "\n#YELLOW#──下一級──\n" .. nd)
end
```

### 3. 天賦書消耗

```lua
local book = self:findBook(t.id)
if book then
    self.actor:removeObject(self.actor:getInven("INVEN"), book_idx)
    self.actor:learnTalent(t.id)
else -- 走普通點數流程 end
```

---

## 總結

| 概念 | 實作 | 關鍵 API |
|------|------|----------|
| 自訂 Dialog | `dialogs/SkillLearnDialog.lua` | `Dialog.init` + `loadUI` + `setupUI` |
| TreeList 天賦樹 | `buildTree()` | `TreeList.new{tree=..., columns=...}` |
| 天賦資料讀取 | `actor.talents_types_def` | `getTalentLevelRaw` / `canLearnTalent` / `learnTalent` |
| 學習邏輯 | `doLearn()` | `actor:learnTalent(t.id)` / `actor.unused_talents` |
| HUD 圖示按鈕 | `GameUI:displayUI()` | `glTexture:toScreenFull` / `game.mouse:registerZone` |
| 鍵盤快捷鍵 | `setupCommands()` | `self.key:addBinds{SHOW_SKILL_TREE=...}` |
| 舊界面保留 | `setupCommands()` 的 `USE_TALENTS` | 不刪原有綁定，新舊並存 |