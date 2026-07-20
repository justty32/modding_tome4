# 實機：佈署到使用者的家目錄、在真桌面開遊戲

> 目標版本 **ToME 1.7.6**，Linux / Manjaro / Wayland。全部經實測驗證（2026-07-10）。
> 這一層跟 [headless-testing.md](headless-testing.md)、[playtesting.md](playtesting.md) **不是同一個 home**。看清楚。

## 0. 最容易犯的錯：測了老半天，東西根本沒進使用者的 home

`verify.sh` 與 `playtest.sh` 都呼叫 `prepare_scratch_home`，各自建一個**拋棄式**的 home
（`lib_scratch.sh:26`），把 addon 複製進去、跑完就丟。

**它們從來不碰 `~/.t-engine/4.0/addons/`。**

所以：

| 現象 | 意義 |
|---|---|
| `verify.sh` 全綠、`playtest.sh` 建得出角色 | 只證明 addon 在 scratch home 裡是好的 |
| 使用者從自己的遊戲進選角，看不到新職業 | 你**沒有** `deploy.sh` 到真 home |

2026-07-10 實測：盧恩術士三層驗證全綠、使用者開遊戲卻找不到職業，
原因是 `~/.t-engine/4.0/addons/` **根本不存在**。

**交付給人玩之前，必須明確跑一次：**

```bash
tools/deploy.sh <addon>          # 預設就是佈署到 $TOME_ADDONS_DIR（真 home）
```

`deploy.sh` 只有在帶 `--home <dir>` 時才寫去別的地方（`deploy.sh:33-35`）。

佈署後**必須完全離開遊戲再重開**。PhysFS 掛載的是啟動當下的目錄樹，
回主選單不會重掃 addon。

確認佈署成功，看 log 這三行（缺一就是沒載到）：

```
Checking addon	tome-<short_name>	:: (as dir)	true	:: (as teaa)	nil
Binding addon	<Long Name>	nil	tome-<short_name>-1.7.6
[<SHORT_NAME>] hook complete
```

## 1. 從 Steam 啟動會 SIGSEGV（與你的 addon 無關）

**症狀**：從 Steam 點「遊戲」，視窗閃一下就沒了，`~/.t-engine/4.0/tome/error-logs/`
**不會**留下任何東西——因為它不是 Lua Error，是原生層 core dump。

**確診**（`coredumpctl list` 找到 t-engine64 的那筆）：

```
#1  lua_rawgeti
#2  lua_steam_grab_subscribed_addons_cb
#3  TE4FileSubcribed::OnDetails      (或 ::OnDownloaded)   libte4-steam.so
#7  SteamAPI_RunCallbacks
#8  on_redraw
```

**成因**：t-engine 用 Steam RemoteStorage 同步「已訂閱的創意工坊 addon」，
把它們下載進 `game/addons/`（注意 log 裡 `game/addons/` 是 WRITEPATH）。
下載／查詢完成的回呼由 `on_redraw` 每幀跑的 `SteamAPI_RunCallbacks` 派送，
而它取用的 Lua registry ref 屬於**已經被 `[MAIN] rebooting lua state` 重建掉的 Lua state**，
於是 `lua_rawgeti` 踩空。啟動後兩秒內必炸，**連 `Checking addon` 都還沒印出來**。

**判別它不是你的鍋**：Steam 的 console log（`~/.steam/steam/logs/console-linux.txt`）
裡沒有任何 `Checking addon`、也沒有你 addon 的 selfcheck 行。遊戲根本沒走到掃 addon。

**繞過**：不要從 Steam 開，直接跑執行檔加 `--no-steam`。
只關掉工坊同步與成就上傳；`game/addons/` 底下已下載的 `.teaa` 照樣載入
（實測 45 個全數載入、進得了選角）。

## 2. 在真桌面開遊戲

> **先問使用者。** 這是本工作區的硬規矩，不管當下多方便。
> 虛擬螢幕（Xvfb）不必問。

使用者的桌面是 **Wayland + XWayland**，所以：

- `DISPLAY` 是 **`:1`**，不是 `:0`。`:0` 上是 sddm 的 Xorg（`-auth /run/sddm/xauth_*`，你沒權限）。
- 必須帶 `XAUTHORITY=/run/user/1000/xauth_XXXXXX`（檔名隨機，每次開機不同）。

漏掉任何一個，SDL 會說：

```
Authorization required, but no authorization protocol specified
Error initializing SDL video:  No available video device
```

**別猜，去問一個活著的 GUI 行程**：

```bash
p=$(pgrep -u "$UID" -x plasmashell | head -1)
tr '\0' '\n' < /proc/$p/environ | grep -E '^(DISPLAY|XAUTHORITY)='
```

包好的版本是 `tools/run.sh`。

## 3. 真桌面 log 的價值

`tools/run.sh` 把 stdout 導進檔案，且**不加 `--no-debug`**，
所以 addon 的 `print` 全都在裡面。使用者實機遊玩時：

- 不必請他截圖，直接 grep log 看技能有沒有觸發、共鳴有沒有算對。
- 崩潰時先看 log 尾巴有沒有 `Lua Error`；沒有就去 `coredumpctl`，那是原生層的問題。

## 4. 不要碰的東西

- `~/.steam/.../TalesMajEyal/`：遊戲安裝，唯讀。
- `~/.t-engine/4.0/settings/addons.cfg`、`~/.t-engine/4.0/tome/save/`：使用者的設定與存檔。
  要鏡像他的 addon 組合來重現問題，**複製**這個檔到 scratch home，不要改原檔。
