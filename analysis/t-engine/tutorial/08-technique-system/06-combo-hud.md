這是與現有技能樹 UI 最大的差異點。我們建立一個**常駐橫條**，顯示 5 個槽位和連擊狀態：

```lua
-- game/modules/hellodungeon/class/ui/TechniqueBar.lua

require "engine.class"

module(..., package.seeall, class.make)

local SLOT_W = 80    -- 每個槽位寬度（像素）
local SLOT_H = 50    -- 槽位高度
local SLOT_PAD = 4   -- 槽位間距
local COMBO_W = 120  -- 連擊計數區寬度

--- 建立連技橫條
-- @param x, y 左上角座標（通常貼近螢幕底部）
-- @param actor 玩家 Actor
function _M:init(actor, x, y)
    self.actor = actor
    self.display_x = x
    self.display_y = y
    -- 總寬度：5槽位 + 連擊區
    self.w = (SLOT_W + SLOT_PAD) * 5 + COMBO_W
    self.h = SLOT_H + 20  -- 20 像素給文字標籤

    -- 字型
    self.font = core.display.newFont("/data/font/DroidSans.ttf", 11)
    self.font_h = self.font:lineSkip()

    -- 快取 surface
    self.surface = core.display.newSurface(self.w, self.h)
    self.texture = nil
    self.texture_w, self.texture_h = 0, 0
end

--- 重新繪製 surface（僅在 actor.changed 時）
function _M:display()
    local a = self.actor
    if not a or not a.changed then return end

    -- 清空背景（半透明黑）
    self.surface:erase(20, 20, 20)

    -- ── 繪製 5 個槽位 ─────────────────────────────────
    for slot = 1, 5 do
        local sx = (slot - 1) * (SLOT_W + SLOT_PAD)
        local t  = a:getTechniqueInSlot(slot)

        -- 槽位外框
        local border_r, border_g, border_b = 80, 80, 80
        if t then
            -- 有連技：依類型顯示不同框色
            if t.type == "starter"  then border_r, border_g, border_b = 60, 120, 220 end
            if t.type == "linker"   then border_r, border_g, border_b = 60, 200, 120 end
            if t.type == "finisher" then border_r, border_g, border_b = 220, 60, 60  end
            if t.type == "free"     then border_r, border_g, border_b = 180, 180, 60 end
        end
        -- 外框（1 像素邊框用四個矩形模擬）
        self.surface:drawRect(sx, 0, SLOT_W, SLOT_H, border_r, border_g, border_b)
        self.surface:drawRect(sx+1, 1, SLOT_W-2, SLOT_H-2, 25, 25, 35)

        if t then
            -- 冷卻遮罩
            local cd = a.techniques.cooldowns[t.id] or 0
            if cd > 0 then
                -- 半透明黑色覆蓋
                self.surface:drawRect(sx+1, 1, SLOT_W-2, SLOT_H-2, 0, 0, 0)
                -- 冷卻數字
                local cds = tostring(cd)
                local tw, th = self.font:size(cds)
                local tex = self.font:draw(cds, SLOT_W, 255, 80, 80)[1]
                self.surface:merge(tex._tex_data or tex, sx + (SLOT_W - tw) / 2, (SLOT_H - th) / 2)
            else
                -- 顯示連技符號（或名稱縮寫）
                local sym = t.display or t.name:sub(1,2)
                local cr, cg, cb = table.unpack(t.color or {200, 200, 200})
                local tex = self.font:draw(sym, SLOT_W, cr, cg, cb)[1]
                local tw, th = self.font:size(sym)
                self.surface:merge(tex._tex_data or tex, sx + (SLOT_W - tw) / 2, (SLOT_H - th) / 2)
            end

            -- 槽位編號（左上角小字）
            local num_tex = self.font:draw(tostring(slot), 20, 150, 150, 150)[1]
            self.surface:merge(num_tex._tex_data or num_tex, sx + 3, 2)

            -- 技能名稱（底部小字）
            local short_name = t.name:sub(1, 4)  -- 最多 4 字
            local nm_tex = self.font:draw(short_name, SLOT_W, 200, 200, 200)[1]
            self.surface:merge(nm_tex._tex_data or nm_tex, sx + 2, SLOT_H - self.font_h - 1)
        else
            -- 空槽位標示
            local empty_tex = self.font:draw(tostring(slot).." --", SLOT_W, 60, 60, 60)[1]
            self.surface:merge(empty_tex._tex_data or empty_tex, sx + 5, SLOT_H / 2 - self.font_h / 2)
        end
    end

    -- ── 連擊狀態區 ────────────────────────────────────
    local cx = 5 * (SLOT_W + SLOT_PAD)
    local combo = a.combo_state

    -- 連擊計數背景（連擊中閃爍橙色）
    local bg_r, bg_g, bg_b = 30, 30, 30
    if combo.active then
        bg_r, bg_g, bg_b = 80, 50, 20
    end
    self.surface:drawRect(cx, 0, COMBO_W, SLOT_H, bg_r, bg_g, bg_b)

    -- 連擊數字（大字）
    local count_str = combo.active and tostring(combo.count) or "0"
    local cr, cg, cb = combo.active and 255 or 80, combo.active and 150 or 80, combo.active and 0 or 80
    local big_font = core.display.newFont("/data/font/DroidSans-Bold.ttf", 22)
    local count_tex = big_font:draw(count_str, COMBO_W, cr, cg, cb)[1]
    local ctw = big_font:size(count_str)
    self.surface:merge(count_tex._tex_data or count_tex,
        cx + (COMBO_W - ctw) / 2, 4)

    -- 「連擊」標籤
    local label = combo.active
        and ("COMBO  ⏱%d"):format(combo.timer)
        or  "COMBO"
    local label_tex = self.font:draw(label, COMBO_W, 160, 160, 160)[1]
    self.surface:merge(label_tex._tex_data or label_tex, cx + 5, SLOT_H - self.font_h - 1)

    -- 更新 GL 紋理
    self.texture, self.texture_w, self.texture_h = self.surface:glTexture()
end

--- 渲染到螢幕
function _M:toScreen()
    self:display()
    if self.texture then
        self.texture:toScreenFull(
            self.display_x, self.display_y,
            self.w, self.h,
            self.texture_w, self.texture_h
        )
    end
end

--- 滑鼠點擊（傳入的是絕對螢幕座標）
function _M:mouseEvent(button, mx, my)
    -- 轉換為相對座標
    local rx = mx - self.display_x
    local ry = my - self.display_y
    if rx < 0 or ry < 0 or rx > self.w or ry > self.h then return false end

    -- 判斷點的是哪個槽位
    for slot = 1, 5 do
        local sx = (slot - 1) * (SLOT_W + SLOT_PAD)
        if rx >= sx and rx < sx + SLOT_W then
            if button == "left" then
                -- 左鍵：使用此槽位的連技
                self.actor:useTechniqueInSlot(slot)
            elseif button == "right" then
                -- 右鍵：顯示連技說明
                self:showTechniqueTooltip(slot, mx, my)
            end
            return true
        end
    end
    return false
end

--- 顯示工具提示
function _M:showTechniqueTooltip(slot, x, y)
    local t = self.actor:getTechniqueInSlot(slot)
    if not t then return end
    local Dialog = require "engine.ui.Dialog"
    local Textzone = require "engine.ui.Textzone"
    local info = t.info and t:info(self.actor, t) or t.name
    local prof = self.actor:getTechniqueProficiency(t.id)
    local full_text = ("#YELLOW#%s#LAST# [%s]\n"):format(t.name, t.type)..
                      ("氣耗：%d  冷卻：%d 回合\n"):format(t.ki_cost, t.cooldown)..
                      ("熟練度：%.0f%%\n\n"):format(prof * 100)..
                      info
    local d = Dialog.new(t.name, 300, 200)
    local tz = Textzone.new{width=d.iw, height=d.ih, text=full_text}
    d:loadUI{{left=0, top=0, ui=tz}}
    d:setupUI()
    game:registerDialog(d)
end
```

> **注意**：`surface:drawRect`、`surface:merge`、`font:draw` 這些是 TE4 的 C 層 SDL surface API。實際渲染時，`font:draw` 回傳的物件結構依引擎版本略有差異；上面的程式碼以 te4-1.7.6 的標準 API 為準，可能需要根據實際回傳值微調 `_tex_data` 或 `_tex` 欄位名稱。

---
