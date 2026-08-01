#!/usr/bin/env bash
# 實機遊玩：在 Xvfb 裡把遊戲真的開起來、真的建角、真的動手，並取得狀態。
#
# 為什麼需要這支：`tools/verify.sh` 只能證明「addon 載入、定義註冊成功、沒有 Lua Error」。
# 它證明不了遊戲邏輯是對的。2026-07-10 實機遊玩抓到三個 verify 全綠卻仍然壞掉的 bug：
#   1. 共鳴比對用了 `t.name`——那是 _t() 翻譯過的，中文語系下永遠比不中
#   2. 起始銘文因為欄位已滿被 setInscription 靜默丟棄
#   3. 古弗薩克文字符在遊戲字型是豆腐方塊
# 這三個都是「載入成功但行為錯誤」，只有真的玩才看得到。
#
# 用法：
#   tools/playtest.sh start <addon> --cheat --birth default
#       開遊戲並自動建角，直接停在**遊戲內**。這是建議的起手式。
#       [--birth default|<race>/<subrace>/<class>/<subclass>]  descriptor 用英文原名
#       [--cheat]      開 Developer Mode，`lua` 與 `probe` 都需要它
#       [--display :99] [--locale zh_hant] [--size 1280x800]
#       不加 --birth 就停在建角畫面，需要自己用 `do click` 走 UI（座標會隨語系變）。
#
#   tools/playtest.sh probe <名字> [參數...]   ← **取得狀態優先用這個**
#   tools/playtest.sh probe --list            列出所有可用探測
#   tools/playtest.sh lua '<一行 Lua>'         臨時查東西才用；固定手法請寫成 probe
#   tools/playtest.sh log [regex]              撈 run.log（預設撈 addon 自報與探測輸出）
#   tools/playtest.sh do <截圖名> <動作...>     動作: click X Y | key K | type TEXT | wait N
#   tools/playtest.sh shot <截圖名>
#   tools/playtest.sh zoom <截圖名> <W> <H> <X> <Y>
#   tools/playtest.sh status
#   tools/playtest.sh stop                     ← 一定要收尾，否則遊戲留在背景
#
# 分工鐵律：AI 要的狀態一律走 `probe` / `lua`（回傳純文字）；
#           截圖是**產給使用者看的**，畫面、渲染、手感、平衡由使用者判斷。
#           探測手法全集見 docs/knowledge/playtesting-parts/03-state-probes.md。
#
# 鐵律：全程綁在本腳本自己開的 Xvfb display，**絕不碰真實桌面**。
#       要在真實桌面用滑鼠鍵盤前，先問使用者。
#
# 實作按職責拆在 tools/lib/playtest/ 底下，本檔只留狀態路徑與參數派發：
#   playtest/session.sh   start / status / stop（session 生命週期）
#   playtest/screen.sh    shot / do / zoom（截圖與 X11 輸入，產給使用者看）
#   playtest/console.sh   probe / lua / log（送 Lua 進遊戲並撈回純文字，給 AI 用）

source "$(dirname "$0")/lib.sh"
handle_help_flag "$@"
set +e

STATE_DIR="${TOME_PLAYTEST_STATE:-${TMPDIR:-/tmp}/tome4-playtest}"
SHOTS="$STATE_DIR/shots"
RUN_LOG="$STATE_DIR/run.log"
GAME_PID_FILE="$STATE_DIR/game.pid"
XVFB_PID_FILE="$STATE_DIR/xvfb.pid"

_PT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib/playtest" && pwd)"
# shellcheck source=lib/playtest/screen.sh
source "$_PT_DIR/screen.sh"
# shellcheck source=lib/playtest/console.sh
source "$_PT_DIR/console.sh"
# shellcheck source=lib/playtest/session.sh
source "$_PT_DIR/session.sh"

read_state() {
    [ -f "$STATE_DIR/display" ] || die "沒有進行中的 playtest。先跑 tools/playtest.sh start <addon> --cheat --birth default"
    DISP="$(cat "$STATE_DIR/display")"
}

require_cheat() {
    [ -f "$STATE_DIR/cheat" ] \
        || die "這個 session 沒開 Developer Mode。請用 start <addon> --cheat（沒有它就沒有 Lua console）"
}

case "${1:-}" in
    start)  shift; cmd_start  "$@" ;;
    do)     shift; cmd_do     "$@" ;;
    shot)   shift; cmd_shot   "$@" ;;
    lua)    shift; cmd_lua    "$@" ;;
    probe)  shift; cmd_probe  "$@" ;;
    zoom)   shift; cmd_zoom   "$@" ;;
    log)    shift; cmd_log    "$@" ;;
    status) shift; cmd_status "$@" ;;
    stop)   shift; cmd_stop   "$@" ;;
    *) die "用法: tools/playtest.sh {start|probe|lua|log|do|shot|zoom|status|stop} ...（-h 看完整說明）" ;;
esac
