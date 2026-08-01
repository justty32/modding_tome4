```lua
-- game/modules/hellodungeon/data/general/objects/potions.lua

-- ============================================================
-- 藥水基底
-- stacking = true：相同藥水在揹包中自動堆疊
-- use_simple：定義「使用」效果（按 a 使用物品時觸發）
-- ============================================================
newEntity{
    define_as = "BASE_POTION",
    type = "potion", subtype = "potion",
    display = "!", color = colors.VIOLET,
    encumber = 0.2,
    stacking = true,    -- 可堆疊：多個「治癒藥水」合為一格顯示數量
    rarity = 4,
    desc = "神祕的魔法藥水。",
}

-- ── 治癒藥水 ──────────────────────────────────────────────
newEntity{ base = "BASE_POTION",
    name = "治癒藥水",
    color = colors.RED,
    level_range = {1, 50},
    rarity = 3,
    cost = 10,
    -- use_simple：最基本的使用定義
    -- name：動作描述（顯示在日誌中）
    -- use：回傳一個 function，實際執行使用效果
    use_simple = {
        name = "喝下治癒藥水",
        use = function(self, who)
            local heal = 20 + rng.range(1, 10)
            who:heal(heal, who)
            game.logSeen(who, "%s 喝下治癒藥水，恢復了 %d 點生命！",
                who:getName():capitalize(), heal)
            -- 回傳 true = 使用成功（物品會被消耗掉）
            -- 回傳 false = 使用失敗（物品不消耗）
            return {used=true, id=true}
        end
    },
}

-- ── 力量藥水 ──────────────────────────────────────────────
newEntity{ base = "BASE_POTION",
    name = "力量藥水",
    color = colors.ORANGE,
    level_range = {3, 50},
    rarity = 6,
    cost = 25,
    use_simple = {
        name = "喝下力量藥水",
        use = function(self, who)
            -- 臨時增加 5 點力量，持續 20 回合
            -- 使用 ActorTemporaryEffects 的持續效果系統
            -- （需要在 timed_effects.lua 定義 EFF_STRENGTH_BOOST）
            game.logSeen(who, "%s 喝下力量藥水，力量暫時提升！",
                who:getName():capitalize())
            -- 這裡改用直接增加屬性作為示範（更簡單）
            local id = who:addTemporaryValue("combat_dam", 5)
            -- 20 回合後移除
            who:setEffect(who.EFF_STRENGTH_BOOST, 20, {id=id})
            return {used=true, id=true}
        end
    },
}
```

**`use_simple` vs `use`**：

| 欄位 | 說明 |
|------|------|
| `use_simple.name` | 動作選單顯示的文字 |
| `use_simple.use(self, who)` | `self`=物品, `who`=使用者；回傳 `{used=true}` 消耗物品 |
| `use` | 完整版（可自訂對話框、目標選擇），進階用法 |

> **注意**：力量藥水範例用到了 `EFF_STRENGTH_BOOST`，如果你的 `timed_effects.lua` 沒有定義這個效果，執行時會報錯。可以先只保留治癒藥水測試，或在 `timed_effects.lua` 中補充定義（見附錄）。

---
