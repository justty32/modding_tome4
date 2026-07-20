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
    -- 根據任務狀態動態生成描述
    local desc = {}
    desc[#desc+1] = _t"You must defeat the great evil."
    if self:isCompleted("boss_killed") then
        desc[#desc+1] = "#LIGHT_GREEN#"..
            _t"* You have killed the boss!"
    else
        desc[#desc+1] = "#YELLOW#"..
            _t"* Find and kill the boss."
    end
    return table.concat(desc, "\n")
end
on_grant = function(self, who)
    -- 接受任務時執行
    game.logCenter(_t"A new quest begins!", ...)
end
on_status_change = function(self, who, status, sub)
    -- sub = 子狀態名稱
    if status == self.COMPLETED then
        who:grantReward(...)
    end
end
```

**任務狀態流**：未開始 → 進行中（`STARTED`）→ 完成（`COMPLETED`）/ 失敗（`FAILED`）

**子任務（substatus）**：`self:setSubStatus("boss_killed", true)` 追蹤各個子目標

---
