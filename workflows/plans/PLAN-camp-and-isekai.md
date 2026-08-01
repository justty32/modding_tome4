# 建置計畫：營地系統 ＋ 歐拉麗異世界

2026-07-11 過夜研究已完成、templates 已備齊，但因 token 預算沒有動手做（zone 是最容易出坑的一塊，
見 runeisles 的踩坑史）。以下是可直接照做的建置藍圖。研究來源見 knowledge/{worldmap-and-zones,
quests-and-lore,npc-and-chats,companions-and-party}.md 與 sub_proj/analysis/t-engine/tutorial/{10,11}-base-camp-*.md。

---

## A. 營地系統（tome-camp）

**目標**：一個持久私有據點，玩家可隨時召回、休息（回血），且狀態持久（放的東西下次還在）。

### 最短實作路徑（低風險版：talent 召回，避開大地圖 overlay 的 wild_x/wild_y bug）

檔案結構（鏡像 runeisles 的 town-stonemark，已驗證可用）：
```
mods/tome-camp/
  init.lua            data=true, hooks=true
  hooks/load.lua      loadDefinition 召回天賦 + ToME:birthDone 教給玩家 + selfcheck
  data/talents/spells/camp.lua      T_CAMP_RECALL
  data/zones/camp/zone.lua          persistent="zone" 的小房間（抄 town-stonemark/zone.lua）
  data/zones/camp/grids.lua         FLOOR/HARDWALL + 營火 + 出口（抄 town-stonemark/grids.lua）
  data/maps/camp.lua                小 ASCII 房間
```
- **zone 短名 = "camp+camp"**（addon short_name "camp" ＋ zone 目錄 "camp"），
  地圖 ref 同為 "camp+camp"（engine/Zone.lua:155-165 的 `+` 慣例）。
- zone.lua 關鍵欄位（**別漏，會 assert 崩**）：`max_level=1`、`width/height` 精確等於 map 的欄列數、
  `persistent="zone"`（否則每次回營地全部重置）、`all_lited=true`。**不要 `wilderness=true`**（那是大地圖語意）。
- grids.lua：**別用 `base="GRASS"`**（nice_tiler 會 100% 換成草地貼圖，你的 image 永遠不顯示——
  runeisles 雪港變綠地就是這坑）。營火用一個自訂 floor grid（image `terrain/campfire.png` 之類，
  先 `unzip -l tome-gfx.team | grep campfire` 確認存在再用）。

### 兩個要小心的接點（研究已標出，實作時重點驗）
1. **玩家落點**：`game:changeLevel(1, "camp")`（Game.lua:940）進新 zone 時，玩家落在 zone 的
   default 起點。Static 地圖要有明確落點——最穩做法：地圖放一個 `<` 上樓梯 tile（`change_level`），
   玩家會落在它上面。實作後**必 playtest 確認落點不是牆裡/(0,0)**。
2. **回程**：召回天賦 toggle——在 camp 就 changeLevel 回 `self.camp_return`（召回前存的
   `{zone=game.zone.short_name, lev=game.level.level}`）；否則存座標並去 camp。回程會落在原 zone 的
   入口而非離開的精確格（ToME 的 recall 也是這樣，可接受）。
   - 進階（更貼「大地圖據點」語意）：改用 runeisles 的 `Entity:loadList`+`MapGeneratorStatic:subgenRegister`
     兩個 hook 把營地入口貼到 Eyal 大地圖（tome-runeisles/hooks/load.lua:28-51），出口 tile `change_zone`
     回 "camp+camp"。但這會碰到 wild_x/wild_y 單組全域 bug（knowledge/worldmap-and-zones.md §5），
     要用 change_level_check 存座標（無 upvalue，要能序列化）。**先做 talent 版，行有餘力再升級。**

### 回血/休息
最簡單、零序列化風險：召回天賦抵達 camp 後直接
`for _,a in ipairs(game.party.m_list) do a.life=a.max_life ... end`（順便回各資源）。
別把 heal 塞進 grid 的匿名 callback（不可序列化，tutorial 10 的核心教訓）。

### 進階（tutorial 11 已研究）
建造系統（Grid 替換 + build_tag 掃描）、農作計時器（Game:onTurn + game.camp_state，
須 `defaultSavedFields{camp_state=true}` 才會存檔）。這些是 v0.2。

---

## B. 歐拉麗異世界（tome-orario，對應「在地下城邂逅」）

**世界結構決策**：用 **hub 城鎮方案（B 案）**，不用「城市當 wilderness 大地圖」（A 案）。
理由：A 案要處理 wilderness 包裝式開關的一堆連動副作用（FOV、掉落永久遺失、技能鎖，
worldmap-and-zones.md:14-20）與 wild_x/wild_y bug；B 案完全複用 town-stonemark 的四件式結構、實作量小很多，
且「鎮與鎮之間傳送」正好符合「歐拉麗各設施各是一區」的設計。中央大迷宮兩案通用。

### 佈局（每個都是一個 zone，用 change_level/change_zone 傳送門互連）
```
歐拉麗中央廣場 (hub zone, town-orario)  ← 起點
  ├─ 傳送門 → 冒險者公會 (town-guild)        公會 NPC 發討伐任務
  ├─ 傳送門 → 豐饒女主人酒館 (town-hestia)   招募同伴 NPC（用 tome-companions 的機制）、休息回血
  ├─ 傳送門 → 市集/巴別塔市集 (town-market)  商店（traps.lua + resolvers.store）
  ├─ 各眷族據點 (town-familia-*)            劇情/委託 NPC
  └─ 傳送門 → 地下城 (dungeon-babel L1..N)   persistent 多層地城（抄 dreadfell/zone.lua 結構）
```

### 建置序（每步都能獨立 playtest，不要一次全做）
1. **hub 中央廣場 zone**（抄 town-stonemark 四件式：zone/grids/npcs/traps/map）。這是骨架。
2. **中央大迷宮**：一個 `persistent="zone"` 的多層 dungeon（`max_level=N`，用 Roomsloader 隨機生成或
   Static 手擺）。抄 `M/data/zones/dreadfell/zone.lua`。從 hub 放一個 `<` 傳送門進入。
3. **公會 + 討伐任務**：公會 NPC（`can_talk="orario+guild"`，焊在 hub 地圖 defineTile 第4參），
   對話 action 內 `who:grantQuest("orario+bounty-"..隨機)`；quest 惰性 loadfile，可程式化生成 table
   （ActorPartyQuest.lua:44 接受直接傳 table）。擊殺回報走目標 NPC 的 on_die →
   `setQuestStatus(id, DONE, "kill")`；回公會 chat 用 cond 檢查 isCompleted 顯示回報選項。
   （細節與行號見 knowledge/quests-and-lore.md 與過夜研究報告。）
4. **酒館招募**：酒館放幾個具名 NPC，對話 action 內用 tome-companions 的 doRecruit 機制
   （或直接 `game.party:addMember(control="full")`）把它們收為同伴——**與已完成的同伴系統天然接上**。
5. **市集商店**：traps.lua `resolvers.store(...)`（抄 town-derth/traps.lua）。
6. **眷族據點**：其餘 town zone，塞劇情 NPC + lore。劇情/人物「不用太計較或還原」（使用者原話）。

### 整包當獨立 campaign（選用，進階）
若要建角畫面能選「歐拉麗」世界：`newBirthDescriptor{type="world"}`（worlds.lua:66 範本），
用 `before_starting_zone` hook（Game.lua:285）把起始 zone 換成歐拉麗 hub。
但**三個官方 DLC 沒一個真的另開世界地圖**，無前例可抄，風險高——初版建議先做成「從 Eyal 某入口進歐拉麗」
（像 runeisles 那樣掛在既有世界上），不動 campaign 選擇。

---

## 已完成（2026-07-11 過夜）
- **tome-companions**：招募+培養+免傷，實機驗證、已 deploy。
- **tome-crafting**：附魔+煉製，驗證、已 deploy。
- 粒子研究（knowledge/particles.md）＋ 上面兩個系統的研究都已落檔。
- 粒子特效實作**刻意留給使用者醒著**（牽涉動畫，需人眼 debug）。
