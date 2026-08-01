# pi coding agent 實驗紀錄 — 讓外部 agent 做一個新職業 mod

> 逐字紀錄。分析與心得見 [pi-agent-driving.md](pi-agent-driving.md)。

- 目標：女巫（Witch）職業 + 一棵特色技能樹「草藥」
- 驅動方式：`printf '%s' "$PROMPT" | pi -p --provider deepseek --model deepseek-v4-flash --session-id witch-experiment`
- 觀察重點：這個 repo 現有的 AGENTS.md / skills / knowledge / tools 對一個**冷啟動的外部 agent** 夠不夠用


---

## 步驟 1 — 冷啟動定位

### 注入的 stdin

```text
我要你在這個 repo 裡做一個新的 ToME4 職業 addon：女巫（Witch），先只做一棵特色技能樹「草藥」。

這一步先不要寫任何檔案。請你先自己把這個 repo 摸清楚，然後回報：

1. 你讀了哪些檔案來搞懂「這個 repo 要怎麼做一個新職業」？依序列出路徑。
2. 這個 repo 有沒有給你「做新職業」的專門指引？在哪裡？
3. 做一個新職業 addon，最少需要哪些檔案？各自的職責是什麼？
4. 有哪些「會讓你踩坑」的規則，是這個 repo 特別警告過的？
5. 完整的驗證流程是什麼？要跑哪些指令？
6. 你打算怎麼做這個女巫/草藥？列出你的計畫。
7. 你現在還缺什麼資訊、或覺得哪裡文件不清楚？講白話，這題很重要。
```

### pi 的回應

```text
Warning: No project session found with id 'witch-experiment'; creating a new session with that id.
我已經把 repo 摸完了。以下是回報（尚未寫任何檔案）。

---

## 1. 我讀了哪些檔案

**工作流入口與工具鏈**（先決定「做新職業要走哪條路」）：

| 路徑 | 為什麼讀 |
|---|---|
| `wf/WORKFLOWS.md` | 派發表 → 確認「做新職業」走 addon-dev |
| `wf/workflows/addon-dev/README.md` | **主流程**：lint → deploy → verify → playtest → build 的管線與 Done when |
| `tools/README.md` | 工具決策表、驗證分層、probe 用法 |
| `wf/INDEX.md` | repo 佈局總覽 |
| `wf/workflows/common/conventions.md` | 真相層優先級、CODE_MAP 維護鏈 |
| `wf/workflows/common/gotchas.md` | 共通踩坑 |
| `wf/workflows/common/code-map/CODE_MAP.md` | 程式碼導航 |

**知識層（引擎真相）**：

- `docs/knowledge/README.md`（含「引擎很愛靜默失敗」總表）
- `docs/knowledge/addon-loading.md`（init.lua 欄位、`/data-<name>/` 私有掛載、版本相容）
- `docs/knowledge/class-parts/01-birth-and-talents.md`（newBirthDescriptor / newTalentType / newTalent）
- `docs/knowledge/class-parts/02-resources-i18n-inscriptions.md`（自訂資源、i18n、銘文坑）
- `docs/knowledge/playtesting.md`（為什麼 verify 綠燈≠做完）

**自製 addon 實例**（`self_mods/tome-runewright/`——本 repo 最完整的職業包）：

- `init.lua`、`hooks/load.lua`、`data/birth/classes/mage.lua`、`data/talents/spells/runecraft.lua`、`data/talents/spells/futhark-freyr/type.lua`、`data/resources.lua`、`data/locales/zh_hant.lua`
- `self_mods/tome-autobirth/init.lua`（無頭建角夾具）、`self_mods/dist/README.md`（成品慣例）

**引擎原始碼**（複驗真相層）：

- `vendor/t-engine4/modules/tome/data/birth/descriptors.lua`、`classes/mage.lua`、`classes/wilder.lua`、`races/human.lua`、`worlds.lua`
- `vendor/t-engine4/modules/tome/mod/dialogs/Birther.lua`（`generateClasses` / `isDescriptorAllowed` 的實際機制）

**第三方 addon**（`vendor/orig/`）：

- `neka_therianthropy_summoner/data/birth/classes/summon.lua`（**全新 class 的唯一範本**）
- `deathknight/data/birth/classes/mage.lua`（subclass 範本）
- `verdant/data/talents/cunning/herbalism.lua`（**現成的「草藥」技能樹**！）
- `steamwitch/`（witch 主題參考）

**工具內部**：`tools/lint.sh`、`tools/lua/check_init.lua`、`tools/lua/verdict.lua`、`tools/lib/scratch.sh`（autobirth 規格）、`tools/playtest.sh`（`--birth` 參數格式）。

---

## 2. 有沒有「做新職業」的專門指引？

**有，但只到「子職業」的程度。** `addon-dev` 工作流的入口檔 + `docs/knowledge/class-parts/01-birth-and-talents.md` 明確涵蓋 `newBirthDescriptor`；repo 自家的旗艦範例 runewright 也是「掛進既有 Mage class 的子職業」。

**但「全新 class（type="class"）」的完整套路 repo 沒有成文文件**——我是在引擎原始碼裡自己挖出來的（見第 7 點，這是文件缺口）。唯一實證範本是 `vendor/orig/neka_therianthropy_summoner`。

---

## 3. 做一個新職業 addon 最少需要哪些檔案

| 檔案 | 職責 |
|---|---|
| `init.lua` | addon 身分。必填 `long_name`、`short_name`（→ `/data-<short_name>/` 掛載點）、`for_module="tome"`、`version={1,7,6}`（不相容會被**靜默移除**）、`addon_version`、`description`、**`weight`**（漏填會拖垮所有 addon 的 table.sort）；開 `data=true`、`hooks=true` |
| `hooks/load.lua` | `ToME:load` hook。**自己 require** `ActorTalents`/`Birther` 等（不是全域）；依序 `loadDefinition` 所有天賦與 birth 檔；結尾印 `[WITCH] selfcheck ...` 與 `[WITCH] hook complete` 供 verify 判讀 |
| `data/birth/classes/witch.lua` | 職業定義：`type="class"` 描述子（含 `descriptor_choices.subclass` 白名單）+ `type="subclass"` 描述子（stats、talents_types、talents、copy、起手裝備）**＋ 把 class 加進世界白名單**（關鍵，見下） |
| `data/talents/cunning/herbalism.lua` | `newTalentType` + 4 個 `newTalent`（草藥樹） |
| `data/locales/zh_hant.lua` | 正體中文翻譯（本 repo 慣例；locale 是 data/ 下唯一自動載入的例外） |

（若用自訂資源池才需要 `data/resources.lua`；本計畫先不做。）

**全新的 class 比 subclass 多一個關鍵步驟**：Maj'Eyal 世界描述子在 `worlds.lua:36-50` 對 `class` 是 `__ALL__ = "disallow"` 白名單制，所以必須：

```lua
getBirthDescriptor("world", "Maj'Eyal").descriptor_choices.class.Witch = "allow"
```

（neka 範本 `summon.lua:986-988` 就是這樣做，還順手對 Infinite/Arena 設 disallow。）

---

## 4. repo 特別警告過、會踩的坑

**會靜默失敗的（最陰險）：**

- `version` 不相容 → addon 無聲消失（`engine/Module.lua:394,595`），**沒有錯誤訊息**
- 資料夾名前綴不是 `tome-` → 無聲忽略（`:409`）
- `data/` 是私有掛載點 `/data-<short_name>/`，**不會自動掃描**，不 `loadDefinition` 就「檔案在、東西不存在」
- `newBirthDescriptor` 撞名**靜默覆蓋**（但 `newTalent`/`defineResource` 撞名是 assert 崩潰——三者行為不一致）
- 銘文欄位只有 3 格、建角時已被回覆/狂暴紋身+法力符文佔滿，再多給會被**靜默丟棄**
- 資源池沒學關聯隱藏被動天賦 → getter 恆回 0
- `t.name` 是**已翻譯**的，遊戲邏輯比對要用 `t.short_name`（runewright 2026-07-10 實機抓到的真 bug）

**會崩潰的：**

- `weight` 漏填 → 整個 addon 清單 `table.sort` 拋錯，拖垮使用者所有 addon
- hook 檔把 `ActorTalents` 當全域用 → runtime nil index（要自己 require）
- 目錄形式與 `.teaa` 不可同時存在（同 addon 載入兩次）

**流程紀律：**

- **絕不在真實桌面裸跑 `t-engine64`**（沒有 `--help`，直接開遊戲視窗）；自動化一律 `xvfb-run` + scratch home；要用真桌面 `tools/run.sh` 前先問使用者
- 佈署目標是 `~/.t-engine/4.0/addons/`，不是 Steam 的 `game/addons/`
- verify/playtest 是拋棄式 scratch home——**交付前一定要自己跑一次 `tools/deploy.sh`**，否則使用者遊戲裡什麼都沒有
- **verify 綠燈 ≠ 做完**：2026-07-10 抓到三個「載入成功但行為錯誤」的 bug；改動觸及遊戲邏輯必須跑 playtest
- 佈署後 addon **預設即啟用**，不用手動開
- AI 不讀截圖，狀態一律走 probe 純文字
- `vendor/`、Steam 安裝目錄是唯讀區
- 新引擎知識要寫回 `docs/knowledge/` 附 `檔案:行號`

---

## 5. 完整驗證流程

| 順序 | 指令 | 證明什麼 | 時間 |
|---|---|---|---|
| 1 | `tools/lint.sh witch` | 語法 + init.lua 欄位語意 | 秒 |
| 2 | `tools/verify.sh witch` | Xvfb 無頭載入：addon 被掃到、hook 跑完、`[WITCH] hook complete`、無 `selfcheck = FAIL`、無 `Lua Error` | 1–3 分 |
| 3 | `tools/playtest.sh start witch --cheat --birth human/Cornac/Witch/Witch` | 真的建出角色（autobirth 夾具跳過 UI）、真的學/放草藥技能、數值真的變動 | 3–5 分 |
| 4 | `tools/playtest.sh probe ...` | 讀遊戲內狀態（天賦、資源、生物）——AI 的唯一狀態通道 | 每次 ~15 秒 |
| 5 | `tools/build.sh witch` | 打包 `.teaa`（交付時才跑） | 秒 |
| 6 | `tools/deploy.sh witch` | 裝到真 home `~/.t-engine/4.0/addons/`（**必須明確跑，不含 `--home`**）；之後使用者進遊戲選 Witch 驗手感 | 秒 |

Done when 完整定義在 `wf/workflows/addon-dev/README.md`：lint 0 + verify 0（有 hook complete、無 FAIL/Lua Error）+ 觸及邏輯要 playtest 實證 + 新知識寫回 docs/knowledge + deploy 跑過 + 手感/平衡列進 `WAIT_USER.md`。

---

## 6. 我打算怎麼做女巫/草藥

**設計前提**（我照 repo 慣例的假設，會跟你確認）：Witch = **全新 class**（不是 Mage 子職業）、草藥樹 = 她的**招牌樹**，本階段就這一棵，其他樹都不給。

**檔案骨架**（對照第 3 點）：

1. `self_mods/tome-witch/init.lua` — 照 runewright 骨架：`short_name="witch"`、`version={1,7,6}`、`weight=100`、`data=true`、`hooks=true`
2. `hooks/load.lua` — require 五件套 → `loadDefinition` 草藥樹 → `loadDefinition` birth → selfcheck 印 `[WITCH]` 開頭 + `hook complete`
3. `data/birth/classes/witch.lua` —
   - `type="class"` Witch：`descriptor_choices.subclass = { __ALL__="disallow", Witch="allow" }`（也可順手限制種族）
   - `type="subclass"` Witch：主屬性擬 `wil/cun/mag`（草藥=意志+靈巧感），起手學草藥樹、給法力池（若用 mana）、起手裝備照法師系（杖+布袍）、`resolvers.equipbirth`、不加 `resolvers.inscription`（避開 3 格靜默丟棄坑）
   - `getBirthDescriptor("world", "Maj'Eyal").descriptor_choices.class.Witch = "allow"`
4. `data/talents/spell/herbalism.lua` — 草藥樹 4 技（主題參考 verdant 的 `cunning/herbalism` 但做成女巫自己的版本）：
   - **藥草知識**（被動）：毒/疾病抗性 + 治療加成
   - **調配藥劑**（主動）：製作增益藥水（速度/專注/韌性擇一，像 verdant 的 Draughts 但簡化成一個技能）
   - **藥毒**（主動）：遠程毒性攻擊/降益（要有主動輸出，否則一棵樹的職業打不死怪）
   - **女巫工坊**（被動或持續）：強化前三者的 master talent
5. `data/locales/zh_hant.lua` — `t("Witch", "女巫", "birth descriptor name")` + 天賦名翻譯

**流程**：lint → verify → playtest（建角 + 實際放技 + probe 驗證數值）→ 通過後 build + deploy → 手感列 `WAIT_USER.md`。過程中把「全新 class 需世界白名單」等新結論補進 `docs/knowledge/`（附行號）。

---

## 7. 我缺什麼資訊／哪裡文件不清楚（白話版）

**文件缺口（影響做法，我已有解但值得你知道）：**

1. **「全新 class」在 repo 裡沒有成文指引。** `docs/knowledge/class-parts/01` 只教「子職業掛進既有 class」；「`type="class"` + 世界白名單」是我從 `worlds.lua:36-50`（`__ALL__="disallow"`）和 neka 範本挖出來的。這個坑沒寫進知識層——做的時候我會順手補進去。
2. **neka 的 Avatar 是唯一完整 class 範本**，但它的設計（限定種族、禁用銘文）很特例，不是乾淨的通用範本；跑 playtest 時自動建角對全新 class 是否完全順暢，我沒有 100% 把握，實測才知道。

**需要你拍板的設計決定（影響 birth 描述子與技能數值）：**

3. **資源**：女巫用現成的法力（最省事，草藥樹走 `spell/` 型別）？還是做自訂資源池（像 runewright 的符文充能，但要連帶做隱藏被動池天賦，多一層功夫）？我建議**先法力**。
4. **草藥樹的 4 技設計**：上面第 6 點是我擬的，你有沒有指定想要的效果？尤其「女巫的特色」——是毒、是藥、是魔藥，還是混合？
5. **起手可玩性**：只有一棵樹時，草藥樹必須自帶「輸出+防禦+回復」才玩得動；或者你想讓女巫同時有 `technique/combat-training` 這種通用保命樹？你説「先只做一棵」，我預設就真的只給一棵、靠技能本身撐。
6. **職業圖示/立繪**：新 class 缺 `class-icons/witch_*` 圖會自動退回 unknown 圖示。先不做美術（你用不用得下去再説），還是你有素材想法？
7. **種族**：全種族可選，還是限定（如人類/精靈）？法師系職業通常全開。

**其他小事**：正體中文優先（repo 慣例）、Infinite/Arena 世界要不要開放（neka 範本預設關）、`allow_random=true` 讓隨機 boss 也能拿到草藥樹（我預設開）。

我的建議：**先把骨架+草藥樹照我的提議做出來、跑完整驗證讓你看得見東西**，數值與美術再依你的回饋迭代——這樣你至少先有可玩的雛形，而不是停在設計討論。你覺得呢？
```

耗時 171 秒，退出碼 0


---

## 步驟 2 — 精簡指令：自己決定並做完

### 注入的 stdin

```text
設計上的事你自己決定，不用問我，照你第 6 點的計畫做。

規則：能自己查、自己試、自己決定的，就不要停下來問。只有在「做下去會不可逆地弄壞使用者環境」時才停下來問。

現在開始動手，一路做到驗證通過：
1. 寫出 addon
2. tools/lint.sh 過
3. tools/verify.sh 過（貼出輸出）
4. tools/playtest.sh 真的建出女巫、真的學到草藥樹、真的放技能看到數值變化

做壞了沒關係，這是實驗，我隨時可以 git restore。

補充：如果需要生成文本或圖像（例如職業圖示、背景故事），機器上有 `agy` CLI 可以用（`agy -p "..."`）。但美術非必要，缺圖示不影響驗證，自己判斷要不要做。
```

### pi 的回應

```text
全部完成。總結如下：

## 完成項目

**新增 addon：`self_mods/tome-witch/`**（5 個檔）

| 檔案 | 內容 |
|---|---|
| `init.lua` | 身分（short_name=witch、version 1.7.6 相容、weight=100） |
| `hooks/load.lua` | `ToME:load` 手動 loadDefinition：天賦 → 職業；結尾 selfcheck |
| `data/birth/classes/witch.lua` | **全新 class**（type="class" + subclass + 三世界白名單） |
| `data/talents/spell/herbalism.lua` | 草藥樹四技：藥草知識（被動）/ 女巫魔藥（毒彈）/ 生命藥露（回血）/ 草藥大師（強化） |
| `data/locales/zh_hant.lua` | 職業顯示名「女巫」 |

## 驗證輸出

**① lint**：`5 個 .lua 語法通過`＋`init.lua 欄位通過` → 退出碼 0。

**② verify**：
```
[WITCH] selfcheck tree = OK
[WITCH] selfcheck class = OK
[WITCH] selfcheck subclass = OK
[WITCH] selfcheck worlds = OK
「witch」hook complete，4 項 selfcheck 全過。
[ OK ] 驗收通過
```

**③ playtest**（Xvfb 無頭，`--birth Human/Cornac/Witch/Witch`）：
```
[PROBE.STATE] name=autotest Cornac/Witch lvl=1 zone=trollmire hp=90/90
[PROBE.TALENTS] T_MANA_POOL=2 / T_WITCH_BREW=1 / T_WITCH_HERB_LORE=1   ← 草藥樹已學
[WITCH] poison_immune=0.2 disease_immune=0.2 healing_factor=1.1 mana=110/110  ← 被動生效
[WITCH] draught hp 90 -> 55 -> 90 regen=table   ← 生命藥露：回血 35 且 regen 效果在
[WITCH] casted at snake pre=16（隨後 log 出現「巨型棕蛇中毒了！」→ 蛇死亡消失）  ← 魔藥命中+毒殺
```

**④ build**：`BUILT self_mods/build/tome-witch.teaa (12K, 12 個檔案)`。
**⑤ deploy**：已裝到 `~/.t-engine/4.0/addons/tome-witch/`（可 `--undeploy` 移除），進遊戲選「女巫」即可玩。

## 順手做的事

- **新知識寫回真相層**：`docs/knowledge/class-parts/01-birth-and-talents.md` 新增「全新 class 比子職業多兩道白名單閘門」（含 `worlds.lua:20-62` 行號）——這是 repo 原本文件缺的一塊。
- **CODE_MAP** 補 `tome-witch` 分節；**WAIT_USER.md** 列手感/平衡待你實機確認；**SESSION-LOG.md** 記進度。

## 途中踩的坑（已解決，非 addon bug）

- `--birth` 的種族要用 descriptor 英文原名（`Human` 大寫；小寫 `human` 會在建角 setTile 炸掉）
- `p:takeHit` 被 Player 覆寫需要 src（改用直接改 `p.life` 測回血）
- `projectile` 是飛行彈道，傷害要等主迴圈結算（讀太快會看到 0 傷害）

截圖在 `/tmp/tome4-playtest/shots/`（`p_ingame.png` 是建角後畫面），要看你隨時可開。已知限制：目前只有草藥一棵樹，起手 3 點用完後升級點數沒地方花——這本來就是「先做一棵」的範圍，等你玩過再決定下一棵要做什麼。
```

耗時 1282 秒，退出碼 0
