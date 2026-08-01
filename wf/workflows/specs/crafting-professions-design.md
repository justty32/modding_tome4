# 設計方案：生產職業系統（鍛造／鑲嵌／附魔／釀造）

← [specs](README.md)｜討論日期 2026-08-01

```text
Done when: 哪些底層白拿、哪些要自己寫講清楚；職業之間怎麼隔離有機制答案；
           規模與分期可獨立驗；與另兩個大構想的關係寫明
```

> 路徑代號 `E` / `M` / `D` 見 [docs/knowledge/README.md](../../../docs/knowledge/README.md)。
> 完整引擎調查在 [crafting-and-imbue.md](../../../docs/knowledge/crafting-and-imbue.md)，
> 本文件只做設計決策，不重複行號考據。

## 1. 目標

參考原版蒸汽科技（Embers of Rage DLC）的裝置製作，做出 WoW 式的多套生產職業：
鍛造、鑲嵌、附魔、釀造、採集……

## 2. 最重要的一件事：一半的底層在基礎遊戲裡

| 層 | 在哪 | 沒 DLC 能用？ |
|---|---|---|
| **裝配槽**（把東西裝到裝備上＝鑲嵌／附魔） | `M/mod/class/Object.lua:2565-2577`、`M/mod/class/Actor.lua:8168-8300` | ✅ **白拿** |
| **材料倉庫**（reagent bank，材料不佔背包） | `M/mod/class/interface/PartyIngredients.lua` | ✅ **白拿** |
| **背包分頁／角色卡顯示** | `M/mod/load.lua:256`、`CharacterSheet.lua:157`、`ShowEquipInven.lua:63` | ✅ **白拿**（只要 actor 有 `can_tinker`）|
| 配方系統（學圖紙、產出） | `D/tome-orcs/.../PartyTinker.lua`（**175 行**）| ❌ DLC，但短到可以自己重寫 |
| 製作 UI | `D/tome-orcs/.../CreateTinker.lua`（284 行）| ❌ 同上 |

**所以「不能依賴玩家買了 DLC」的代價只有約 460 行**，而且 DLC 那份是 GPL，結構可照抄。

## 3. 架構決策

### 3.1 每個生產職業 = 一種 `is_tinker` ★

這是本設計的核心，而且是**引擎原生支援的隔離機制**：

```lua
-- M/mod/class/Actor.lua:8169-8170
if not self.can_tinker then return nil, "can not use attachments" end
if not self.can_tinker[tinker.is_tinker] then return nil, "can not use attachments of this type" end
```

`can_tinker` 是**任意 key 的表**，由天賦的 `on_learn` 掛上去
（`D/tome-orcs/data/talents/steam/other.lua:128-135`）。於是：

| 職業 | 裝置種類 | 學會後 |
|---|---|---|
| 符文鍛造 | `is_tinker = "runeforge"` | `can_tinker.runeforge = 1` |
| 寶石鑲嵌 | `is_tinker = "gemcraft"` | `can_tinker.gemcraft = 1` |
| 附魔 | `is_tinker = "enchant"` | `can_tinker.enchant = 1` |

彼此**互不干擾**，也不會誤裝到蒸汽零件上。不用自己設計隔離機制，
也不用擔心與裝了 DLC 的玩家打架。

### 3.2 材料走 `PartyIngredients`，不要用背包

`collectIngredient` / `hasIngredient` / `useIngredient`，掛在 **party 上不是 actor**。
材料不佔背包格——這正是 WoW 的手感，跟現有 `tome-crafting` 的「掃背包湊材料」不是同一個層次。

`min = INFINITY` 表示「一旦取得就永久擁有」，很適合拿來存**已學會的知識**（配方、圖紙），
不只是物料。

### 3.3 配方層自己寫，格式照抄 `newRecipe`

```lua
newRecipe{ id = ..., name = ..., desc = ..., icon = ...,
  base_ml = 1, max_ml = 5,              -- 材質等級上下限，一個配方自然長出五階產物
  talents = { T_SMITH = 2 },            -- 天賦等級門檻
  ingredients = { LUMP_ORE = 7 },       -- 吃材料倉庫
  items = { ... },                      -- 吃背包裡的實體物品
  special = {{desc=..., cond=fn}},      -- 任意條件
  create = function(tdef, party, actor, ml, silent, onend) ... end,  -- 自訂產出
}
```

`ml` 會接在 id 後面當後綴查找（`ING..ml` 找不到才退回 `ING`）——這是 tier 分級的實作方式。
沒給 `create` 就走預設路徑（按 `"TINKER_"..id..ml` 從物品清單 `makeEntityByName`）。

### 3.4 美術成本接近零

- **裝配加成**用 `object_tinker` 表，不需要新貼圖。
- **產出的裝備**用 `resolvers.moddable_tile("<27 種 slot 之一>")` → 身上疊圖白拿，還自動五階。
- **背包圖示**一張 64×64。
- **ego 詞綴完全不碰貼圖** → 新增詞綴美術成本 0。

細節見 [races-and-tiles.md §3](../../../docs/knowledge/races-and-tiles.md)、
[items-and-egos.md](../../../docs/knowledge/items-and-egos.md)。

## 4. WoW 職業對照與現成度

| WoW | 對應 | 現成度 |
|---|---|---|
| 附魔 / 鑲嵌 | 裝配槽（`object_tinker` 加成） | 底層全有，只要寫裝置內容 |
| 鍛造（打造裝備） | `create` 自訂函式 | 有完整範本：`STEAMSAW`（`D/tome-orcs/data/tinkers/smith.lua:3-45`）——**吃掉一把武器改造成另一把，還保留原 ego** |
| 煉金 / 釀造（消耗品） | 預設產出路徑，不必寫 `create` | 最簡單 |
| 採集（礦、草藥） | `collectIngredient` + zone 物件 | 底層有，採集點要自己做 |
| 學配方 | 圖紙物品 + `learnTinker`（`schematics.lua:21-61` 有 `use_simple` 讀了就學、`on_prepickup` 不重複撿、`random_schematic` 自動進掉落池）| 有範本 |
| 專精分支 | `talents` 門檻 + `can_tinker` 種類 | 有 |

## 5. 五個坑（都已複驗）

1. **一件裝備只能裝一個裝置**（`Object.lua:2574`）。要多槽位得 superload。
2. `object_tinker` 是 `addTemporaryValue`，卸下靠 `oldo.tinkered` 記錄的 id 還原
   （`Actor.lua:8191-8197`）。**自己寫類似機制務必成對**，否則加成永久疊加。
3. 裝配預設**消耗一個回合**（`Actor.lua:8275-8278`），除非 actor 有 `free_tinker_attach`。
4. `PartyTinker.lua:152,156` 留著 DarkGod 的 debug `print`（`"!!aazdazdazd!!!"`）——照抄時記得刪。
5. 材料倉庫在 **party**，不是 actor。單人也一樣走 `game.party:`。

## 6. 分期

| 期 | 內容 | 為什麼這個順序 |
|---|---|---|
| **P0 一個職業垂直切片** | 選**釀造**（最簡單，走預設產出路徑）：材料定義、5–8 個配方、圖紙物品、製作 UI | UI 是最大的未知數，用最簡單的職業把它做出來 |
| **P1 裝配槽職業** | 加**鑲嵌**：`is_tinker="gemcraft"`、裝置物件、`object_tinker` 加成 | 驗證 §3.1 的隔離機制真的成立（兩種 tinker 並存不打架）|
| **P2 採集** | 礦脈／草叢 zone 物件 → `collectIngredient` | 有了兩個消費端才知道要產哪些材料 |
| **P3 鍛造** | `create` 自訂函式，抄 `STEAMSAW` 的「吃掉舊武器產新武器、保留 ego」 | 最複雜，放最後 |
| **P4 內容量產** | 配方擴到各職業各 20–30 條 | 資料驅動後可交給 pi + deepseek |

**P0 要驗透的三件事**：

1. 存檔往返：`party.ingredients` 與已學配方讀檔後還在。
2. 製作 UI 能真的做出東西，且材料正確扣除（`useIngredient` 回 false 時不可以還是產出）。
3. 沒裝 DLC 的環境完全正常（我們的 175 行配方層不能意外依賴 `PartyTinker`）。

## 7. 與另外兩個構想的關係

見 [orario-complete-design.md §8](orario-complete-design.md)。三者底層共用：

- 本系統的 `PartyIngredients` ＝ 歐拉麗的**魔石經濟**。
- 本系統的「學配方」＝ [生長式天賦](organic-talents-design.md) 的**節點長出來**
  （兩者都可以是 `__show_special_talents`，也可以各走各的）。

**要不要合併是使用者要拍板的第一題。** 本文件先假設「各做各的」，
若決定合併，§3.3 的配方層應該改成生長式天賦的一個 source。

## 8. 待使用者決定

1. 先做哪個職業？（§6 建議釀造，理由是 UI 風險最低）
2. 生產職業是**天賦樹**（佔天賦點）還是**獨立系統**（不佔點，靠跑腿解鎖）？
3. 要不要與既有的 `tome-crafting` addon 合併／取代？那個是舊的「掃背包湊材料」版本。
4. 配方數量級：每職業 10 條夠玩，還是要 30+ 才有 WoW 感？

## 9. 產出分工（依 [agent-driving](../agent-driving/README.md)）

| 工作 | 交給誰 |
|---|---|
| 175 行配方層 ＋ 製作 UI | 主 agent（機制敏感，且 UI 細節多）|
| 配方／材料／裝置資料列 | pi + deepseek（格式固定，量大）|
| 圖紙、材料、裝置圖示 | `agy` cli，**送使用者肉眼審核** |
| 中文文案 | **一律使用者審** |
