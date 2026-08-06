# gameplots schema 沿用評估

← [README](README.md)

> 本檔評估 `C:\code\mine\gameplots`（唯讀，一字未改）的結構化 schema，
> 有哪些可以直接搬進碑洲的「內容資料模型」，供 deepseek 量產時照表填。

## 一句話

gameplots 是一套「讀既有作品 → 抽取結構化詞條」的分析工具庫：輸入是別人寫好的故事（wiki、攻略），
輸出是 `results/<作品>/{characters,factions,events,places,items,concepts}.md` 六類詞條 + `timeline.md`（編年）
+ `synopsis.md`（速覽）+ `index.md`（索引），每類詞條都有固定的「彈性欄位」結構，目的是給人類讀者
「不看原作也能查」。它做的是**逆向抽取**，我們要做的是**正向生成**——這個方向差異決定了哪些能抄、哪些不能。

## schema 對照表

| gameplots 詞條 | 輸出欄位（來源檔） | 我們的 ToME 內容需要 | 可直接沿用 | 我們多需要的 | 它有我們用不到的 |
|---|---|---|---|---|---|
| 人物 `extract_characters` | 一句話定位／登場與結局／動機／行動／關係／附註 | NPC 定義（`docs/knowledge/npc-and-chats.md`） | 一句話定位→NPC flavor desc；動機／行動→背景故事可轉 `desc`／chat 內容；關係→faction/同伴連結 | `name` 的英文 id、`faction` id、`can_talk` 對應 chat 檔、`image`／`nice_tile` 貼圖路徑、`level_range`／`rank`／`rarity`、`unique` 旗標、大地圖座標或 zone 內座標 | 附註裡的「視覺/音樂敘事意義」——生成內容用不到考據既有配樂 |
| 種族/陣營 `extract_factions` | 起源／構成／目標信念／與其他陣營關係／關鍵人物／故事中角色 | faction／reputation 定義 | 起源／目標信念→faction lore desc；與其他陣營關係（盟友/敵人）→engine 的 relative faction 表可直接照抄「質性」再填數值 | faction id 字串、初始 reputation 數值、`kill_on_sight` 門檻、玩家陣營選擇分支 | 「與其他陣營的關係」若寫成純敘事文（如「曾經是盟友，後因……分裂」）用不到，engine 只認二元/數值關係 |
| 地點 `extract_places` | 位置／概述／居民掌控者／發生過的事／敘事意義／現狀 | zone 定義（`docs/knowledge/worldmap-and-zones.md`） | 位置／概述／敘事意義→zone 的 `desc`／進場文案；居民掌控者→連結 NPC/faction；現狀→決定 zone 是廢墟/繁榮的貼圖風格 | zone `short_name`、`level_range`、地圖產生器/tileset 選擇、大地圖進入座標、`persistent` 旗標、encounter 表 | 「發生過的事」若只是背景敘事而非可玩事件，只能當 flavor text，不對應任何 quest 欄位 |
| 事件 `extract_events` | 時間／地點／參與者／經過／結果／長期影響／真相隱情 | quest 定義（`docs/knowledge/quests-and-lore.md`） | 經過／結果／長期影響→quest 大綱與 `desc`；參與者→NPC/faction 連結；真相隱情→適合當 quest 後段揭露的伏筆 | quest `id`／`name`／`desc`（assert 必填）、觸發點（`on_grant`／對話 `answers[].action`／`on_enter`／`on_die`）、`on_status_change`、狀態常數 `PENDING/COMPLETED/DONE/FAILED`、子目標 | 「時間定位」（編年位置）我們用不到——ToME quest 沒有全局時間軸，只有 quest chain 的先後關係 |
| 物品/技術 `extract_items` | 本質／能力／來源／持有使用者／故事中角色／代價隱情／下落 | artifact／ego 定義（`docs/knowledge/items-and-egos.md`） | 本質／來源／代價隱情→`desc`／`unided_name` 的 flavor text | `define_as`、`base` 繼承模板、`rarity`＋`material_level`、`power_source`、`combat`／`wielder` 數值、`image`／`moddable_tile`、`set_list`、掉落 `resolvers.drops` | 「能力」若寫成敘事化描述（如「能斬斷因果」）完全用不到，engine 只認具體數值鍵（`combat.dam`、`talent_on_hit` 等） |
| 概念/設定 `extract_concepts` | 意涵／運作方式／持有者信仰者／與其他概念關係／故事中功能／真相隱情 | lore 條目（`docs/knowledge/quests-and-lore.md` §4） | **幾乎整組欄位可直接當 lore 正文**——意涵＋運作方式＋故事中功能串起來就是 `newLore{...}.lore` 的內文素材 | lore `id`／`category`（`newLore` 必填）、觸發方式（撿物件 `lore=` 欄位／NPC `on_death_lore`／`placeRandomLoreObject`） | 無明顯浪費——這一類詞條的敘事密度剛好貼合 lore 條目的用途 |

## 可直接抄的部分

- `gameplots/skills/extract_concepts.md` 的詞條結構（意涵／運作方式／持有者信仰者／與其他概念關係／故事中功能／真相隱情）
  —— 抄成我們「律」與「碑」的 lore 詞條模板**幾乎不用改**，這是六類裡貼合度最高的一份。
- `gameplots/skills/extract_events.md` 的欄位（時間／地點／參與者／經過／結果／長期影響／真相隱情）
  —— 抄成 quest 的「敘事大綱」欄位（不含機制觸發點那半），填完這張表再由人/agent 補 `id`／觸發點/狀態機。
- `gameplots/skills/extract_factions.md` 的「與其他陣營的關係」欄位設計（盟友/敵人/連結對方詞條）
  —— 抄成 faction 表的質性關係欄，之後再加一欄數值化。
- `gameplots/skills/scan_entities.md` 的方法論（先窮盡列名單、缺一條就是漏一條）
  —— 抄成量產前的**流程**：每域先出一份「本域所有 NPC/faction/zone/quest/item/lore 名單」當 deepseek 的覆蓋 checklist，
  跟 `docs/analysis/` 「先索引再細寫」的精神一致。
- `gameplots/skills/build_index.md` 的索引產生法（掃描各表、每條目一行 + 連結、自我檢查條目數對得上 entities 名單）
  —— 抄成每域收尾時「產內容索引 + 自我核對數量」的檢查步驟，用來擋 deepseek 漏填。

## classes/ 三份分類表能不能當「內容生成的選單」

| 檔案 | 判斷 | 理由 |
|---|---|---|
| `gameplots/classes/archetypes_character.md`（10 個角色原型） | **可以**，但要加一欄「對應哪條律」再用 | 每條原型已經是「核心特質／動機與代價／創作應用」三段固定結構，拿掉「對應案例」（指向別的作品）就是一份乾淨的選單——讓 deepseek 從 10 個原型挑一個再套用當地的律，比自由發揮動機收斂得多。但原型本身是通用奇幻 MMO 調性，跟碑洲「律即物理法則」的世界觀不天然掛鉤，直接抄等於半成品，需要我們自己補一欄「這個原型在碑洲的哪個域最合理」。 |
| `gameplots/classes/themes_narrative.md`（9 個敘事主題） | **可以**，同上邏輯 | 「反抗命運」「禁忌的代價」「封印與末日倒數」這類主題本身就是可重複套用的 quest 骨架，適合當「這條主線用哪個主題」的選單，比讓弱模型自己想劇情走向安全。同樣要砍掉「對應案例」欄位並補上律的掛鉤。 |
| `gameplots/classes/tropes_worldbuilding.md`（4 個世界觀 trope） | **不建議當固定選單，只當靈感參考** | 只有 4 條且高度綁定單一來源（少女咖啡槍/雙生視界），樣本太薄，不足以覆蓋七域的地圖設計需求；照抄會讓多個域撞出同一種「雙重空間」套路。可以讀過取靈感，但不要把它當作填空表。 |

**結論**：`archetypes_character.md` 與 `themes_narrative.md` 值得整理成碑洲自己的「NPC 原型選單」與「quest 主題選單」（各自去掉對應案例欄、加一欄「哪條律／哪個域適用」），`tropes_worldbuilding.md` 樣本太少，不列入強制選單。

## 不建議沿用的部分

1. **「全劇透」與「窮盡名單」的寫作哲學不適用**——gameplots 的目的是「讓讀者不看原作也能查」，
   所以要求全劇透、逐條窮盡；我們是在**生成新內容**，沒有「原作」可劇透，也不該把窮盡既有素材的紀律
   誤用成「必須填滿所有欄位」。可以抄表格結構，不要抄這套工作哲學。
2. **`working/<作品>/raw/` → `results/` 的攝入流程不適用**——那套流程假設有「原始素材」可分析。
   碑洲沒有原作，起點是空白，不需要 ingestion/analysis 兩階段，只需要 schema。
3. **`classes/` 各條目的「對應案例」欄位不要抄**——那些指向別款遊戲的具體人物/事件，
   照抄等於把別的作品的具體設計原封引用進碑洲，有素材雷同與著作權風險，且對深度模型量產無幫助。
4. **座標、貼圖、數值、id 這類機制欄位 gameplots 完全沒有**——不是「不建議沿用」而是「它本來就不覆蓋」，
   這部分（`docs/knowledge/npc-and-chats.md` `items-and-egos.md` `worldmap-and-zones.md` `quests-and-lore.md`
   列出的引擎欄位）要我們自己定義，gameplots 幫不上忙。
5. **`build_index.md` 的錨點連結格式（GitHub slugify 的 `#中文錨點`）不要跟 ToME 的 id 系統混用**——
   前者是給人類讀者導覽的 markdown 連結，後者是 `grantQuest("<addon>+<name>")`／`define_as`／`newLore{id=...}`
   這類程式碼裡的穩定字串鍵。兩套 id 命名規則完全獨立，索引產生的**流程**可以抄，錨點格式本身不要照搬。

## 總結判斷

gameplots 六個 `extract_*` 裡，**`extract_concepts.md` 貼合度最高（幾乎可以直接當 lore 模板）**，
`extract_events.md`／`extract_factions.md`／`extract_places.md` 次之（敘事欄位可抄，機制欄位要自己補），
`extract_characters.md`／`extract_items.md` 的敘事欄位可用但機制欄位（座標、數值、id）缺口最大——
這兩類正是 ToME 內容裡「引擎相關細節最多」的兩類。`classes/` 的角色原型與敘事主題兩份可以整理成生成選單，
世界觀 trope 那份樣本太薄不建議照搬。
