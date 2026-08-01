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
    id = "temple-creation-note-1",  -- 唯一識別符
    category = "temple of creation",  -- 分類（ShowLore 中分組）
    name = _t"tract of destruction",  -- 顯示名稱
    lore = _t[[
#{bold}#On the Nature of the Spellblaze#{normal}#

In the age before the Spellblaze, the great mages...
    ]],
}
```

**文字格式化標記**：

| 標記 | 效果 |
|------|------|
| `#{bold}#...#{normal}#` | 粗體文字 |
| `#{italic}#...#{normal}#` | 斜體文字 |
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

---
