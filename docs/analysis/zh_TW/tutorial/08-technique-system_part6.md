## 6. 連技 HUD（橫條顯示器）

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
```
