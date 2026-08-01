---
name: tome4-addon
description: 開發、檢查、打包、佈署、無頭測試 Tales of Maj'Eyal (ToME 4) 的 addon/mod。當使用者要做或修改 ToME4 / t-engine4 的 mod——新職業、新技能、新物品、新 UI 面板、平衡調整——時使用。也在需要驗證某個 ToME addon 是否真的能載入時使用。
---

# ToME4 addon 開發

工作區：`~/repo/moddings/tome4/`（以下路徑皆相對於此）

## 鐵律（先讀，違反會壞事）

1. **絕不擅自在真實桌面執行 `t-engine64`。** 它沒有 `--help`；任何參數都會直接開遊戲視窗，在使用者畫面上彈出對話框。自動化只透過 `tools/verify.sh` / `tools/playtest.sh` 跑遊戲，它們會綁到自己開的 Xvfb display。要在真桌面開遊戲或用真滑鼠鍵盤，**先問使用者**，再用 `tools/run.sh`。
2. **不要憑記憶寫 ToME 的 API。** 先讀 `knowledge/`，沒有的話去 `~/repo/moddings/tome4/vendor/t-engine4/` grep 原始碼，讀完把結論**附行號**補進 `knowledge/`。
3. **`~/repo/moddings/tome4/sub_proj/analysis/t-engine/` 不是權威**，只是索引。
4. **唯讀區**：`vendor/t-engine4/`、`~/.steam/.../TalesMajEyal/`、`~/repo/moddings/tome4/vendor/orig/`。
5. **佈署到 `~/.t-engine/4.0/addons/`**，不是 Steam 的 `game/addons/`。
6. 宣稱「能動」之前必須跑過 `tools/verify.sh` 並貼出輸出。沒跑就說沒跑。
7. **`verify.sh` / `playtest.sh` 跑的是拋棄式 scratch home。** 要交給使用者玩，得另外明確跑一次
   `tools/deploy.sh <addon>`（不帶 `--home`），否則他的遊戲裡什麼都沒有。
8. **使用者不能從 Steam 開遊戲**——引擎自身的工坊同步回呼會 SIGSEGV，與 addon 無關。
   用 `tools/run.sh`（帶 `--no-steam`）。詳見 `knowledge/real-machine.md`。

## 一條龍

```bash
tools/lint.sh   <addon>   # 語法 + init.lua 欄位語意
tools/deploy.sh <addon>   # 目錄形式佈署，改檔即生效
tools/verify.sh <addon>   # Xvfb 無頭啟動，確認真的載入且無 Lua Error
tools/playtest.sh start <addon> --cheat --birth default   # 自動建角進遊戲
tools/build.sh  <addon>   # 要交付 .teaa 時才跑
tools/run.sh              # 在使用者真桌面開遊戲（先問過才准跑）
```

`<addon>` 可以是 `runewright`、`tome-runewright` 或完整路徑。
每支腳本都吃 `-h`；決策表與工具鏈佈局見 **`tools/README.md`**。

開發時走 `lint → deploy → verify` 短迴圈。`verify.sh` 約需 1–3 分鐘（真的把遊戲開起來點過主選單）。

## verify 綠燈不等於做完

`verify.sh` 只證明：addon 被載入、定義註冊成功、載入過程沒有 Lua Error。
**它證明不了遊戲邏輯是對的。**

2026-07-10 盧恩術士在 verify 7/7 全綠時，實機遊玩仍抓到三個 bug：共鳴判定拿已翻譯的
`t.name` 比對英文（中文語系永不成立）、起始銘文因欄位滿被靜默丟棄、符文字符是豆腐方塊。

**只要改動觸及遊戲邏輯（天賦效果、資源、判定、UI 文字），就要跑 playtest。**

```bash
tools/playtest.sh start <addon> --cheat --birth default   # 自動建角，直接停在遊戲內
tools/playtest.sh probe --list           # 看有哪些探測
tools/playtest.sh probe logmirror        # ★ 先裝：之後每條遊戲訊息都變成純文字
tools/playtest.sh probe state            # 我是誰、我在哪、剩幾點天賦
tools/playtest.sh probe actors           # 本層生物（名稱/座標/血量/距離）
tools/playtest.sh probe attack "large white snake"   # 打它，印前後血量與傷害
tools/playtest.sh stop                   # 一定要收尾
```

`--birth` 也吃 `<race>/<subrace>/<class>/<subclass>`（英文原名），例如
`--birth Elf/Shalore/Mage/Archmage`——**測自訂職業就用這個**。

**取得狀態一律用 `probe`／`lua`（回傳純文字），不要靠讀截圖判斷。**
截圖照產，但那是**給使用者看的**：畫面、渲染、手感、平衡由使用者判斷，
那是人眼比 AI 可靠的地方，而且圖片很吃 token。要秀畫面就把路徑給使用者。

探測手法全集與原理：`knowledge/playtesting-parts/03-state-probes.md`。
要加新的固定手法，就在 `tools/probes/` 放一支 `.lua`（規矩見 `tools/README.md`），
不要每次手打 `lua '<一行>'`。

看不到的內部狀態**不要猜**——在 superload/hook 塞暫時的 `print`，跑一輪用 `playtest.sh log` 撈出來，
看完刪掉再重跑 lint + verify。那三個 bug 全是這樣抓到的。

## 三個會浪費你半天的坑

這三個都已經被 `tools/lua/check_init.lua` 自動擋下，但你要知道為什麼：

1. **addon 的 `data/` 不會被自動掃描。** 它掛在私有的 `/data-<short_name>/`（`engine/Module.lua:498-503`），不是合併進 `/data`。所有 `birth/classes`、`talents`、`timed_effects` 都必須在 `hooks/load.lua` 的 `ToME:load` hook 裡手動 `loadDefinition`。**唯一例外是 `data/locales/*.lua`，那個會自動載入。**
2. **`version` 與模組不相容時，addon 是靜默消失的**，沒有任何錯誤訊息（`engine/Module.lua:390` → `:595`）。對 1.7.6 而言 `{1,7,6}` 可以，`{1,7,7}` 不行。
3. **`weight` 漏填會讓整個 addon 清單載入崩潰**（`engine/Module.lua:437` 拿 `nil` 去比較），連帶弄壞使用者所有其他 addon。

其餘坑見 `knowledge/README.md` 的「這個引擎很愛靜默失敗」總表。

## 讓 addon 自報，不要判讀畫面

在 `hooks/load.lua` 結尾 `print` 可驗證的事實，`verify.sh` 靠 grep 判定：

```lua
print(("[MYMOD] selfcheck %s = %s"):format(name, ok and "OK" or "FAIL"))
print("[MYMOD] hook complete")
```

範例：`mods/tome-runewright/hooks/load.lua` 結尾。

## 知識層

| 檔案 | 內容 |
|---|---|
| `knowledge/README.md` | 索引；先讀這份 |
| `knowledge/addon-loading.md` | init.lua 欄位、私有掛載、版本、weight |
| `knowledge/class-and-talents.md` | Birther、newTalent、自訂資源、i18n |
| `knowledge/visuals-and-sounds.md` | 粒子、音效、圖示 |
| `knowledge/headless-testing.md` | Xvfb 啟動、為何跳不過主選單、預裝 addon 地雷 |
| `knowledge/playtesting.md` | 實機遊玩、座標速查、TEMP-DEBUG |

## 要做新職業

讀 `.claude/skills/tome4-class/SKILL.md`。

## 真實範例

- `mods/tome-runewright/` — 本工具鏈做的職業
- `~/repo/moddings/tome4/vendor/orig/{arcanum,nullpack,midnight}/` — 實裝過的第三方職業包（唯讀）
