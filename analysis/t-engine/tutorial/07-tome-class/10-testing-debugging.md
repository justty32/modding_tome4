### 10.1 在角色創建中快速測試

啟動遊戲進入角色創建，如果職業不出現：

1. 確認 `init.lua` 有 `hooks = true`
2. 確認 `hooks/load.lua` 的 hook 名稱是 `"ToME:load"`（不是 `"ToME:run"`）
3. 確認 `Birther:loadDefinition` 的路徑正確（`/data/birth/classes/sanguinist.lua`，使用虛擬路徑）

### 10.2 技能不出現在技能 UI

```lua
-- 在遊戲中進入 debug 模式，呼叫以下查詢：
-- （在 Lua console 中，按 F12 或使用 ~ 鍵）
print(ActorTalents.talents_types_def["blood/sanguination"])
-- 應該顯示技能類型的定義表格
-- 如果是 nil，表示 loadDefinition 沒有成功執行
```

### 10.3 技能效果驗證

建立一個測試角色，在 debug 模式下手動設定技能等級：

```lua
-- 在 Lua console：
game.player:learnTalent(game.player.T_BLOOD_DRAIN, true, 5)
game.player:setTalentTypeMastery("blood/sanguination", 1.5)
```

### 10.4 require 問題

如果玩家無法加點（技能顯示「需求不足」），在技能的 `require` 中加入 print：

```lua
require = {
    stat = { mag = function(level)
        local v = 10 + level * 4
        print("[DEBUG] mag require for level", level, ":", v, "current:", game and game.player and game.player:getStat("mag"))
        return v
    end },
},
```

---
