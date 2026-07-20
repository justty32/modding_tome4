## 18. 支援系統

### Quest.lua — 任務系統

**狀態機**：`PENDING(0)` → `COMPLETED(1)` → `DONE(100)` 或 `FAILED(101)`

```lua
local quest = Quest.new({
    name = "Kill the Dragon",
    on_grant = function(self, who) ... end,
    on_status_change = function(self, who, status, sub) ... end,
}, player)
quest:setSubCompleted("find_lair")
quest:setCompleted()
```

### Faction.lua — 陣營系統

- `Faction:add(t)` — 定義陣營（含初始反應表）
- `Faction:factionReaction(f1, f2)` — 查詢當前反應（-100 到 100）
- `Faction:setFactionReaction(f1, f2, reaction, mutual)` — 動態修改
- 預定義：`"players"` 與 `"enemies"` 陣營

### Store.lua — 商店系統

繼承 Entity + ActorInventory，增加：
- `loadup(level, zone)` — 從 zone 實體生成商品
- `tryBuy(who, o, item, nb)` / `onBuy(...)` — 模板方法購買流程
- `trySell(who, o, item, nb)` / `onSell(...)` — 模板方法販售流程
- `canRestock()` — 檢查補貨延遲
- `interact(who, name)` — 開啟商店對話框

### Chat.lua — NPC 對話系統

- 支援兩種格式：傳統 Lua 腳本 + 新版 JSON（視覺化編輯器）
- `replace(text)` — 解析 `@placeholder@` 插值
- `switchNPC(npc, pan_camera)` — 對話中切換 NPC
- `chatFormatActions(nodes, answer, ...)` — 遞迴解析 JSON 動作/條件鏈
- 支援唯一條件追蹤（每玩家/NPC/遊戲狀態）

### Birther.lua — 角色創建嚮導

- 多步驟精靈（base → role → …）
- `loadDefinition(file, env)` — 載入描述定義
- `randomSelect()` — 隨機選擇；`quickBirth()` — 預設選擇
- `apply(self_contained)` — 將所有選擇的 `copy`/`stats`/`talents` 累加到角色
- 支援 a-z, A-Z 快捷鍵

### Autolevel.lua — NPC 自動升級

- `registerScheme(t)` — 註冊升級方案
- `autoLevel(actor)` — 執行 `actor.autolevel` 指定的方案

### HighScores.lua — 高分榜

- `registerScore(world, details)` — 儲存死亡角色分數
- `noteLivingScore(world, name, details)` — 追蹤存活角色
- `createHighScoreTable(world, formatters)` — 生成格式化分數字串
- 透過 `profile:saveModuleProfile()` 持久化

### NameGenerator.lua — 音節名稱生成

```
$s=起始音節, $m=中間, $e=結尾, $v=母音, $c=子音
$35m = 35% 機率加中間音節
```

使用 LPEG 模式替換；支援重複抑制

### NameGenerator2.lua — 文法名稱生成

- 預訓練音節組合文法（syllable transition 機率）
- `generate(no_repeat, min_syl, max_syl)` — 帶音節數限制的生成
- 累積機率分布做加權隨機；禁詞列表避免重複

### I18N.lua — 國際化系統

```lua
I18N:loadLocale("/data/locales/engine/zh.lua")
I18N:setLocale("zh")
_t"Hello World"           -- 取得翻譯字串
_t("Hello %s", name)      -- 帶參數
string.tformat(s, ...)    -- 格式化（支援參數重排序）
```

- 翻譯資料：`{["Hello World"] = "你好世界"}`
- tag 系統分類翻譯（"entity name"、"tformat" 等）
- `dumpUnknowns()` — 匯出未翻譯字串

### colors.lua — 顏色系統

- 60+ 命名顏色（BLACK, WHITE, RED, GOLD, DARK_KHAKI …）
- 雙向登錄：`colors`（全定義）+ `r_colors`（反向查找）
- `colors.simple(c)`、`colors.simple1(c, a)`、`colors.hex1(hex)` — 顏色工具
- `colors.lerp(a, b, x)` — 線性插值

### utils.lua — 全局工具庫

此檔案向全局命名空間注入大量輔助函數：

**math.\*** （10+ 函數）：
- `math.decimals(v, nb)` — 四捨五入到 N 小數位
- `math.round(v, mult, num)` — 捨入到倍數
- `math.scale(i, imin, imax, dmin, dmax)` — 線性插值
- `math.boundscale(...)` — 有界插值

**string.\*** （30+ 函數）：
- `string.limit_decimals(num, sig_figs)` — 精度格式化
- `string.trim(str)` — 去除空白
- `string.a_an(str)` — 加冠詞 "a"/"an"
- `string.he_she(actor)` — 依 `actor.female` 回傳代名詞
- `string.capitalize(str)` / `string.bookCapitalize(str)` — 大寫轉換
- `string.noun_sub(str, type, noun)` — 替換 `@type@` 佔位符
- `string.split(str, char)` — 字串分割
- `string.splitAtSize(bstr, size, font)` — 依像素寬自動換行
- `string.toTString(str)` — 轉換為 TString 富文本類型
- `string.removeColorCodes(str)` — 移除顏色標記
- `string.levenshtein_distance(str1, str2)` — 編輯距離

**table.\*** （50+ 函數）：
- `table.clone(tbl, deep, k_skip)` — 深/淺拷貝
- `table.merge(dst, src, deep)` — 合併（覆寫）
- `table.mergeAdd(dst, src, deep)` — 合併（數字相加）
- `table.ruleMergeAppendAdd(dst, src, rules)` — 規則驅動合併（ego 系統使用）
- `table.keys(t)` / `table.values(t)` — 提取鍵/值
- `table.count(t)` — 計數（支援 pairs）
- `table.weak_keys(t)` / `table.weak_values(t)` — 弱引用 table 建立
- `table.has(t, ...)` / `table.get(t, ...)` / `table.set(t, ...)` — 巢狀存取
- `table.shuffle(t)` — 隨機排列
- `table.applyRules(dst, src, rules, state)` — 複雜規則合併
- `table.equivalence(t1, t2, recurse)` — 深度相等比較

**util.\*** （40+ 函數）：
- `util.bound(i, min, max)` — 夾值；`util.boundWrap(i, min, max)` — 循環夾值
- `util.getval(val, ...)` — 取值（函數則呼叫，否則直接回傳）
- `util.lerp(a, b, x)` — 線性插值
- `util.dirToCoord(dir, sx, sy)` — 方向轉 dx/dy
- `util.coordToDir(dx, dy, sx, sy)` — 座標轉方向
- `util.getDir(x1, y1, x2, y2)` — 兩點間方向
- `util.adjacentCoords(x, y, no_diagonals)` — 取相鄰格
- `util.findFreeGrid(sx, sy, radius, block, what, checker)` — 找空格子
- `util.loadfilemods(file, env)` — 帶 addon 覆蓋載入
- `util.uuid()` — 生成 UUID
- `util.showMainMenu(no_reboot, ...)` — 顯示/重啟主選單
- `util.send_error_backtrace(msg)` — 帶 call stack 的錯誤記錄

**迭代器**：
- `ipairsclone(t)` / `pairsclone(t)` / `ripairsclone(t)` — 拷貝後迭代（迭代中修改安全）
- `ripairs(t)` — 反向 ipairs
- `ipairs_value(t)` / `ripairs_value(t)` — 先回傳值的迭代器

### version.lua — 版本管理

```lua
engine.version_check(v)          -- 比較 v 與引擎版本
engine.version_compare(v, ev)    -- 比較兩個版本 table
engine.version_nearly_same(v, ev) -- 檢查 major/minor 相容性
engine.version_from_string(s)    -- 解析 "x.y.z" 或 "name-x.y.z"
```

回傳值：`"newer"`, `"lower"`, `"same"`, `"different engine"`, `"bad C core"`

---

## 19. 關鍵設計模式總結

| 模式 | 應用 |
|------|------|
| **Mixin 繼承** | `engine/interface/` 所有介面，Actor 按需組合 |
| **Data-driven 定義** | `newTalent`, `newEffect`, `newDamageType` — 資料與邏輯同在定義 table |
| **兩階段初始化** | Entity define（原型）→ resolve（實例），支援延遲亂數計算 |
| **命名行為** | AI 系統以字串 key 組合行為，可在運行時動態切換 |
| **弱引用追蹤** | `__uids`, `entities`, `ai_target`, FOV actors，讓 GC 自然清理死亡實體 |
| **每物件存一檔** | 存檔用 zip 內多 Lua 檔，跨物件引用用 hash 連結，天然支援 graph 結構 |
| **Hook 系統** | 模組可在不修改引擎的情況下，在任何 hook 點注入邏輯 |
| **延遲載入** | Shader、存檔物件首次使用時才真正初始化 |
| **動態函數編譯** | Map 的實體檢查函數、ActorResource 的回復函數，按需編譯提升效能 |
| **臨時值 ID 追蹤** | 所有加成透過 ID 可逆撤銷（裝備、技能、效果），不需手動管理 |
| **協程目標選擇** | GameTargeting / ActorTalents 用協程暫停等待玩家輸入，避免回呼地獄 |
| **模板方法** | Store 的 tryBuy/onBuy、PlayerRest 的 restCheck()，預留覆寫點 |
| **Registry Pattern** | DamageType, Faction, WorldAchievements 維護全域定義登錄表 |
| **LRU Cache** | Zone 最近造訪層快取（`enableLastPersistZones`），減少磁碟讀寫 |
| **概率生成系統** | Zone 的 `computeRarities()`，稀有度 × 深度差的加權生成 |
