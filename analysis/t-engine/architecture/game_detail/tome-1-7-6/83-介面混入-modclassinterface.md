### 8.3 介面混入 (mod/class/interface/)

#### Combat.lua（2844 行）— 核心戰鬥系統

**主要方法**：

| 方法 | 說明 |
|------|------|
| `bumpInto(target, x, y)` | 碰撞分派（對話/攻擊/位移）|
| `attackTarget(target, damtype, mult, ...)` | 攻擊入口 |
| `attackTargetWith(target, weapon, ...)` | 單武器攻擊邏輯 |
| `attackTargetHitProcs(...)` | 命中後特效處理（特效/爆擊/閃避）|
| `combatAttack()` / `combatDefense()` | 命中/閃避計算 |
| `combatDamage()` / `combatArmor()` / `combatAPR()` | 傷害/護甲/穿透 |
| `combatPhysicalpower()` / `combatSpellpower()` / `combatMindpower()` | 三層施法力 |
| `physicalCrit()` / `spellCrit()` / `mindCrit()` | 爆擊計算 |
| `combatTalentScale(t, min, max)` | 線性技能縮放 |
| `combatTalentLimit(t, limit, min, max)` | 有上限技能縮放 |
| `grappleSizeCheck()` / `startGrapple()` | 擒抱機制 |
| `buildCombo()` / `getCombo()` | 連擊系統 |

**設計特點**：
- 階層命中 vs 防禦系統（`getTierDiff()`、`checkHit()`）
- 護甲硬韌度系統（減少護甲穿透影響）
- 武器類型訓練路徑
- 隊友受攻擊時的救援機制

#### ActorLife.lua — 生命/死亡

- `oktodie()`：檢查存活機制（T_CAUTERIZE 技能、callback）
- 殺手記功系統（`on_kill`）
- NPC 雙重死亡條件

#### ActorAI.lua（1825 行）— AI 決策

**戰術系統**（ToME 核心 AI）：

```
三步戰術評分：
1. 計算每個技能的 TACTIC WEIGHT（via aiTalentTactics()）
2. 計算各戰術的 WANT VALUE（AI 特定）
3. FINAL TACTICAL SCORE = sum(WEIGHT × WANT)，依技能等級/速度調整
```

**戰術分類**（`AI_TACTICS` 係數表）：

| 有害 | 有益 |
|------|------|
| attackarea, attack, closein | cure, heal, buff |
| escape, surrounded, disable | defend, protect, feedback |
| attackall | special, ammo |

**額外功能**：
- `aiResourceAction()`：資源補充決策
- `aiHealingAction()`：治療目標選擇
- `aiGridDamage()` / `aiGridHazard()`：環境評估
- `aiFindSafeGrid()`：安全位置尋路
- Lite/夜視/增強感知支援的視野判斷

#### ActorInscriptions.lua — 銘文系統

- 插槽式銘文（Rune/Infusion/Talon）管理
- `max_inscriptions`：插槽數（預設 3）
- 同類型最多 2 個銘文限制
- 屬性縮放（`use_stat_mod`、`use_any_stat`）
- 替換時保留快捷鍵

#### Archery.lua（878 行）— 弓箭遠程戰鬥

| 方法 | 說明 |
|------|------|
| `archeryAcquireTargets(tg, params)` | 目標+資源檢查 |
| `archeryShoot(targets, talent, tg, params)` | 投射物建立 |
| `hasArcheryWeapon(type, quickset)` | 弓箭裝備檢查 |
| `hasAmmo(type, quickset)` | 彈藥驗證 |
| `reloadRate()` / `reload()` | 換彈速度/手動換彈 |

支援：主手+副手+Psionic Focus 射手、無限彈藥屬性、多重射擊、彈藥耗盡追蹤

#### ActorObjectUse.lua — 物品使用AI整合

將物品能力包裝為技能，讓 NPC AI 能評估並使用物品：
- 支援三種物品能力類型：`use_power`、`use_simple`、`use_talent`
- `no_npc_use` / `allow_npc_use` 旗標控制 AI 使用權
- 戰術權重系統整合

#### ActorPartyQuest.lua — 隊伍任務管理

所有任務事件委派給主玩家：
- `grantQuest(quest, args)` / `setQuestStatus()` / `hasQuest()` / `isQuestStatus()`

#### PartyDeath.lua — 隊伍死亡處理

- 非主要成員死亡時切換目前玩家
- 遊戲結束判定（無合適玩家）
- Easy 模式多命、在線 profile 提交

#### PartyIngredients.lua — 食材/材料系統

- 食材定義與收集追蹤（含 INFINITY 常數支援）
- `collectIngredient(id, nb)` / `useIngredient(id, nb)` / `hasIngredient(id, nb)`

#### PartyLore.lua — 史料系統

- 史料條目發現與顯示（富文本：`[i]`、`[b]`、`[u]`）
- 模板支援（slt2 渲染）
- 發現時打斷玩家休息/奔跑
- 史料貢獻角色統計

#### PlayerStats.lua — 角色統計追蹤

- 唯一角色識別符（世界/種族/職業/難度/永久死亡）
- Profile 持久化：死亡、唯一怪擊殺、神器收集、護送任務

#### TooltipsData.lua — 提示框資料

537 行靜態常數，定義所有 UI 幫助文字：
- 資源（黃金、生命、耐力、魔力、Vim 等）
- 技能（銘文、偉業、物品技能、主動/持續/被動）
- 速度（全局/移動/施法/攻擊/心靈）
- 屬性（力量/敏捷/體質/魔法/意志/狡詐）
- 戰鬥（命中/攻擊力/傷害/護甲/穿透/爆擊）
- 防禦（疲勞/護甲硬韌度/爆擊減免/防禦/抗性）

---

