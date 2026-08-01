#!/usr/bin/env bash
# 無頭驗收：把 addon 佈署進全新的 scratch home，實際跑一次 t-engine64（綁在腳本自己開的
# Xvfb display，絕不碰真實桌面），走到「tome 模組載入完 addon 的 hooks」為止，
# 靠 run.log 判定成功/失敗。
#
# 用法： tools/verify.sh <addon> [--keep] [--display :97]
#          --keep      失敗時保留 scratch home 與 run.log 供追查
#          --display   起始 display 號碼（被佔用會自動往上找）
# 退出碼：0 = addon 載入且自我檢查全過 / 非 0 = 失敗
#
# 它證明什麼：addon 被引擎掃到、掛載、hook 跑完、沒有 Lua Error。
# 它**不**證明遊戲邏輯正確——那要 tools/playtest.sh（真的建角、真的動手）。
#
# ⚠️ 刻意不開 cheat 模式。cheat 會改變引擎行為（例如 engine/Particles.lua:61,81
#    對缺檔粒子的處理），而 verify 的職責是「在最接近使用者的環境下確認 addon 載入」。
#
# ============================================================================
# 為什麼是這樣寫（完整原理與行號在 knowledge/headless-testing.md，這裡只留結論）：
#
# 1) `--home <dir>` 只覆寫 fs.getUserPath()；引擎會再接上 "/.t-engine/4.0"。
#    所以 cfg/profile/addons 都在 $SCRATCH/.t-engine/4.0/ 底下（見 lib/scratch.sh）。
#
# 2) 開場的線上功能彈窗由 profiles/online/generic/firstrun.profile 決定，**不是 cfg**。
#    prepare_scratch_home() 會預寫它。
#
# 3) 主選單第一項就是 New Game 且預設有焦點，按一次 Return 即可
#    （engine/ui/List.lua:47、mod/dialogs/MainMenu.lua:86,222）。
#    本機只有 tome 一個相容模組，NewGame.lua:67-72 會自動選中，
#    tome 的 no_get_name=true 又跳過命名對話框——所以不需要滑鼠座標。
#
# 4) addon 的 "ToME:load" hook 在模組載入過程中同步觸發（mod/load.lua:267），
#    早於建角畫面。等到 hook 的自報字串或 Lua Error 就能判定，不必真的建角。
#
# 5) **不要在主選單按 Escape**：退出確認彈窗，實測會 core dump。全程只用 Return。
#
# 6) 不能用 Discord 的 "Main Menu" 當就緒標記——disable_all_connectivity=true 之後
#    engine/init.lua:103-109 會把 core.discord 設 nil，那行永遠不會印。
#    改等 "[ENGINE] Switching to realtime, interval 125 ms"。
# ============================================================================

source "$(dirname "$0")/lib.sh"
handle_help_flag "$@"
# lib.sh 會 `set -euo pipefail`；這支腳本大量需要「檢查結果、印訊息、繼續」，
# 用手動判斷取代讓 -e 直接中止，避免每個 grep/wait 都要包 `|| true`。
set +e

require_game
require_headless_tools
require_lua      # 判定階段要跑 tools/lua/verdict.lua

[ "$#" -ge 1 ] || die "用法: tools/verify.sh <addon> [--keep] [--display :97]（-h 看說明）"
addon_names "$1"; shift
KEEP=0
DISP=":97"
while [ "$#" -gt 0 ]; do
    case "$1" in
        --keep) KEEP=1 ;;
        --display) DISP="$2"; shift ;;
        *) die "未知參數: $1" ;;
    esac
    shift
done

XVFB_W=1024
XVFB_H=768

SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/tome4-verify.XXXXXX")"
ACTUAL_HOME="$SCRATCH/.t-engine"       # 見上方筆記 1)
RUN_LOG="$ACTUAL_HOME/run.log"
GAME_PID_FILE="$SCRATCH/game.pid"
XVFB_PID_FILE="$SCRATCH/xvfb.pid"

cleanup() {
    stop_game "$GAME_PID_FILE"
    [ -f "$XVFB_PID_FILE" ] && kill "$(cat "$XVFB_PID_FILE")" 2>/dev/null
    if [ "$KEEP" -eq 1 ]; then
        info "--keep：保留 scratch home 與 log 於 $SCRATCH"
    else
        rm -rf "$SCRATCH"
    fi
}
trap cleanup EXIT INT TERM

info "驗收 addon「$ADDON_SHORT」（scratch home = $SCRATCH）"

# 1) 預先寫好能少一個彈窗算一個的狀態（實作與理由在 tools/lib/scratch.sh）
prepare_scratch_home "$ACTUAL_HOME" "$ADDON_SHORT" "$XVFB_W" "$XVFB_H"
ok "cfg / profile 寫入完成"

# 2) 佈署待測 addon（絕不碰使用者真實 ~/.t-engine 或 Steam 的 game/addons/）
"$MODKIT_ROOT/tools/deploy.sh" "$ADDON_DIR" --home "$ACTUAL_HOME" || die "tools/deploy.sh 失敗"
[ -d "$ACTUAL_HOME/4.0/addons/$ADDON_BASE" ] \
    || die "佈署後找不到 $ACTUAL_HOME/4.0/addons/$ADDON_BASE"
ok "已佈署到 $ACTUAL_HOME/4.0/addons/$ADDON_BASE"

# 3) 起 Xvfb（display 被佔用就自動換號）
DISP="$(pick_free_display "$DISP")"
start_xvfb "$DISP" "$XVFB_W" "$XVFB_H" "$SCRATCH/xvfb.log" "$XVFB_PID_FILE"
ok "Xvfb 已啟動於 $DISP"

# 4) 啟動遊戲（絕不用真實桌面的 DISPLAY；--no-debug / --logtofile 的地雷見 lib/game.sh）
launch_game "$SCRATCH" "$DISP" "$RUN_LOG" "$GAME_PID_FILE" 180
sleep 1
GAME_PID="$(cat "$GAME_PID_FILE" 2>/dev/null)"
[ -n "$GAME_PID" ] || die "抓不到遊戲 pid"
info "遊戲已啟動（pid $GAME_PID, DISPLAY=$DISP），等待主選單……"

# 5) 等主選單（見上方筆記 6)：只能等這個字串）
wait_log "$RUN_LOG" 'Switching to realtime, interval 125 ms' 90 "$GAME_PID"
case "$?" in
    2) dump_tail "$RUN_LOG"; die "遊戲行程在到達主選單前就結束了" ;;
    1) dump_tail "$RUN_LOG"; die "等待主選單逾時（90s）" ;;
esac
# 主選單背景地圖沒有穩定的「完成」字串可等，用短暫緩衝寬限 setupUI/setFocus
sleep 2
ok "已到主選單（firstrun 彈窗已跳過）"

# 6) 見上方筆記 3)、4)：按 Return 觸發 New Game，hook 會在載入途中同步印出
sleep 1
DISPLAY="$DISP" xdotool key Return
info "已送出 New Game（Return 鍵）"

wait_log "$RUN_LOG" "hook complete|Lua Error|stack traceback" 90 "$GAME_PID"
case "$?" in
    2) dump_tail "$RUN_LOG"; die "載入 tome 模組／執行 hook 時遊戲行程當掉了" ;;
    1) dump_tail "$RUN_LOG"; die "等待 addon 載入結果逾時（90s）" ;;
esac

# 7) 判定。所有判讀規則與優先順序都在 tools/lua/verdict.lua，這裡只負責轉述退出碼。
verdict_out="$("$LUA_BIN" "$MODKIT_LUA_DIR/verdict.lua" "$RUN_LOG" "$ADDON_SHORT" 2>&1)"
verdict_rc="$?"
printf '%s\n' "$verdict_out"
if [ "$verdict_rc" -ne 0 ]; then
    [ "$KEEP" -eq 1 ] || warn "想看完整 run.log 請加 --keep 重跑"
    die "「$ADDON_SHORT」驗收失敗"
fi
ok "驗收通過"
