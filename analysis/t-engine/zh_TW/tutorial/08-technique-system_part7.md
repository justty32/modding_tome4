```lua
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
