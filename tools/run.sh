#!/usr/bin/env bash
# 在**使用者的真實桌面**開遊戲（不是 Xvfb），用真實 home，stdout 導進 log。
# 用法：
#   tools/run.sh                 # 開遊戲
#   tools/run.sh --log           # 印出目前 log 路徑
#   tools/run.sh --tail [regex]  # 追 log（預設只印 addon 自報的行）
#   tools/run.sh --stop
#   tools/run.sh --build-wheel-fix # 編修滑鼠滾輪的 LD_PRELOAD 補丁（一次就好）
#   tools/run.sh --make-sdl-shim   # 對照實驗用：改成換掉整個 SDL（預設不走這條）
#
# ⚠️ 這會在使用者眼前彈出視窗。**執行前必須先問過使用者。**
#    純自動化驗證請用 tools/verify.sh / tools/playtest.sh（Xvfb，不必問）。
#
# 為什麼一定要 --no-steam：
#   從 Steam 啟動時，t-engine 的工坊同步回呼（lua_steam_grab_subscribed_addons_cb）
#   會在 Lua state 重建後才被 SteamAPI_RunCallbacks 派送，必定 SIGSEGV。
#   詳見 docs/knowledge/real-machine.md §1。
#
# 為什麼不寫死 DISPLAY=:0：
#   使用者桌面是 Wayland，X 是 XWayland（通常 :1），且需要 XAUTHORITY。
#   一律從活著的 GUI 行程的 /proc/<pid>/environ 讀出來。
#
# 為什麼要掛 LD_PRELOAD（滑鼠滾輪）：
#   遊戲自帶 SDL 2.0.3（2014），它判滾輪的方式是只有在 ButtonPress 進來的那一瞬間、
#   配對的 ButtonRelease 已經在 X 事件佇列裡才發 SDL_MOUSEWHEEL，否則退化成「第 4／5 顆
#   按鍵被按下」→ Lua 收到 button4／button5，而沒有任何 UI 在監聽那個名字 → 滾輪全死。
#   在 XWayland 上這個競態幾乎必然觸發。
#   修法是 tools/src/sdl_wheel_fix.c：攔 SDL_PollEvent／SDL_WaitEvent 把 button 4-7 原地
#   改寫成滾輪事件，**SDL 與整條渲染路徑一個字節都不動**。
#   （換掉整個 SDL 也能修滾輪，但實測 2.32 在 NVIDIA 全螢幕下畫面全白。）
#   詳見 docs/knowledge/real-machine.md §5。

source "$(dirname "$0")/lib.sh"
handle_help_flag "$@"
require_game

RUN_LOG="${RUN_LOG:-/tmp/tome4-run/run.log}"
TOME_SDL_SHIM="${TOME_SDL_SHIM:-$HOME/.local/lib/tome4-sdl-shim}"
TOME_WHEEL_FIX="${TOME_WHEEL_FIX:-$HOME/.local/lib/tome4-wheel-fix.so}"

# 掛滾輪補丁（預設路徑；見檔頭與 tools/src/sdl_wheel_fix.c 的檔頭）。
enable_wheel_fix() {
    if [ ! -e "$TOME_WHEEL_FIX" ]; then
        warn "沒有滾輪補丁（$TOME_WHEEL_FIX）→ 滑鼠滾輪會是壞的"
        warn "編一次就好：tools/run.sh --build-wheel-fix"
        return
    fi
    export LD_PRELOAD="$TOME_WHEEL_FIX${LD_PRELOAD:+:$LD_PRELOAD}"
    info "滾輪補丁：$TOME_WHEEL_FIX"
}

build_wheel_fix() {
    local src="$(dirname "$0")/src/sdl_wheel_fix.c"
    [ -f "$src" ] || die "找不到原始碼：$src"
    command -v gcc >/dev/null || die "沒有 gcc"
    mkdir -p "$(dirname "$TOME_WHEEL_FIX")"
    gcc -shared -fPIC -O2 -Wall -Wextra -o "$TOME_WHEEL_FIX" "$src" -ldl || die "編譯失敗"
    # 攔不到就等於沒修，所以這裡一定要檢查符號真的匯出了。
    local got
    got="$(nm -D --defined-only "$TOME_WHEEL_FIX" | grep -cE " T (SDL_PollEvent|SDL_WaitEvent)$")"
    [ "$got" = "2" ] || die "符號沒匯出（SDL_PollEvent／SDL_WaitEvent 只找到 $got 個）"
    ok "滾輪補丁已編好：$TOME_WHEEL_FIX（SDL_PollEvent／SDL_WaitEvent 皆已匯出）"
}

# ── 以下是「換掉整個 SDL」的舊路，預設不用 ────────────────────────────────
# 它也能修滾輪（無頭實測 2.0.10 與 2.32.10 都 20/20），但**實測 2.32 在使用者的
# NVIDIA GPU 全螢幕下畫面全白**（遊戲邏輯照跑，只有 GL 輸出壞）。留著是為了對照實驗，
# 要用得自己開：TOME_USE_SDL_SHIM=1 tools/run.sh
#
# 遊戲把 SDL 的 SONAME 改名成 libSDL2-usemeyousilly-2.0.so.0 以防被系統 SDL 覆蓋，
# 但改名只改檔名，動態載入器照檔名找 → 同名的新版放進 LD_LIBRARY_PATH 就換掉了。
# **不需要動 Steam 安裝目錄**（那是唯讀區）。
enable_sdl_shim() {
    local lib="$TOME_SDL_SHIM/libSDL2-usemeyousilly-2.0.so.0"
    if [ ! -e "$lib" ]; then
        warn "沒有 SDL shim（$lib）→ 用自帶的 2.0.3，滑鼠滾輪會是壞的"
        warn "建立方式：tools/run.sh --make-sdl-shim"
        return
    fi
    export LD_LIBRARY_PATH="$TOME_SDL_SHIM${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    # 自帶的 2.0.3 只編了 X11，遊戲一直是走 XWayland 的。把 backend 釘在 x11，
    # 確保換 SDL 之後唯一變的就是滾輪那段程式碼，不會連視窗系統都換掉。
    export SDL_VIDEODRIVER=x11
    info "SDL shim：$(basename "$(readlink -f "$lib")")（$TOME_SDL_SHIM）"
}

# 用 Steam Runtime 那份**真正的** SDL2 建 shim。
# 為什麼不用 /usr/lib/libSDL2-2.0.so.0：那是 sdl2-compat，底層 dlopen libSDL3.so.0，
# 實測滾輪會好但**技能圖標與大量貼圖會壞掉**——遊戲自帶的 libSDL2_image 是 2014 年的，
# 配 SDL3 後端的表面格式對不上。Steam Runtime 那份是 release-2.32.10、純 X11 編譯。
# 是「複製」不是 symlink，這樣 Steam 更新換掉 runtime 也不會把這裡弄壞。
make_sdl_shim() {
    local src="" c
    for c in "$HOME/.local/share/Steam/ubuntu12_32/steam-runtime/usr/lib/x86_64-linux-gnu/libSDL2-2.0.so.0" \
             "$HOME/.steam/steam/ubuntu12_32/steam-runtime/usr/lib/x86_64-linux-gnu/libSDL2-2.0.so.0"; do
        [ -e "$c" ] && { src="$c"; break; }
    done
    [ -n "$src" ] || die "找不到 Steam Runtime 的 libSDL2（需要 ≥ 2.0.5 的真 SDL2）"
    mkdir -p "$TOME_SDL_SHIM"
    cp "$src" "$TOME_SDL_SHIM/libSDL2-usemeyousilly-2.0.so.0"
    chmod 755 "$TOME_SDL_SHIM/libSDL2-usemeyousilly-2.0.so.0"
    ok "shim 已建立：$TOME_SDL_SHIM ← $src"
    info "版本：$(strings -a "$TOME_SDL_SHIM/libSDL2-usemeyousilly-2.0.so.0" | grep -Eo 'release-2\.[0-9.]+' | sort -u | head -1)"
    LD_LIBRARY_PATH="$TOME_SDL_SHIM" ldd -r "$TOME_GAME_DIR/t-engine64" 2>&1 \
        | grep -iE "undefined|not found" && die "符號解析失敗，shim 不可用" \
        || ok "符號複驗：0 個 undefined、0 個 not found"
}

# 從任一個使用者的 GUI 行程繼承 DISPLAY / XAUTHORITY
detect_x_env() {
    local p=""
    for name in plasmashell gnome-shell xfce4-session kwin_wayland; do
        p="$(pgrep -u "$(id -u)" -x "$name" 2>/dev/null | head -1 || true)"
        [ -n "$p" ] && break
    done
    [ -n "$p" ] || die "找不到桌面工作階段行程，無法推斷 DISPLAY／XAUTHORITY"
    X_DISPLAY="$(tr '\0' '\n' < "/proc/$p/environ" | sed -n 's/^DISPLAY=//p' | head -1)"
    X_AUTH="$(tr '\0' '\n' < "/proc/$p/environ" | sed -n 's/^XAUTHORITY=//p' | head -1)"
    [ -n "$X_DISPLAY" ] || die "該行程沒有 DISPLAY，桌面可能是純 Wayland 無 XWayland"
}

case "${1:-start}" in
    --log)
        echo "$RUN_LOG" ;;
    --tail)
        [ -f "$RUN_LOG" ] || die "還沒有 log：$RUN_LOG"
        grep -nE "${2:-\[[A-Z-]+\] (selfcheck|hook|dbg)|Lua Error}" "$RUN_LOG" || warn "沒有符合的行" ;;
    --stop)
        # t-engine64 不理 SIGTERM（實測：送了 TERM 之後 10 秒仍在跑），必須升級到 SIGKILL。
        pkill -x t-engine64 2>/dev/null || true
        for _ in $(seq 10); do pgrep -x t-engine64 >/dev/null || break; sleep 0.5; done
        if pgrep -x t-engine64 >/dev/null; then
            pkill -9 -x t-engine64 2>/dev/null || true
            for _ in $(seq 10); do pgrep -x t-engine64 >/dev/null || break; sleep 0.5; done
        fi
        pgrep -x t-engine64 >/dev/null && die "殺不掉 t-engine64" || ok "已停止" ;;
    --build-wheel-fix)
        build_wheel_fix ;;
    --make-sdl-shim)
        make_sdl_shim ;;
    start)
        pgrep -x t-engine64 >/dev/null && die "遊戲已經在跑了（先 tools/run.sh --stop）"
        detect_x_env
        if [ "${TOME_USE_SDL_SHIM:-0}" = "1" ]; then
            warn "TOME_USE_SDL_SHIM=1：走換掉整個 SDL 的舊路，畫面可能全白（見檔頭）"
            enable_sdl_shim
        else
            enable_wheel_fix
        fi
        mkdir -p "$(dirname "$RUN_LOG")"
        info "DISPLAY=$X_DISPLAY XAUTHORITY=$X_AUTH"
        info "log → $RUN_LOG"
        (
            cd "$TOME_GAME_DIR" || exit 1
            DISPLAY="$X_DISPLAY" XAUTHORITY="$X_AUTH" \
                setsid nohup ./t-engine64 --no-steam --flush-stdout \
                </dev/null >"$RUN_LOG" 2>&1 &
        )
        # 等它真的活起來；載入完整 addon 集約需 30 秒
        for _ in $(seq 60); do
            grep -q "MODULE LOADER] done loading module" "$RUN_LOG" 2>/dev/null && break
            pgrep -x t-engine64 >/dev/null || { warn "行程已結束"; tail -5 "$RUN_LOG"; exit 1; }
            sleep 1
        done
        ok "遊戲已啟動（$(grep -c 'Checking addon' "$RUN_LOG" 2>/dev/null || true) 個 addon 被掃到）"
        grep -E "\[[A-Z-]+\] hook complete" "$RUN_LOG" || warn "沒看到任何 addon 的 hook complete（可能還在載入）"
        ;;
    *) die "用法: tools/run.sh [start|--stop|--log|--tail [regex]|--build-wheel-fix|--make-sdl-shim]" ;;
esac
