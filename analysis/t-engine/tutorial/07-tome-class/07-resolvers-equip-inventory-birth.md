這兩個 resolver 是 ToME 特有的，**專門用於角色創建時**的裝備初始化：

```lua
-- equipbirth：嘗試自動裝備到適當槽位
equipment = resolvers.equipbirth{ id=true,   -- id=true：物品自動鑑定
    -- 每個表格是一個物品篩選條件
    {
        type = "weapon", subtype="staff",
        name = "elm staff",      -- 精確名稱匹配
        autoreq = true,          -- 自動提升屬性/等級以滿足需求（角色創建常用）
        ego_chance = -1000,      -- 不生成附魔（確保是基礎版）
        ignore_material_restriction = true,  -- 忽略材料等級限制（equipbirth 默認啟用）
    },
    -- 也可以用更寬鬆的條件（讓系統隨機選）
    {
        type = "armor",
        subtype = "cloth",
        autoreq = true,
        ego_chance = -1000,
    },
},

-- inventorybirth：放入揹包（不裝備）
inventory = resolvers.inventorybirth{ id=true,
    {type="potion", subtype="potion"},  -- 任意藥水
    {type="potion", defined="POTION_REGENERATION"},  -- 精確指定物品 define_as
},
```

**`resolvers.equip` vs `resolvers.equipbirth` 的差異**：

| 欄位 | equip（NPC 用） | equipbirth（出生用） |
|------|----------------|---------------------|
| 材料限制 | 遵守 zone 的 material_level | 忽略（可以在任何材料等級） |
| 使用場景 | NPC 的 resolvers.equip{} | 角色創建的 copy.equipment |
| autoreq | 不常用 | 推薦使用，確保能穿上 |

---
