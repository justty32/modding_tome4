## 3. data/quests/ — 任務系統

共 **49 個任務定義檔案**，實現完整的任務追蹤與進度管理。

### 3.1 起始任務（職業/種族專屬）

| 檔案 | 說明 |
|------|------|
| `start-allied.lua` | Allied Kingdoms 開始任務 |
| `start-archmage.lua` | 大法師職業特殊開場 |
| `start-dwarf.lua` | 矮人種族開場 |
| `start-shaloren.lua` | Shaloren 精靈開場 |
| `start-sunwall.lua` | 太陽之牆開場 |
| `start-thaloren.lua` | Thaloren 精靈開場 |
| `start-undead.lua` | 不死種族特殊開場 |
| `start-yeek.lua` | Yeek 種族開場 |
| `start-point-zero.lua` | Point Zero（時空裂縫）開場 |
| `starter-zones.lua` | 新手地區進度追蹤 |

### 3.2 主線任務鏈

| 任務 | 大小 | 說明 |
|------|------|------|
| `high-peak.lua` | 13KB | 主線終章：攻克 High Peak |
| `shertul-fortress.lua` | 10KB | 中線：解鎖 Sher'Tul 要塞 |
| `west-portal.lua` | 4.8KB | 主線：開啟西方傳送門 |
| `east-portal.lua` | 7.8KB | 主線：前往遠東 |
| `keepsake.lua` | 12KB | 神器保護任務 |
| `pre-charred-scar.lua` | — | 焦土峽谷前置 |

### 3.3 Tier 1 新手任務組

控制新手階段可訪問的地區序列（via `starter-zones.lua`）：
- 選擇其中 **2 個** Tier 1 地區（共 7 個可選）
- 完成後解鎖 High Peak 主線

### 3.4 側線任務

**職業相關**

| 任務 | 說明 |
|------|------|
| `antimagic.lua` | 加入 Ziguranth（反魔法路線）|
| `anti-antimagic.lua` | 加入 Angolwen（魔法路線）|
| `brotherhood-of-alchemists.lua` | 煉金士兄弟會配方任務（17KB）|
| `lichform.lua` | 巫妖轉化任務 |
| `lightning-overload.lua` | 法師閃電過載技能解鎖 |
| `paradoxology.lua` | 時空術師悖論研究 |
| `staff-absorption.lua` | 法杖吸收技能 |

**劇情側線**

| 任務 | 說明 |
|------|------|
| `love-melinda.lua` | Melinda 人質救援（情感線）|
| `mage-apprentice.lua` | 法師學徒指導 |
| `master-jeweler.lua` | 珠寶師工藝任務 |
| `ring-of-blood.lua` | 血戒契約 |
| `kryl-feijan-escape.lua` | Kryl-Feijan 越獄 |

**BOSS 觸發任務**

| 任務 | 說明 |
|------|------|
| `orc-pride.lua` | 消滅四個獸人部落 |
| `orc-breeding-pits.lua` | 清除獸人繁殖穴 |
| `orc-hunt.lua` | 特定獸人獵殺 |
| `dreadfell.lua` | Dreadfell 地城任務 |
| `deep-bellow.lua` | Deep Bellow 地城 |
| `grave-necromancer.lua` | 巫妖獵殺 |

**世界事件任務**

| 任務 | 說明 |
|------|------|
| `escort-duty.lua` | 護送任務（隨機生成護送 NPC）|
| `lost-merchant.lua` | 失蹤商人救援 |
| `lumberjack-cursed.lua` | 受詛咒的伐木工 |
| `spydric-infestation.lua` | 蜘蛛侵擾 |
| `temple-of-creation.lua` | 創造神殿探索 |
| `temporal-rift.lua` | 時空裂縫消除 |
| `trollmire-treasure.lua` | 巨魔之沼寶藏 |
| `void-gerlyk.lua` | Void 實體 Gerlyk |

**特殊模式任務**

| 任務 | 說明 |
|------|------|
| `arena.lua` | 競技場波次 |
| `arena-unlock.lua` | 競技場解鎖條件 |
| `infinite-dungeon.lua` | 無限地城記錄 |

### 3.5 任務定義結構

```lua
-- data/quests/example-quest.lua
name = _t"Main Quest: End the Threat"
desc = function(self, who)
    local desc = {}
    desc[#desc+1] = _t"You must defeat the great evil."
    if self:isCompleted("boss_killed") then
        desc[#desc+1] = "#LIGHT_GREEN#".._t"* You have killed the boss!"
    else
        desc[#desc+1] = "#YELLOW#".._t"* Find and kill the boss."
    end
    return table.concat(desc, "\n")
end
on_grant = function(self, who)
    game.logCenter(_t"A new quest begins!", ...)
end
on_status_change = function(self, who, status, sub)
    if status == self.COMPLETED then
        who:grantReward(...)
    end
end
```

**任務狀態流**：未開始 → 進行中（`STARTED`）→ 完成（`COMPLETED`）/ 失敗（`FAILED`）

**子任務（substatus）**：`self:setSubStatus("boss_killed", true)` 追蹤子目標

---

## 4. data/lore/ — 史料系統

共 **36 個史料定義檔案**，構建世界觀知識體系。

### 4.1 史料分類

**地點史料**

| 檔案 | 記錄地點 |
|------|---------|
| `angolwen.lua` | 法師城市 Angolwen |
| `ardhungol.lua` | 蜘蛛巢穴 Ardhungol |
| `daikara.lua` | 火山 Daikara |
| `derth.lua` | 城鎮 Derth |
| `dreadfell.lua` | 恐懼要塞 |
| `kor-pul.lua` | Kor'Pul 地下城 |
| `last-hope.lua` | 最後希望城市 |
| `maze.lua` | 大迷宮 |
| `scintillating-caves.lua` | 閃耀洞窟 |
| `sandworm.lua` | 沙蟲領域 |
| `trollmire.lua` | 巨魔之沼 |

**派系/勢力史料**

| 檔案 | 說明 |
|------|------|
| `rhaloren.lua` | Rhaloren 精靈 |
| `shertul.lua` | Sher'Tul 古族 |
| `slazish.lua` | Slazish 族 |
| `spellhunt.lua` | 反魔法獵巫 |
| `sunwall.lua` | 太陽之牆 |
| `tannen.lua` | 法師 Tannen |
| `zigur.lua` | Zigur 城市（反魔法）|
| `iron-throne.lua` | 鐵王座帝國 |
| `orc-prides.lua` | 獸人部落 |
| `elvala.lua` | Elvala 精靈地 |

**劇情史料**

| 檔案 | 說明 |
|------|------|
| `fearscape.lua` | 恐懼界 |
| `spellblaze.lua` | 魔法大爆炸歷史 |
| `high-peak.lua` | High Peak 故事 |

**特殊史料**

| 檔案 | 大小 | 說明 |
|------|------|------|
| `misc.lua` | 85KB（最大）| 綜合世界史料（大量內容）|
| `fun.lua` | — | 幽默彩蛋條目 |
| `arena.lua` | — | 競技場相關史料 |
| `lore.lua` | — | 載入器（載入所有史料檔）|

### 4.2 史料條目結構

```lua
newLore{
    id = "temple-creation-note-1",
    category = "temple of creation",
    name = _t"tract of destruction",
    lore = _t[[
#{bold}#On the Nature of the Spellblaze#{normal}#
In the age before the Spellblaze, the great mages...
    ]],
}
```

**文字格式化標記**：

| 標記 | 效果 |
|------|------|
| `#{bold}#...##{normal}#` | 粗體文字 |
| `#{italic}#...##{normal}#` | 斜體文字 |
| `#GOLD#...#LAST#` | 金色文字 |
| `#LIGHT_GREEN#...#LAST#` | 亮綠色 |
| `#RED#...#LAST#` | 紅色警告 |

### 4.3 史料發現機制

1. **地圖物品**：特殊「史料書」物品被拾取時觸發
2. **NPC 對話**：對話中選擇特定選項解鎖
3. **地形互動**：踩到特殊地板/物件
4. **事件觸發**：完成特定事件後自動解鎖

**發現時行為**（`PartyLore` 混入）：
- 打斷玩家的休息/奔跑
- 彈出 `LorePopup` 通知
- 記錄到 `PartyLore.lore` 表
