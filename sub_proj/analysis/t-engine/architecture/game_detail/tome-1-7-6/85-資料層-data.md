### 8.5 資料層 (data/)

#### 角色創建（birth/）

**選擇流程**：Campaign（世界）→ Difficulty → Permadeath → Race → Subrace → Sex → Class → Subclass

**描述符類型**：`world`、`difficulty`、`permadeath`、`race`、`subrace`、`sex`、`class`、`subclass`

**難度等級**：

| 難度 | 怪物等級 | 技能倍率 | 樓梯延遲 | 特殊 |
|------|---------|---------|---------|------|
| Easy | ×1 | ×1 | 0 | 無敵免疫、傷害-30%、治療+30% |
| Normal | ×1 | ×1 | 2 回合 | 無敵免疫 |
| Nightmare | ×1.25 | ×1.3 | 3 回合 | — |
| Insane | ×1.5+1 | ×1.7 | 5 回合 | — |
| Madness | ×2.5+2 | ×2.7 | 9 回合 | 生命×3、獵殺機制 |

**永久死亡模式**：Exploration（無限復活）、Adventure（多條命）、Roguelike（1 條命）

**職業分類**（12 大類，各含子職業）：

| 職業類 | 子職業 |
|--------|--------|
| 戰士 | Berserker、Bulwark、Archer、Brawler、Arcane Blade |
| 法師 | Alchemist、Archmage、Necromancer |
| 盜賊 | Rogue、Shadowblade、Marauder、Skirmisher |
| 天界 | Sun Paladin、Anorithil |
| 野性 | Summoner、Wyrmic、Oozemancer、Stone Warden |
| 心靈 | Mindslayer、Solipsist |
| 時空 | Chronomancer 系列 |
| 腐化 | Corruptor 系列 |
| 受詛 | Cursed 系列 |
| 冒險家 | Adventurer（全職業混合）|
| 無 / 教學 | 特殊用途 |

**種族**（8 種）：Human（Cornac/Higher）、Elf（Shalore/Thalore）、Dwarf、Halfling、Yeek、Giant、Undead（Ghoul/Skeleton）、Construct

**世界/戰役**：
- Maj'Eyal（主線）、Infinite Dungeon（無限下降）、The Arena（競技場）

#### 資源（resources.lua）

11 種資源池，各有獨立顏色、回復設定、AI 管理：

| 資源 | 特色 |
|------|------|
| Air | 窒息機制 |
| Stamina | 物理技能耗費 |
| Mana | 魔法施法（mana_pool 技能）|
| Equilibrium | `invert_values=true`（越高越不穩）|
| Vim | 惡魔能量，`restore_factor=0.8` |
| Positive/Negative | 善/惡能量，`restore_factor=0.4` |
| Hate | 狂暴者 |
| Paradox | 時空悖論，`invert_values=true` |
| Psi | 心靈能量 |
| Souls | 上限 10，不自動回復 |

#### 傷害類型（damage_types.lua）

含物理、火、冷、閃電、酸、毒、光、暗、時間等 40+ 傷害類型，各有獨立投射器與視覺顏色。

#### 陣營（factions.lua）

25+ 個陣營：Allied Kingdoms、Angolwen、Shalore、Thalore、Iron Throne、Orc Pride 系列、Sorcerers、Sher'Tul、Undead 等。

- 初始反應值由 CSV 矩陣定義（-100 到 100）
- `hostile_on_attack`：受攻擊後轉敵對

#### 技能分類（data/talents/）

13 個大類，200+ 個技能檔案：

| 類別 | 數量 | 說明 |
|------|------|------|
| `techniques/` | 40 | 物理戰鬥（combat-training、2h、dual、archery、shield 等）|
| `spells/` | 48 | 秘術魔法（fire、ice、air、stone、arcane、necromancy、temporal 等）|
| `celestial/` | 19 | 神聖力量（sun、light、chants、circles、guardian 等）|
| `psionic/` | 30 | 心靈能力（absorption、telekinetic、dreaming、solipsism 等）|
| `corruptions/` | — | 黑暗/腐化 |
| `chronomancy/` | — | 時間操縱 |
| `gifts/` | — | 野性恩賜/自然 |
| `cunning/` | — | 盜賊/潛行 |
| `cursed/` | — | 受詛/受苦 |
| `misc/` | — | 雜項 |
| `undeads/` | — | 不死生物特有 |
| `uber/` | — | 偉業技能（高階）|

**技能定義模式**：
```lua
newTalent{
    name="Fireball", type={"spells/fire",1}, mode="activated",
    points=5, cooldown=10, mana=20, range=8,
    target=function(self,t) ... end,
    action=function(self,t) ... end,
    tactical={attackarea=2, escape=1},  -- AI 戰術評分
    getDamage=function(self,t) ... end, -- 縮放函數
    info=function(self,t) ... end,      -- 提示文字
}
```

技能縮放函數：`combatTalentScale`、`combatTalentLimit`、`combatTalentSpellDamage`

---

