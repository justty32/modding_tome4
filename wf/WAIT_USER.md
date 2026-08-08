# WAIT_USER — 等待使用者的事

只列需要使用者親自做/驗證才能繼續的 open 項。完成即移除，不留完成清單。

常見類型：

- 實機或 UI 手動驗證
- 外部帳號、權限、下載、授權
- 本機環境變數或工具安裝
- 不能由 agent 代跑的指令
- 高風險操作的確認

## Open

- **★ 用 `tools/run.sh` 開一次，確認滑鼠滾輪好了、而畫面沒被弄壞**（2026-08-06）。
  成因與修法都已查清，見 [real-machine.md §5](../docs/knowledge/real-machine.md)。
  **最終採用的是 `LD_PRELOAD` 補丁**（`tools/src/sdl_wheel_fix.c`），SDL 2.0.3 與整條渲染
  路徑一個字節都沒動，所以理論上不可能再白畫面。已編好，`tools/run.sh` 會自動掛。
  **要你判斷的是**：滾輪在四處（清單／訊息列／天賦樹／快捷列換頁）是否都活了、
  畫面／技能圖標一切正常。（若滑鼠有橫向滾輪，順手看看它是不是也活了。）
  走過的兩條死路別再試：**換成 sdl2-compat** → 貼圖壞；**換成真 SDL2 2.32** → 你實測全白；
  **Steam 啟動選項** → pressure-vessel 會重建環境，塞不進去。
  ⚠️ `tools/run.sh` 會在你桌面開視窗，**agent 執行前必須先問你**。

- **要不要追 `tome-steamwitch` 的建角崩潰？**（2026-08-06 使用者實機撞到）
  `Lua Error: ActorTalents.lua:553: Learning unknown talent: nil`，
  來自 `data-steamwitch/talents/magic/mysticbirthright.lua:125` 的 `on_learn`
  去學 `T_SWX_TOUCH_OF_CLOTHO` 而它是 nil。**與本 repo 無關、也與 SDL 無關**
  （那次啟動用的是自帶 2.0.3）。已查明：三個 `SWX_TOUCH_OF_*` 就定義在同一個檔的
  第 26/56/87 行，比呼叫它的第 125 行還早，紙上讀起來應該要能用；`tome-zomnibus`
  沒有夾帶副本、`tome-steamwitch-zh` 只有一個 locale 檔。所以是**你那 45 個 addon 的
  載入期干擾**，要繼續查只能逐個關 addon 二分。**要不要花這個時間由你決定。**

- **實機看 Fall from Heaven 大地圖與中層 import**（2026-08-08）。
  已拆 `/home/lorkhan/Downloads/FallfromHeaven2041n.exe`，分析與索引在
  [ffh-import](workflows/investigation/findings/ffh-import/README.md)。
  已做 `tome-fall-from-heaven` 第一版：把 Civ4 劇本
  `Assets/XML/Scenarios/The Black Tower.CivBeyondSwordWBSave` 轉成 ToME 第二張 wilderness 大地圖
  `Erebus: The Black Tower`，並抽出 9 座城市與 1 個 Lanun 登陸營地資料表。
  目前 `C` 城市格可進 `fall-from-heaven+city` 原型，`S` 起始格可進
  `fall-from-heaven+landing-camp` 原型；也有第一版大地圖 AI tick，能讓城市生產 warband、
  並把 AI 部隊投影成 worldmap marker；
  部隊朝敵城移動。第一批 FFH DDS unit button 已轉 PNG 並接到地標圖示；
  3D `.nif` 目前有 manifest，且其中 8 個已有 texture-derived proxy sprite，尚待 renderer 轉成真正 2D sprite。已 `lint`、`verify`、無頭底層生成測試、`probe ffh_ai_step`、
  `build`，並已 `tools/deploy.sh tome-fall-from-heaven` 到真 home。
  **要你判斷的是**：大地圖視覺是否像 FFH、地形轉譯是否合理、入口位置是否合適、
  城市/登陸營地中層原型的空間尺度與氣氛是否對。AI 已驗證載入與生成，
  但不替你做人眼畫面與遊玩節奏判斷。

- **★ 三份設計方案，兩題最關鍵的已拍板（2026-08-03），還剩細節待答**：
  1. ✅ **玩家是誰**（orario §4）：**B 同時代的另一名冒險者**。
  2. ✅ **三構想要不要合併**（orario §8）：**歐拉麗當試驗場**——先在歐拉麗做出 Falna，
     跑得通再抽成通用框架；organic-talents／crafting 的獨立實作先不動工。
  3. 待答：[生長式天賦](workflows/specs/organic-talents-design.md) §6：規模、「自我練習」怎麼累積
     （優先序排在 Falna 之後，不急）。
  4. 待答：[生產職業](workflows/specs/crafting-professions-design.md) §8：先做哪個職業、佔不佔天賦點
     （同上，不急）。
  5. 待答：[歐拉麗完全版](workflows/specs/orario-complete-design.md) §10 剩餘三題——做到第幾卷、
     巴別塔幾層、原文素材整理。

- **★ [型月魔術體系 fate-magecraft](workflows/specs/fate-magecraft-design.md) §16 五題**（2026-08-03 新增）。
  兩題最關鍵的已在該次對話拍板（主軸＝魔術師＋召喚兩層都要；取得＝區域門檻人人可學），剩下：
  1. **addon 名字**：`tome-magecraft`（機制取向）／`tome-clocktower`（地點取向）／其他。
  2. **開通回路的成本要多重**？走區域門檻＝人人可得，所以「不是白送」得靠成本
     （長跑腿？大筆錢？永久扣點什麼？）。這題直接決定平衡。
  3. **從者要不要具名**？公有領域的歷史／神話原型是安全的，但取什麼名字是文案品味題。
  4. **詠唱最長能接受幾回合**？這個數字決定 `formula.lua` 的節數表怎麼填。
  5. **Eyal 大地圖 (28,18) 可以嗎**？（歐拉麗 3×3 overlay 佔 24–26 × 17–19，這格是隔壁不重疊；
     但該格地形與有無撞到原版地點要在有 `vendor/` 的機器上確認。）

  另外**不是問你、是提醒你**：這份 spec §13 的最大風險（多回合詠唱在 roguelike 可能就是不好玩）
  只有實機手感能判斷。v0.3 做完會停下來請你試玩，**在你回覆之前不做 v0.4 以後任何內容**。

- **實機看一下歐拉麗**（市集三家店 + 三個眷族據點）。**已 deploy。**
  2026-08-01 修掉「入口被牆擋住進不去」：三棟建築原本被畫成密閉 3x3 盒子，
  傳送門格本身沒問題、周圍八格全是 HARDWALL。已在南牆開門口，
  並因為 zone 是 `persistent`（光改地圖對現有存檔無效）加了進場遷移。
  證據：六個方向的 A\* 全部有路、真的逐格走進去又走回來、三家店走得到也開得起來、
  verify 22/22、0 Lua Error。
  **要你判斷的是**：店裡賣的東西合不合理（進貨 filter 是 pi 挑的）、
  三個據點的氛圍與文案（世界觀取材《地錯》但沒還原人物）、
  見面禮 30/50/40 金幣會不會太甜。

- **看一下演出系統的節奏**（`tome-director` v0.2）。**已 deploy。**
  2026-08-01 依實機回報改了兩件事：**演出不再吃回合**（原本一段過場跑掉幾千上萬回合，
  連中毒／冷卻／飢餓都被快轉；驅動器換成 `Game:registerTimer`，實測 `turns_spent=0`），
  **台詞改走 ToME 原生對話框**（左右立繪，停下來等你按 Enter，不必再猜停留時間）。
  跳過鍵順勢改成 **Escape**——Enter 要留給翻台詞。
  無頭測試：38 項自我驗證全過（21 + 台詞框 7 + 讀檔復原 6 + 跳過 4）。
  **要你判斷的是**：走位速度（預設每格 150ms）會不會太慢／太快、
  鏡頭切換順不順、台詞框擋不擋畫面。在 Lua console 打：
  ```
  game.director:play("demo")
  ```
  （入口從 `rawget(_G,"__tome_director")` 改成 `game.director`，好打多了。）

- **實機試玩女巫森林 `tome-witchwood`**。**已 deploy。**
  2026-08-01 修掉兩件實機回報的事：
  1. **守根人葛薇卡在入口**——她被生成在入口樓梯格上，而入口是地圖邊緣、
     往內只有一格寬的隧道；加上她有 `never_move`（推不動）又有 `can_talk`
     （撞上去變成開對話，走不到交換位置那條分支）→ 玩家被她的身體完全封死。
     已改成自己掃地圖找「離入口 2 格以上、八方至少 5 格可走、且把她當牆時入口到下樓梯仍通」
     的位置。連續 4 張隨機圖都放置成功。順手給了她 `invulnerable`（她跑不掉也不還手，
     死了任務就永久拿不到）。
  2. **樹沒有去背**——兩張樹貼圖滿佈亮洋紅色斑點。病因是「AI 生圖 + `magick -fuzz` key 背景」
     產出的是 1-bit alpha，殘邊清不掉、清狠了又把樹幹鑿成蜂窩。已改成從原版美術資產
     衍生（`swamptree2` / `tree_dark_alpha3` 色調位移成詛咒紫），alpha 乾淨、風格一致。
  3. **樹沒有疊在地面上**（第二輪回報）——貼圖 alpha 是對的，錯在分層：
     一格只畫一個 TERRAIN 實體，引擎不會自動鋪地面，所以樹的透明處露出黑底。
     已改成原版寫法 `image =`地面`+ add_mos =`樹（`forest.lua:76,153` 全是這樣）。
     已實機拍圖確認樹確實疊在林地上。
  **要你判斷的是**：新的樹好不好看（見對話裡的 before/after 對照圖，
  不喜歡就換 src 檔名重跑一行 magick，原版有 485 張樹可挑）、
  瑞文谷（Derth）西北 (23,15) 入口有沒有出現、任務能不能完整走完。



- **實機確認女巫（手感／平衡）**。無頭測試證明：建角成功（Cornac/Witch）、草藥樹四技註冊、
  被動生效（毒/疾病免疫 20%、治療加成 +10%）、生命藥露回血（90→55→90＋regen）、
  女巫魔藥命中並毒殺 16HP 棕蛇（log：`巨型棕蛇中毒了`）。
  畫面、手感、數值平衡必須人眼看。
  已佈署 `tools/deploy.sh witch`（`~/.t-engine/4.0/addons/tome-witch/`），
  移除 `tools/deploy.sh witch --undeploy`。進遊戲選 class 分類「女巫」（Cornac/Witch）即可。
  目前只有草藥一棵樹（起手 3 點、升級會沒地方花點數是已知限制）。

- **盧恩術士特效殘留：稽核完畢，源碼裡沒有誤用——但查出 addon 當時是壞的**（2026-08-01）。
  15 個粒子呼叫點逐一回原始檔複驗：3 處 `arcane_power` 全是正確的
  `addParticles`／`removeParticles` 配對，`projectile()` 第 6 參數全是命中粒子，
  沒有女巫那種誤用。無頭實測 11 主動＋2 持續＋1 定時效果殘留數全回 0，
  且用「故意製造殘留」的正對照證明量尺有效。
  **真正的問題是別的**：`require("data.…")` 用在私有掛載點上，讓 hook 第 19 行就爆，
  整個職業沒註冊（已修，lint + verify 8/8 複驗過，知識已進 `addon-loading.md`）。
  → **要你做的**：實機看這五點，確認畫面上真的沒殘影（AI 不讀圖）。
    1. 開著 ᛉ Algiz 或 ᚹ Wunjo 走幾步——光環要**跟著人走**，不能留原地；關掉要**立刻消失**。
    2. ᚲ Kenaz / ᚺ Hagalaz 對遠處放，走開再走回來——落點不該有殘留亮點。
    3. ᛊ Sowilo 光束打完，路徑上不該留光。
    4. 開著持續技存檔→離開→讀檔，光環數不該變多。
    5. **反向問題**：ᛖ Ehwaz／ᚲ Kenaz／ᛟ Othala 的 buff 光環分別用 `ball_teleport`／
       `ball_fire`／`ball_arcane`（`data/timed_effects.lua:42,67,91`），這三個粒子**自己會停**，
       所以 buff 還在但光環一兩秒後就沒了。這是「該有的沒有」，要不要改成持續型是設計決定，agent 沒動。

- **實機確認盧恩術士（手感／平衡）**。無頭測試只能證明 addon 載入、定義註冊成功、沒有 Lua Error；
  畫面、手感、數值平衡必須人眼看。
  佈署 `tools/deploy.sh runewright`（裝到 `~/.t-engine/4.0/addons/tome-runewright/`），
  移除 `tools/deploy.sh runewright --undeploy`。進遊戲選 Mage → 子職業應出現「盧恩術士」。
  機制正確性已實機驗過（充能 13/13 → 0/13、泉湧共鳴讓法力回復 +0.5 顯示為 +1.00），
  但數值好不好玩只有你能判斷——特別是 ᛏ Tiwaz 吃光充能換傷害倍率的節奏。
  **這是 6 個 addon 升格 `self_mods/dist/` 批次的唯一卡關項**（見 [SESSION-LOG.md](SESSION-LOG.md)）。

- **`Odyssey of The Summoner` 這個既有 addon 是壞的**，與本 repo 無關。
  它在 New Game 時必定拋 `EFF_EXHAUSTION` 重複定義的 Lua Error
  （`neka_therianthropy_summoner/timed_effects/fire-drake.lua:216`），桌面版一樣會炸。
  你的 `~/.t-engine/4.0/settings/addons.cfg` 已把它設為 false，目前不影響遊玩——**別再打開**。

- **`.teaa` 暫存 build 的發佈策略未定**。`build/` 下的自製 addon 與
  `sub_proj/zh_mods/build/` 的 18 個在地化 `.teaa` 都屬「暫存 build，未升格 dist」，
  哪天要一起決定發佈策略。

- **實機確認 Fall from Heaven 大地圖/戰術層雛形**。**已 deploy。**
  目前 FFH 已能從 Civ4 `The Black Tower` worldbuilder 檔生成 84x52 ToME worldmap，
  Eyal 入口、9 城、Lanun 登陸營地、城市/營地中層 zone、Civ-style world AI、
  world unit sprite projection 都已接上。2026-08-08 追加：world unit 已升級為
  ToME `WorldNPC` actor，遭遇會落到 `fall-from-heaven+skirmish` 戰術場景；
  無頭 probe 證明 `placed=1 counted=1 actors=1 actor=true`，skirmish 場景生成
  4 個 FFH proxy 敵人。再下一步已接上 skirmish → world AI 回寫：
  `player_won` 會移除對應 world unit，probe 證明 `before=1 after=0 removed=true`；
  `player_retreat` 會保留 world unit，只記錄 retreat log，probe 證明 `before=1 after=1 removed=false`。
  **要你判斷的是**：FFH 大地圖比例、城市/營地/單位圖標可讀性、NIF texture proxy sprite 能不能先頂著用、
  以及「撞 world unit 進 skirmish」這個節奏是否符合你想要的三層地圖設計。
