### 1.2 物品定義 (objects/)

共 **60+ 個物品定義檔案**，按類型組織。

#### 武器類

| 檔案 | 武器類型 |
|------|---------|
| `swords.lua` | 單手劍 |
| `axes.lua` | 單手斧 |
| `maces.lua` | 單手棒錘 |
| `knifes.lua` | 匕首/短刀 |
| `whips.lua` | 鞭子 |
| `polearms.lua` | 長柄武器 |
| `2hswords.lua` / `2haxes.lua` / `2hmaces.lua` / `2htridents.lua` | 雙手武器 |
| `bows.lua` | 弓 |
| `slings.lua` | 投石器 |
| `digger.lua` | 挖掘工具 |
| `staves.lua` | 魔杖（法師專用）|
| `mindstars.lua` | 心靈星（心靈師專用）|
| `totems.lua` | 圖騰（召喚師專用）|

#### 防具類

| 檔案 | 防具位置 |
|------|---------|
| `cloth-armors.lua` | 布甲（法袍）|
| `light-armors.lua` | 輕甲（皮革）|
| `heavy-armors.lua` | 重甲（鎖甲）|
| `massive-armors.lua` | 板甲（全身甲）|
| `helms.lua` | 頭盔 |
| `leather-caps.lua` | 皮革帽 |
| `leather-boots.lua` | 皮革靴 |
| `heavy-boots.lua` | 重型靴 |
| `gauntlets.lua` | 板甲手套 |
| `gloves.lua` | 皮革手套 |
| `shields.lua` | 盾牌 |
| `leather-belt.lua` | 腰帶 |
| `jewelry.lua` | 珠寶（戒指/項鍊）|
| `lites.lua` | 光源（火把/燈籠/符文石）|

#### 消耗品

| 檔案 | 說明 |
|------|------|
| `potions.lua` | 藥水（治療/屬性/特效）|
| `scrolls.lua` | 卷軸（傳送/辨識/地圖）|
| `rods.lua` | 法杖（可充能的魔法道具）|
| `wands.lua` | 魔棒（可消耗的魔法道具）|

#### 神器（Artifacts）

| 檔案 | 大小 | 說明 |
|------|------|------|
| `world-artifacts.lua` | 313KB（最大）| 主要世界傳奇神器（數百件）|
| `world-artifacts-maj-eyal.lua` | 47KB | Maj'Eyal 地區神器 |
| `world-artifacts-far-east.lua` | 21KB | 遠東地區神器 |
| `boss-artifacts.lua` | 8KB | 通用 Boss 掉落神器 |
| `boss-artifacts-maj-eyal.lua` | 67KB | Maj'Eyal Boss 神器 |
| `boss-artifacts-far-east.lua` | 21KB | 遠東 Boss 神器 |
| `brotherhood-artifacts.lua` | 13KB | 煉金士兄弟會神器 |
| `quest-artifacts.lua` | 17KB | 任務關鍵神器 |
| `special-artifacts.lua` | 4KB | 特殊機制神器 |

#### Ego 系統（物品詞綴）

`egos/` 目錄包含物品詞綴定義：
- **前綴 ego**（如 「燃燒的」、「冰冷的」）：修改物品基礎屬性
- **後綴 ego**（如 「敏捷之」、「力量之」）：添加屬性加成
- **特殊 ego**：`special_on_hit`、`talent_on_hit`、`on_block` 等特殊效果

```lua
-- ego 定義範例
newEntity{
    power_source = {arcane=true},
    name = _t"of striking",
    keywords = {striking=true},
    level_range = {1, 50},
    rarity = 10,
    wielder = {
        combat_atk = resolvers.mbonus(12, 5),
    },
}
```

#### 物品辨識系統

- `unided_name`：未辨識時的名稱（如 "red potion"）
- `desc`：辨識後顯示的說明
- `identified`：是否已辨識（武器/防具預設為 true，藥水/卷軸預設為 false）

#### 區域性物品

- `tome_drops`：控制物品在哪些情境出現（`"Maj'Eyal"`, `"Far East"` 等）
- `level_range`：物品出現的等級範圍
- `rarity`：越高越少見

#### 隨機神器（Randart）

`random-artifacts.lua` 定義隨機神器的生成規則：
- 基於基礎物品加上隨機 ego 與屬性
- `GameState:generateRandart(data)` 呼叫
- 強大神器系統（Randart Power Budget）控制平衡

---

