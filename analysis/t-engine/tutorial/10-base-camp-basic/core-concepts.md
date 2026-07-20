### `persistent = "zone"` 如何運作

TE4 的 Zone 有四種持久化模式：

| 值 | 行為 |
|----|------|
| `false`（預設） | 離開即重新生成，不保留任何狀態 |
| `"memory"` | 存在 `game.memory_levels` 中，存檔後消失 |
| `"zone"` | 整個 Zone 以 `.teaz` 檔儲存，下次進入從檔案載入 |
| `true` | 每一層都獨立存檔 |

據點使用 `"zone"`：Zone 離開時把每一層的 Level 物件存入 `self.memory_levels[level_num]`，並在 Zone 存檔時寫入磁碟。下次 `zone:getLevel()` 時優先從 `memory_levels` 取出，而不是重新生成。

**結果**：你在據點放下的箱子、NPC 的當前狀態，下次進入都還在。

### Static Map 產生器

靜態地圖由一個 Lua 檔描述。產生器讀取這個檔案並把 ASCII 字元對映到具體的 Grid / NPC / Object 實體：

```lua
defineTile(char, grid_define_as, object_define_as, actor_define_as, trap_define_as)
-- 後三個參數可傳 nil 表示「不放置」
return [[
  ASCII地圖字串
]]
```

### 旗標驅動行為 vs. 函式欄位

TE4 的序列化系統**無法序列化匿名函式**。如果在 `newEntity{}` 裡直接寫 `on_move = function(...) end`，存檔重載後這個函式將遺失。

正確模式：
- **資料放在實體欄位**（`camp_heal = true`）
- **行為放在有名稱的類別方法**（`Grid:on_move()` 根據旗標分派）

---
