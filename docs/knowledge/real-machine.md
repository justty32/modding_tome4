# 實機：佈署到使用者的家目錄、在真桌面開遊戲

> 目標版本 **ToME 1.7.6**，Linux / Manjaro / Wayland。全部經實測驗證（2026-07-10）。
> 這一層跟 [headless-testing.md](headless-testing.md)、[playtesting.md](playtesting.md) **不是同一個 home**。看清楚。

## 0. 最容易犯的錯：測了老半天，東西根本沒進使用者的 home

`verify.sh` 與 `playtest.sh` 都呼叫 `prepare_scratch_home`，各自建一個**拋棄式**的 home
（`tools/lib/scratch.sh:19`），把 addon 複製進去、跑完就丟。

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

## 5. 滑鼠滾輪在 Linux 上全死：自帶的 SDL 2.0.3 太舊（2026-08-06 查清並修好）

**症狀**：遊戲裡**每一處**吃滾輪的 UI 都沒反應——背包／裝備清單、左下訊息列、天賦樹、
快捷列換頁。使用者回報「在 Windows 上明明有用」。
（注意：**地圖上滾輪本來就沒功能**，縮放那段在 `engine/interface/PlayerMouse.lua:148-150`
是被註解掉的，別拿地圖當測試點。）

**判斷方向的第一步**：Lua 層兩平台是同一份程式碼，收滾輪的地方有 20 幾處
（`engine/ui/List.lua:76-77`、`engine/LogDisplay.lua:202-203`、`engine/HotkeysDisplay.lua:193`…），
所以「Windows 有、Linux 沒有」的差異**只可能在 C／SDL 輸入層**。

**成因**：遊戲自帶 SDL **2.0.3**（2014 年；`strings lib64/libSDL2-usemeyousilly-2.0.so.0`
可見 `SDL2-2.0.3`、`hg-8628:b558f99d48f0`、建置路徑 `/opt/SDL2-2.0.3/`）。
它的 `src/video/x11/SDL_x11events.c` 判滾輪的方式是：

```c
static SDL_bool X11_IsWheelEvent(Display *display, XEvent *event, int *ticks) {
    XEvent relevent;
    if (X11_XPending(display)) {                      // 佇列裡「當下」得有東西
        if (X11_XCheckIfEvent(display, &relevent, X11_IsWheelCheckIfEvent, (XPointer) event)) {
            if (event->xbutton.button == Button4) *ticks = 1;
            else if (event->xbutton.button == Button5) *ticks = -1;
            return SDL_TRUE;
        }
    }
    return SDL_FALSE;
}
case ButtonPress: {
    int ticks = 0;
    if (X11_IsWheelEvent(display, &xevent, &ticks)) SDL_SendMouseWheel(data->window, 0, 0, ticks);
    else SDL_SendMouseButton(data->window, 0, SDL_PRESSED, xevent.xbutton.button);  // ← 退化
}
```

**只有在 ButtonPress 進來的那一瞬間、配對的 ButtonRelease 已經躺在 X 事件佇列裡**，
才會發出 `SDL_MOUSEWHEEL`；否則走 else 分支發成普通按鍵 4／5，Lua 端收到的是
`button4`／`button5`（`engine/KeyBind.lua:197` 的 `sym:gsub("button","b")` 證明 `buttonN`
是引擎的正規命名），而**沒有任何 UI 在監聽 `button4`** → 那一格滾動無聲消失。
Windows 走 `WM_MOUSEWHEEL`，沒有這個配對條件，所以一直是好的。
**SDL 2.0.5 起改成無條件認 button 4-7**（順帶才有橫向滾輪；引擎早就有 `wheelleft`/`wheelright`
這兩個名字，但 2.0.3 根本產不出來）。

**實測（Xvfb + Lua 間諜 monkeypatch `engine.Mouse:receiveMouse`，同一套注入 protocol）**：

| 組 | SDL | 注入 | 結果 |
|---|---|---|---|
| B | 自帶 2.0.3 | `xdotool mousedown 4` → 0.3s → `mouseup 4` × 10 | **20/20 `button4`，0 次 `wheelup`** |
| C | 真 SDL2 2.32.10 | 完全相同 | **20/20 `wheelup`，0 次 `button4`** |

只換 SDL 一個變數 → 100% 翻轉。用 `xdotool click 4`（press+release 一起送）則時好時壞，
因為那剛好有機會滿足佇列條件——**所以測滾輪一定要用 `mousedown`/`mouseup` 拉開**，
`click 4` 會給你假的綠燈。

### 修法：`LD_PRELOAD` 攔事件佇列，**不要換 SDL**

```bash
tools/run.sh --build-wheel-fix   # 編一次就好
tools/run.sh                     # 之後自動掛上
```

源碼在 `tools/src/sdl_wheel_fix.c`（40 行）：攔 `SDL_PollEvent` / `SDL_WaitEvent`，
把 `SDL_MOUSEBUTTONDOWN(button=4..7)` 原地改寫成 `SDL_MOUSEWHEEL`、把配對的 UP 吞掉。
**SDL 2.0.3 與整條渲染路徑一個字節都沒動**，所以不可能影響畫面。順手把橫向滾輪
（button 6/7 → `wheelleft`/`wheelright`，引擎早就有這兩個名字）也接上了。

攔得到的理由：`nm -D --undefined-only t-engine64` 可見 `U SDL_PollEvent`、`U SDL_WaitEvent`，
LD_PRELOAD 的物件在全域符號搜尋順序上早於那份改名的 SDL。
結構偏移實測一致：`sizeof(SDL_Event)=56`、`wheel{type=0,timestamp=4,windowID=8,which=12,x=16,y=20}`。

無頭實測（同一套 `mousedown 4`/`mouseup 4` protocol）：
`RESULT=left,left, wheelup ×20, wheeldown ×10`（10 次上滾 + 5 次下滾）、0 個 `Lua Error`，
`/proc/<pid>/maps` 同時可見補丁與**原本那份** `libSDL2-usemeyousilly-2.0.so.0`。
一次滾動產生 2 個事件是引擎正常行為（`engine/Mouse.lua:111-113` 的 `delegate` 派
`button-down` 與 `button` 各一次），B 組的 `button4` 也是 20 個對 10 次注入。

**已知取捨**：綁在 button 4-7 上的按鍵繫結會失效。那些繫結在滾輪壞掉的狀態下本來就綁不起來。

### 換掉整個 SDL 也能修滾輪，但**在 NVIDIA 上畫面全白**（別走這條）

`tools/run.sh --make-sdl-shim` + `TOME_USE_SDL_SHIM=1` 保留了這條路，只為對照實驗。
原理是遊戲把 SDL 的 SONAME 改名成 `libSDL2-usemeyousilly-2.0.so.0` 以防被系統 SDL 覆蓋，
但改名只改檔名，動態載入器照檔名找 → `LD_LIBRARY_PATH` 裡放一份同名的新版就換掉了
（**不必動 Steam 安裝目錄**）。三個候選的實測結果：

| 候選 | 版本 | 底層 | 結果 |
|---|---|---|---|
| `/usr/lib/libSDL2-2.0.so.0` | sdl2-compat 2.32.70 | **SDL3**（dlopen `libSDL3.so.0`）| ❌ 滾輪好了，但**技能圖標與大量貼圖壞掉**（自帶的 `libSDL2_image` 是 2014 年的，表面格式對不上）；無頭還會挑 wayland driver，畫面不畫在給定的 `DISPLAY` 上（截圖只有 233 bytes）|
| Steam Runtime 的 `libSDL2-2.0.so.0` | release-2.32.10（真 SDL2、純 X11 編譯）| 真 SDL2 | ⚠️ 無頭 20/20 `wheelup`、截圖正常，但**使用者真實桌面全白**（RTX 5060 Ti / NVIDIA 610.43.03、全螢幕；遊戲邏輯照跑，log 裡玩家在放技能、怪在行動，只有 GL 輸出壞）|
| archive.archlinux.org 的 `sdl2-2.0.10-1-x86_64.pkg.tar.xz` | 2.0.10（2019）| 真 SDL2 | 無頭 20/20 `wheelup`、截圖 490KB/746KB 正常；真實桌面未採用（已改走 preload）|

**教訓**：2.0.3 → 2.32 跨了十年的 GL context／FBO 行為差異，無頭（softpipe）驗不出來——
`LIBGL_ALWAYS_SOFTWARE=1` 的 Xvfb 跟真實 NVIDIA 驅動是兩條不同的 GL 路徑。
**「無頭截圖不是 233 bytes」只能證明沒有完全不畫，不能證明畫得對。**

（`--make-sdl-shim` 那條路另外把 `SDL_VIDEODRIVER=x11` 釘住，因為 2.0.10 與 sdl2-compat
都把 wayland／KMSDRM 編了進去，不釘住可能被誤選。走 preload 就沒這問題——自帶的 2.0.3
本來就只有 X11。）

**認指紋**（要判斷某次啟動到底載到哪份 SDL）：

```bash
grep -i libSDL2- /proc/$(pgrep -x t-engine64 | head -1)/maps | awk '{print $6}' | sort -u
grep -a "Available video driver" <log>
#   x11 / dummy （只兩項）                          → 自帶 2.0.3 ← 走 preload 時應該看到這個
#   dummy / evdev / offscreen / x11                 → 真 SDL2 2.32.10（Steam Runtime）
#   dummy / KMSDRM / wayland / x11                  → 真 SDL2 2.0.10（arch 封存）
#   wayland / x11 / KMSDRM / offscreen / dummy / evdev → sdl2-compat（SDL3），不要用
```

走 preload 的正常樣貌：`maps` 裡**同時**有 `tome4-wheel-fix.so` 與
`.../TalesMajEyal/lib64/libSDL2-usemeyousilly-2.0.so.0`（原本那份 2.0.3 還在）。

**Steam 的「啟動選項」塞不進去，別浪費時間**：ToME 是跑在 Steam Linux Runtime
（pressure-vessel）容器裡的，容器會**重建**環境。實測從 Steam 啟動的行程
`/proc/<pid>/environ` 裡 `LD_LIBRARY_PATH` 全是 `SteamLinuxRuntime/var/steam-runtime/…` 與
`/usr/lib/pressure-vessel/overrides/…`，我們設的路徑不見了。要修滾輪就走 `tools/run.sh`。
