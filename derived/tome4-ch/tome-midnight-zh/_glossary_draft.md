# midnight addon 漢化 — 術語表（草稿，供分工 agent 共用）

此檔為施工中間產物，完工後內容併入 NOTES.md，本檔本身**不要**被打包進最終 addon（不是 .lua）。

## 沿用官方 zh_hant.lua 既有譯法（務必照抄，勿自創）

- Celestial（出生描述符 / 職業大類） → 天空系
- Sun Paladin → 太陽騎士
- Anorithil → 星月術士
- Elf → 精靈
- Human → 人類
- Sunwall → 太陽堡壘
- Gates of Morning → 晨曦之門
- Sceptre → 權杖
- Physical Power → 物理強度
- Spellpower → 法術強度
- Mindpower → 精神強度
- Physical Save / Spell Save / Mental Save → 物理豁免 / 法術豁免 / 精神豁免
- saving throw → 豁免
- Cooldown / cooldown → 冷卻時間 / 冷卻
- crit / Critical → 暴擊
- Combat Training（天賦樹） → 戰鬥訓練

## midnight 專屬新名詞（本次定譯，全檔案內部須一致）

### 新職業（birth class，data/birth/classes/celestial.lua）
- Moon Paladin → 月光騎士（對照官方 Sun Paladin＝太陽騎士）
- Starslinger → 擲星者

### 新種族／子種族（birth subrace）
- Star Elf → 星精靈（對照天賦樹 key `race/star-elf`）
- Mardrop → 馬卓普（音譯，Human 子種族專有名，無實義可翻）

### 新天賦樹（newTalentType，data/talents/celestial/celestial.lua 定義，其餘檔案沿用）
- night → 夜色（generic，Moon Paladin 用，隱匿＋傷害）
- lunar combat → 月之戰技
- shooting stars → 流星
- guidance → 引導
- deep space → 深空
- sigils → 符印
- glory → 榮光
- moon magic → 月魔法
- umbra → 暗影本源（Starslinger 用，恆星與黑暗的真正力量；勿與「night／夜色」混用）
- race/star-elf → 星精靈（天賦樹沿用種族名）
- race/mardrop → 馬卓普（天賦樹沿用種族名）

### 地名
- Tenebrous Glades（新地城） → 幽暗林地
- Midnight（新城鎮，也是本 addon 名稱） → 午夜鎮（town-midnight 相關場景用此譯名；短字串 "Midnight" 若明確指這座城鎮才用「午夜鎮」，若泛指「午夜／子夜」時間概念則譯「午夜」）
- Sunwall Orchard（新地城） → 太陽堡壘果園

## tag 選用備忘（依 GUIDE 權威表）
- 天賦樹 name/description → "talent type" / "talent category"（依官方檔同類條目為準，grep 確認）
- newTalent name → "talent name"；info() 內含 %d/%s 等格式符的描述 → "tformat"；無格式符的固定描述 → "_t"
- newEntity name → "entity name"；desc → "_t"（除非含格式符則 "tformat"）
- newBirthDescriptor name → "birth descriptor name"；desc → "_t"
- chats / 對話文字 → "chat" 或 "say"（依官方 chats 章節 grep 確認）
- game.log / logSeen / logPlayer → "log"

## 已確認「無玩家可見字串」的檔案（掃過，locale 不需條目，仍需在 NOTES.md 列出）
- overload/data/gfx/particles/breath_light.lua
- overload/data/gfx/particles/corrupt_starfield.lua
- overload/data/gfx/particles/fullshadow.lua
- overload/data/gfx/particles/lunar_flash.lua
- overload/data/maps/zones/sunwall-orchard1.lua
- overload/data/maps/zones/sunwall-orchard2.lua
- overload/data/maps/zones/sunwall-orchard3.lua
- overload/data/maps/towns/midnight.lua
- data/maps/gates-of-morning-overlay.lua
（若你負責的檔案中發現以上判斷有誤、其實有字串，請照常翻譯並在你的報告中提出更正）

## 輸出格式規範（給分工 agent）

- 每人只寫**自己的暫存 partial locale 檔**，路徑由任務指派決定，**不要**動 `data/locales/zh_hant.lua` 正式檔（會由主控合併，避免多人同時寫入衝突）。
- partial 檔內**不要**寫 `locale "zh_hant"` 這行（合併時只在最終檔開頭寫一次），直接從 `section "..."` 開始。
- section 命名慣例：`section "midnight/<addon 內相對路徑>"`，例如 `section "midnight/data/talents/celestial/night.lua"`。
- 每個來源檔一個 section，照 GUIDE 規則抽取翻譯、用 `t(src, dst, tag)`。
- 完成後在你的最終回報中列出：處理了哪些檔案、各自抽出幾條、有無疑難字串（找不到適合 tag、程式碼動態拼接無法整串比對等）需要記錄進 NOTES.md。
