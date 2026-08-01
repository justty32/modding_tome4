### 農田三態轉換

```
FARM_EMPTY  ──種植──→  FARM_GROWING  ──成熟──→  FARM_READY
（空農田）               （生長中）                （可收穫）
    ↑                                                 ↓
    └─────────────────收穫後重置──────────────────────┘
```

### 修改 `mod/data/grids/camp.lua`（追加以下定義）

```lua
-- ── 農田三態 Grid ──────────────────────────────────────────────

-- 空農田（未種植）
newEntity{
    define_as = "FARM_EMPTY",
    name = "空農田",
    display = ',', color_r=139, color_g=90, color_b=43,
    back_color = colors.DARK_UMBER,
    always_remember = true,

    farm_interact = "plant",   -- 旗標：踩上提示可種植
}

-- 農田：生長中
newEntity{
    define_as = "FARM_GROWING",
    name = "農田（生長中）",
    display = ',', color_r=0, color_g=180, color_b=0,
    back_color = colors.DARK_GREEN,
    always_remember = true,

    farm_interact = "check",   -- 旗標：踩上顯示進度
}

-- 農田：可收穫
newEntity{
    define_as = "FARM_READY",
    name = "農田（可收穫！）",
    display = 'F', color_r=255, color_g=220, color_b=0,
    back_color = colors.DARK_GREEN,
    notice          = true,
    always_remember = true,

    farm_interact = "harvest",  -- 旗標：踩上可收穫
}

-- ── 建造地塊 ──────────────────────────────────────────────────
-- 建造前顯示 ?；建造後被對應設施 Grid 替換

newEntity{
    define_as = "BUILD_SITE_FARM",
    name = "建造地塊（農田）",
    display = '?', color_r=139, color_g=90, color_b=43,
    back_color = colors.DARK_UMBER,
    always_remember = true,
    build_site = true,
    build_tag  = "farm",   -- 與 camp_state.buildings 的 key 對應
}

newEntity{
    define_as = "BUILD_SITE_CHEST",
    name = "建造地塊（儲物箱）",
    display = '?', color_r=180, color_g=180, color_b=100,
    back_color = colors.DARK_GREY,
    always_remember = true,
    build_site = true,
    build_tag  = "chest",
}

newEntity{
    define_as = "BUILD_SITE_FIRE",
    name = "建造地塊（強化篝火）",
    display = '?', color_r=255, color_g=100, color_b=0,
    back_color = colors.DARK_RED,
    always_remember = true,
    build_site = true,
    build_tag  = "upgraded_fire",
}

-- ── 建造完成後的設施 Grid ──────────────────────────────────────

-- 強化篝火（建造後替換 BUILD_SITE_FIRE）
newEntity{
    define_as = "CAMPFIRE_UPGRADED",
    name = "強化篝火",
    display = 'X', color_r=255, color_g=200, color_b=0,
    back_color = colors.DARK_RED,
    always_remember = true,

    camp_heal          = true,
    camp_heal_pct      = 0.10,  -- 治療 10% HP（普通篝火是 5%）
    camp_heal_cooldown = 5,     -- 冷卻縮短為 5 動作（普通是 10）
}

-- 據點儲物箱（建造後替換 BUILD_SITE_CHEST）
-- camp_chest 旗標：踩上按 > 開啟共享儲物 Dialog
newEntity{
    define_as = "CAMP_CHEST",
    name = "據點儲物箱",
    display = 'c', color_r=200, color_g=150, color_b=50,
    back_color = colors.DARK_UMBER,
    notice          = true,
    always_remember = true,

    camp_chest = true,   -- 旗標：由 Grid:on_move 分派儲物互動
}
```

### 擴充 `mod/class/Grid.lua`：農田提示 + 儲物箱互動

```lua
-- mod/class/Grid.lua（在 on_move 中追加）

function _M:on_move(x, y, who, forced)
    if forced then return end

    -- ① 移動投射傷害（原有）
    if who.move_project and next(who.move_project) then
        local DamageType = require "engine.DamageType"
        for typ, dam in pairs(who.move_project) do
            DamageType:get(typ).projector(who, x, y, typ, dam)
        end
    end

    -- ② 篝火治療（Tutorial 10）
    if self.camp_heal and who == game.player then
        self:_campfireHeal(x, y, who)
    end

    -- ③ 農田狀態提示（踩上時顯示當前狀態）
    if self.farm_interact and who == game.player then
        self:_farmStep(x, y, who)
    end

    -- ④ 儲物箱（踩上提示玩家可按 > 開啟）
    if self.camp_chest and who == game.player then
        game.logPlayer(who, "這是據點儲物箱。按 [>] 開啟存放物品。")
    end
end

-- ── 農田踩上提示 ─────────────────────────────────────────────
function _M:_farmStep(x, y, who)
    local fi = self.farm_interact
    if fi == "plant" then
        game.logPlayer(who,
            "這是空農田。按 [>] 種植草藥（需要：草藥種子 ×1）。")
    elseif fi == "check" then
        local cs = game.camp_state
        if cs and cs.farms then
            local farm = cs.farms[x .. "_" .. y]
            if farm and farm.turn_planted > 0 then
                local tpa     = game.energy_to_act / game.energy_per_tick
                local elapsed = game.turn - farm.turn_planted
                local needed  = farm.turns_to_grow * tpa
                local pct     = math.min(100, math.floor(elapsed / needed * 100))
                game.logPlayer(who, "農田生長進度：%d%%。按 [>] 查詢詳情。", pct)
                return
            end
        end
        game.logPlayer(who, "農田正在生長中。按 [>] 查詢進度。")
    elseif fi == "harvest" then
        game.logPlayer(who, "#LIGHT_GREEN#農田已成熟！按 [>] 收穫。")
    end
end
```

---
