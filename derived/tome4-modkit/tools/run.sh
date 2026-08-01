#!/usr/bin/env bash
# 在**使用者的真實桌面**開遊戲（不是 Xvfb），用真實 home，stdout 導進 log。
# 用法：
#   tools/run.sh                 # 開遊戲
#   tools/run.sh --log           # 印出目前 log 路徑
#   tools/run.sh --tail [regex]  # 追 log（預設只印 addon 自報的行）
#   tools/run.sh --stop
#
# ⚠️ 這會在使用者眼前彈出視窗。**執行前必須先問過使用者。**
#    純自動化驗證請用 tools/verify.sh / tools/playtest.sh（Xvfb，不必問）。
#
# 為什麼一定要 --no-steam：
#   從 Steam 啟動時，t-engine 的工坊同步回呼（lua_steam_grab_subscribed_addons_cb）
#   會在 Lua state 重建後才被 SteamAPI_RunCallbacks 派送，必定 SIGSEGV。
#   詳見 knowledge/real-machine.md §1。
#
# 為什麼不寫死 DISPLAY=:0：
#   使用者桌面是 Wayland，X 是 XWayland（通常 :1），且需要 XAUTHORITY。
#   一律從活著的 GUI 行程的 /proc/<pid>/environ 讀出來。

source "$(dirname "$0")/lib.sh"
handle_help_flag "$@"
require_game

RUN_LOG="${RUN_LOG:-/tmp/tome4-run/run.log}"

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
    start)
        pgrep -x t-engine64 >/dev/null && die "遊戲已經在跑了（先 tools/run.sh --stop）"
        detect_x_env
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
    *) die "用法: tools/run.sh [start|--stop|--log|--tail [regex]]" ;;
esac
