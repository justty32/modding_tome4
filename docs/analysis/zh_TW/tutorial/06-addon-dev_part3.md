### 步驟六：職業描述符

```lua
-- game/addons/my-shadow/data/birth/shadow.lua

-- 允許「亡靈」陣營選擇此職業
getBirthDescriptor("class", "Rogue").descriptor_choices.subclass["Shadow Assassin"] = "allow"

newBirthDescriptor{
    type = "subclass",
    name = "Shadow Assassin",

    desc = {
        "暗影刺客是潛行與瞬殺的大師，在黑暗中穿梭，目標察覺前便已結束戰鬥。",
        "核心屬性：靈巧（Dexterity）與狡黠（Cunning）",
        "#GOLD#屬性加成：",
        "#LIGHT_BLUE# * +2 敏捷、+3 靈巧、+2 狡黠、-1 體質",
        "#GOLD#每級生命：#LIGHT_BLUE# -3",
    },

    -- descriptor_choices = { ... },  -- 不設限則所有陣營可選

    power_source = {technique=true, antimagic=false},

    stats = { str=0, dex=2, con=-1, mag=0, wil=0, cun=3 },

    talents_types = {
        ["shadow/stealth-arts"] = {true,  0.3},
        ["technique/combat-training"] = {true,  0},
        ["cunning/survival"]    = {true,  0},
        ["cunning/stealth"]     = {true,  0.3},
    },

    talents = {
        [ActorTalents.T_SHADOW_STEP] = 1,
        [ActorTalents.T_WEAPON_COMBAT] = 1,
        [ActorTalents.T_STEALTH] = 1,
    },

    copy = {
        max_life = 90,
        resolvers.equipbirth{ id=true,
            {type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
            {type="armor",  subtype="light",  name="rough leather armour", autoreq=true, ego_chance=-1000},
        },
    },

    copy_add = { life_rating = -3 },
}
```

---

## 7. 測試開發中 Addon

### 方法一：直接放目錄

```
game/addons/my-shadow/
```

啟動後主選單 → Addons → 勾選 → 重啟。

### 方法二：用 tome-addon-dev

啟用後按 F1 進入 Debug > Addon Developer：

- **FSHelper**：瀏覽 PhysFS，確認路徑掛載
- **NPCDesign**：即時測試 NPC
- **TalentFinder**：搜尋天賦
- **ExampleAddonMaker**：快速生成骨架

### 常見錯誤

```lua
-- hooks/load.lua 或天賦 action 中加 print
print("Loading my talent definition...")

-- 確認天賦常數：天賦 "Shadow Step" → T_SHADOW_STEP
-- 遊戲 console (F1 LUA CONSOLE) 執行：
-- print(ActorTalents.T_SHADOW_STEP)
```

| 錯誤 | 原因 |
|------|------|
| Addon 未出現 | `for_module` 不符；`init.lua` 語法錯誤 |
| 天賦不在選單 | `hooks` 未設 `true`；路徑錯誤 |
| `T_SHADOW_STEP` 為 nil | 未經 `ActorTalents:loadDefinition` 載入 |
| superload 崩潰 | 漏 `return _M` 或 `loadPrevious(...)` 缺 `...` |
| 路徑找不到 | `data/` 真實路徑是 `/data-my-shadow/`，非 `/data/` |

---

## 8. Superload 鏈（多 Addon 共存）

多 Addon superload 同一模組時，按 `weight` 小→大串聯：

```
原始 Actor.lua
  └─ addon-A (weight=1) superload → loadPrevious() 取得原始
      └─ addon-B (weight=2) superload → loadPrevious() 取得 addon-A 版
          └─ require "mod.class.Actor" 回傳最外層（addon-B 版）
```

意涵：

- **每個 superload 必須呼叫 `loadPrevious()`**，否則斷鏈使前序 Addon 失效
- **方法替換須儲存原始引用**（如 `orig_gainExp`）再呼叫
- 越後載入（weight 越大）包裝在最外層，優先執行

---

## 9. 打包發布

壓縮為 `.team`（即標準 zip）：

```bash
cd game/addons/
zip -r my-shadow-1.0.0.team my-shadow/
```

發布管道：

- [te4.org](https://te4.org) Addon 頁面
- 或直接分發 `.team`，玩家放入 `~/.t-engine/4.0/game/addons/`

---

## 10. 實際 Addon 分析

| Addon | 機制 | 功能 |
|-------|------|------|
| `tome-addon-dev` | hooks + overload + superload | 開發工具（FSHelper、NPCDesign），僅 cheat 模式 |
| `tome-possessors` | hooks + superload + data | DLC 職業：hooks 載入天賦，superload/Actor.lua 攔截 gainExp |
| `tome-items-vault` | hooks + overload + data | 線上物品保管庫：hooks 注入地圖子產生器與實體列表 |

### tome-possessors 載入流程

```
init.lua (hooks=true, superload=true, overload=true, data=true)
    │
    ├─ hooks/load.lua
    │      bindHook("ToME:load", PO.hookLoad)
    │
    ├─ superload/mod/class/Actor.lua
    │      loadPrevious(...)  ← 取得原始 Actor
    │      _M.gainExp = 包裝版（EFF_POSSESSION 時阻止經驗）
    │
    └─ overload/mod/class/PossessorsDLC.lua  ← 新類別（不覆蓋現有）
           hookLoad():
               ActorTalents:loadDefinition("/data-possessors/talents/...")
               ActorTemporaryEffects:loadDefinition("/data-possessors/timed_effects.lua")
               Birther:loadDefinition("/data-possessors/birth/psionic.lua")
```

---

## 11. 總結

| 機制 | 適用情境 | 風險 |
|------|----------|------|
| `hooks` | 注入生命週期、載入新定義 | 低；多 Addon 共存無問題 |
| `superload` | 修改現有方法行為 | 中；需正確呼叫 loadPrevious 維持鏈 |
| `overload` | 添加全新類別/替換資源 | 高；兩 Addon 覆蓋同一檔案會衝突 |

**最佳實踐**：

1. 優先 `hooks/ToME:load` 載入定義，避免 superload
2. 修改現有方法才用 superload，務必呼叫原始方法
3. 新類別放 `overload/` 用獨特路徑（如 `mod/class/MyAddonClass.lua`）
4. 資料放 `data/`，以 `/data-<short_name>/` 路徑存取

---

**下一步**：→ [教學 07：為 ToME 新增職業與技能樹（進階）](./07-class-and-talents.md)
