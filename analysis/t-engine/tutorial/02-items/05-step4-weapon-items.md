建立物品定義檔。物品原型使用 `newEntity{...}` 語法（與 NPC 和地形相同）：

```lua
-- game/modules/hellodungeon/data/general/objects/weapons.lua

-- ============================================================
-- 武器基底原型
-- define_as：可被其他 newEntity 用 base = "BASE_WEAPON" 繼承
-- slot：對應 defineInventory 的 short_name → 裝備到 WEAPON 欄
-- ============================================================
newEntity{
    define_as = "BASE_WEAPON",
    type = "weapon", subtype = "sword",
    slot = "WEAPON",            -- 裝備到 WEAPON 槽
    display = "/",              -- 地圖上的字元顯示
    color = colors.SLATE,
    encumber = 2,               -- 揹包重量（目前未強制限制，但可自行實作）
    -- rarity 決定此物品在隨機生成時的出現機率
    -- 數字越大越罕見，沒有 rarity 的物品永遠不會隨機出現
    rarity = 5,
    desc = "一把近戰武器。",
}

-- ── 木劍（初級） ──────────────────────────────────────────
newEntity{ base = "BASE_WEAPON",
    name = "木劍",
    level_range = {1, 5},   -- 僅在 1~5 層隨機出現
    rarity = 3,             -- 比較常見
    cost = 5,               -- 商店售價（目前未用）
    -- wielder：裝備後套用到 Actor 的臨時加成
    -- 原理：ActorInventory:onWear() 呼叫 self:addTemporaryValue(k, v)
    --        ActorInventory:onTakeoff() 呼叫 self:removeTemporaryValue(k, id)
    wielder = {
        combat_dam = 3,     -- 傷害加成（Actor.combat_dam 會自動增加）
        combat_apr = 1,     -- 穿甲加成（需在 Combat.lua 中讀取）
    },
}

-- ── 鐵劍（中級） ──────────────────────────────────────────
newEntity{ base = "BASE_WEAPON",
    name = "鐵劍",
    level_range = {3, 10},
    rarity = 5,
    cost = 20,
    wielder = {
        combat_dam = 7,
        combat_apr = 2,
    },
}

-- ── 精鋼劍（高級） ────────────────────────────────────────
newEntity{ base = "BASE_WEAPON",
    name = "精鋼劍",
    level_range = {8, 20},
    rarity = 8,
    cost = 60,
    wielder = {
        combat_dam = 14,
        combat_apr = 4,
    },
}
```

**`wielder` 的工作原理**：

當玩家裝備武器時，`ActorInventory:onWear()` 被呼叫：

```lua
-- engine/interface/ActorInventory.lua (簡化版)
function _M:onWear(o, inven_id)
    o.wielded = {}
    o:check("on_wear", self, inven_id)   -- 呼叫物品的 on_wear 鉤子（若有）
    if o.wielder then
        for k, e in pairs(o.wielder) do
            -- addTemporaryValue 讓屬性可疊加、也可完整移除
            o.wielded[k] = self:addTemporaryValue(k, e)
        end
    end
end
```

`addTemporaryValue("combat_dam", 7)` 會讓 `self.combat_dam` 增加 7，並回傳一個移除用的 ID 存在 `o.wielded` 裡。取下武器時用這個 ID 精確移除加成，不會影響其他來源（例如 buff）。

---
