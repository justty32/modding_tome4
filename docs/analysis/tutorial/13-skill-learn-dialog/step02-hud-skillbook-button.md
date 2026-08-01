### 設計方法

TE4 的 UISet 管理 HUD 的繪製和滑鼠事件。加入新按鈕的標準流程：

1. 在 `displayUI()` 中把按鈕圖示繪製到螢幕
2. 在 `createSeparators()` 中記錄按鈕的位置和尺寸
3. 在 `clickIcon()` 中根據點擊座標開啟 Dialog

對於**自訂模組**（不繼承 ToME UISet），最乾淨的方法是讓模組有自己的 UISet 類別。以下示範在簡化的自訂 UISet 中加入按鈕。

### 自訂 UISet：`mod/class/uiset/GameUI.lua`

```lua
-- mod/class/uiset/GameUI.lua
-- 自訂 UISet，在 HUD 下方加入技能書按鈕

require "engine.class"
local UISet     = require "engine.game.GameUI"   -- 引擎基礎 UISet
local LogDisplay = require "engine.LogDisplay"
local FontPackage = require "engine.FontPackage"

module(..., package.seeall, class.inherit(UISet))

-- 預載入按鈕圖示（module 層級，只載入一次）
local _skill_icon, _skill_icon_w, _skill_icon_h
local _skill_icon_sel, _, _  -- hover 高亮版（可選）

function _M:init()
    UISet.init(self)
end

function _M:activate()
    UISet.activate(self)

    -- 載入技能書圖示
    -- 你可以替換為自己的圖片路徑；這裡借用引擎現有圖示做示範
    _skill_icon, _skill_icon_w, _skill_icon_h =
        core.display.loadImage("/data/gfx/ui/talents-icon.png"):glTexture()

    -- 字型
    local font, size = FontPackage:getFont("default")
    local f = core.display.newFont(font, size)
    self.hud_font   = f
    self.hud_font_h = f:lineSkip()

    -- 訊息日誌
    self.logdisplay = LogDisplay.new(
        0, game.h - self.hud_font_h * 5,
        game.w, self.hud_font_h * 5,
        nil, font, size)

    game.log = function(style, ...)
        if type(style) == "number" then
            self.logdisplay(...)
        else
            self.logdisplay(style, ...)
        end
    end
    game.logPlayer = function(e, style, ...)
        if e == game.player or e == game.party then
            game.log(style, ...)
        end
    end

    -- 記錄技能書按鈕的位置（供 clickIcon 使用）
    self:_setupSkillButton()
end

-- ── 設定技能書按鈕的螢幕位置 ─────────────────────────────────
function _M:_setupSkillButton()
    -- 把按鈕放在螢幕右下角
    local btn_w = _skill_icon_w or 32
    local btn_h = _skill_icon_h or 32
    self.skill_btn = {
        x = game.w - btn_w - 8,
        y = game.h - btn_h - 8,
        w = btn_w,
        h = btn_h,
    }

    -- 向 game 的全域滑鼠系統註冊這個區域
    -- （UISet 的 mouse 物件由引擎在 setupMouse 時掛載）
    if game.mouse then
        game.mouse:registerZone(
            self.skill_btn.x, self.skill_btn.y,
            self.skill_btn.w, self.skill_btn.h,
            function(button, mx, my, xrel, yrel, bx, by, event)
                if event == "button" and button == "left" then
                    self:openSkillDialog()
                elseif event == "motion" then
                    -- hover：顯示 tooltip
                    game:tooltipDisplayAtMap(game.w, game.h,
                        "#GOLD#技能學習\n#LAST#點擊開啟技能學習界面。")
                end
            end
        )
    end
end

-- ── displayUI：每幀繪製 HUD ───────────────────────────────────
function _M:displayUI()
    -- 繪製訊息日誌背景（半透明黑色）
    core.display.drawQuad(
        0, game.h - self.hud_font_h * 5 - 2,
        game.w, self.hud_font_h * 5 + 2,
        0, 0, 0, 180)

    -- 繪製技能書圖示按鈕
    if _skill_icon and self.skill_btn then
        local b = self.skill_btn

        -- hover 效果：滑鼠移到按鈕上時略微增亮
        local mx, my = core.mouse.get()
        local hover = mx >= b.x and mx <= b.x + b.w
                  and my >= b.y and my <= b.y + b.h

        -- 繪製按鈕背景框（半透明圓角矩形）
        core.display.drawQuad(b.x - 2, b.y - 2, b.w + 4, b.h + 4,
            20, 20, 20, hover and 200 or 150)

        -- 繪製圖示
        local alpha = hover and 1.0 or 0.8
        _skill_icon:toScreenFull(b.x, b.y, b.w, b.h,
            _skill_icon_w, _skill_icon_h,
            alpha, alpha, alpha, alpha)  -- r g b a

        -- 繪製標籤文字（圖示下方）
        local label = "技能"
        local lw    = self.hud_font:size(label)
        self.hud_font:drawColorString(
            core.display.glMatrix(),
            label,
            b.x + (b.w - lw) / 2, b.y + b.h + 2,
            hover and 1 or 0.7,   -- r
            hover and 1 or 0.9,   -- g
            hover and 0 or 0.7,   -- b
            true)
    end
end

-- ── 開啟技能學習 Dialog ───────────────────────────────────────
function _M:openSkillDialog()
    if not game.player then return end
    game:registerDialog(
        require("mod.dialogs.SkillLearnDialog").new(game.player)
    )
end
```

> **`toScreenFull(x, y, w, h, tex_w, tex_h, r, g, b, a)`**：把 glTexture 繪製到指定矩形區域，`r g b a` 是顏色乘數（1.0 = 原色，< 1.0 = 變暗）。

---
