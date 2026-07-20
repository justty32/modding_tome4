#!/usr/bin/env bash
# 無頭驗收：把 addon 佈署進全新的 scratch home，實際跑一次 t-engine64（綁在腳本自己開的
# Xvfb display，絕不碰真實桌面），用鍵盤操作走到「tome 模組載入完 addon 的 hooks」為止，
# 靠 run.log 判定成功/失敗。
#
# 用法： tools/verify.sh <addon> [--keep] [--display :97]
# 退出碼： 0 = addon 載入且自我檢查全過 / 非 0 = 失敗
#
# ============================================================================
# 為什麼是這樣寫（完整原理與行號在 knowledge/headless-testing.md，這裡只留結論）：
#
# 1) `--home <dir>` 只覆寫 fs.getUserPath()；引擎會再接上 "/.t-engine/4.0"。
#    所以 cfg/profile/addons 都在 $SCRATCH/.t-engine/4.0/ 底下。
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
source "$(dirname "$0")/lib_scratch.sh"   # prepare_scratch_home / pick_free_display / launch_game
# lib.sh 會 `set -euo pipefail`；這支腳本大量需要「檢查結果、印訊息、繼續」，
# 用手動判斷（if/grep -q）取代讓 -e 直接中止腳本，避免每個 grep/wait 都要包 `|| true`。
set +e

require_game

[ "$#" -ge 1 ] || die "用法: tools/verify.sh <addon> [--keep] [--display :97]"
ADDON="$1"; shift
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

command -v xdotool >/dev/null 2>&1 || die "找不到 xdotool"
command -v Xvfb    >/dev/null 2>&1 || die "找不到 Xvfb"

ADDON_DIR="$(resolve_addon_dir "$ADDON")"
ADDON_BASENAME="$(basename "$ADDON_DIR")"                # tome-<short_name>
SHORT_NAME="${ADDON_BASENAME#tome-}"
UPPER_SHORT_NAME="$(printf '%s' "$SHORT_NAME" | tr '[:lower:]' '[:upper:]')"

XVFB_W=1024
XVFB_H=768

SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/tome4-verify.XXXXXX")"
ACTUAL_HOME="$SCRATCH/.t-engine"       # 見上方筆記 1)：引擎實際家目錄
SETTINGS_DIR="$ACTUAL_HOME/4.0/settings"
PROFILE_DIR="$ACTUAL_HOME/4.0/profiles/online/generic"
RUN_LOG="$ACTUAL_HOME/run.log"

XVFB_PID=""
GAME_PID=""

cleanup() {
    [ -n "$GAME_PID" ] && kill -9 "$GAME_PID" 2>/dev/null
    [ -n "$XVFB_PID" ] && kill "$XVFB_PID" 2>/dev/null
    wait 2>/dev/null
    if [ "$KEEP" -eq 1 ]; then
        info "--keep：保留 scratch home 與 log 於 $SCRATCH"
    else
        rm -rf "$SCRATCH"
    fi
}
trap cleanup EXIT INT TERM

info "驗收 addon「$SHORT_NAME」（scratch home = $SCRATCH）"


# ---------------------------------------------------------------------------
# 1) 預先寫好能少一個彈窗算一個的狀態（實作與註解在 tools/lib_scratch.sh）
# ---------------------------------------------------------------------------
prepare_scratch_home "$ACTUAL_HOME" "$SHORT_NAME" "$XVFB_W" "$XVFB_H"

ok "cfg / profile 寫入完成：$SETTINGS_DIR"

# ---------------------------------------------------------------------------
# 2) 佈署待測 addon（絕不碰使用者真實 ~/.t-engine 或 Steam 的 game/addons/）
# ---------------------------------------------------------------------------
"$MODKIT_ROOT/tools/deploy.sh" "$ADDON" --home "$ACTUAL_HOME"
if [ "$?" -ne 0 ]; then
    die "tools/deploy.sh 失敗"
fi
if [ ! -d "$ACTUAL_HOME/4.0/addons/$ADDON_BASENAME" ]; then
    die "佈署後找不到 $ACTUAL_HOME/4.0/addons/$ADDON_BASENAME"
fi
ok "已佈署到 $ACTUAL_HOME/4.0/addons/$ADDON_BASENAME"

# ---------------------------------------------------------------------------
# 3) 起 Xvfb（display 被佔用就自動換號）
# ---------------------------------------------------------------------------
DISP="$(pick_free_display "$DISP")"

Xvfb "$DISP" -screen 0 "${XVFB_W}x${XVFB_H}x24" -nolisten tcp >"$SCRATCH/xvfb.log" 2>&1 &
XVFB_PID=$!
sleep 1
if ! kill -0 "$XVFB_PID" 2>/dev/null; then
    warn "Xvfb log："; cat "$SCRATCH/xvfb.log" >&2
    die "Xvfb 啟動失敗（display $DISP）"
fi
ok "Xvfb 已啟動於 $DISP（pid $XVFB_PID）"

# ---------------------------------------------------------------------------
# 4) 啟動遊戲（絕不用真實桌面的 DISPLAY，一律用上面自己開的 Xvfb display）
# ---------------------------------------------------------------------------
# 注意兩件事，改動前先讀：
#
# 1) 不可加 --no-debug。它會讓引擎吞掉 Lua 的 print 輸出，於是 addon 的
#    "[X] selfcheck ... = OK" / "[X] hook complete" 一行都不會出現，
#    verify 會誤判成逾時失敗——即使 addon 其實載入得好好的。
#    引擎自己的 "Checking addon" / "* with data" 也會一起消失。
#
# 2) cwd 必須是 TOME_GAME_DIR。執行檔靠相對路徑找 game/ 資料，
#    從別的目錄啟動會停在啟動早期、連主選單都到不了。
#    （--logtofile 也不要用：它把輸出轉去 te4_log.txt 並改變啟動行為。）
(
    cd "$TOME_GAME_DIR" || exit 1
    DISPLAY="$DISP" LIBGL_ALWAYS_SOFTWARE=1 timeout 180 ./t-engine64 \
        --no-steam --no-web --flush-stdout --home "$SCRATCH" \
        >"$RUN_LOG" 2>&1 &
    echo $! >"$SCRATCH/game.pid"
)
sleep 1
GAME_PID="$(cat "$SCRATCH/game.pid" 2>/dev/null)"
[ -n "$GAME_PID" ] || die "抓不到遊戲 pid"
info "遊戲已啟動（pid $GAME_PID, DISPLAY=$DISP），等待主選單……"

# ---------------------------------------------------------------------------
# 5) 等 log 字串（有逾時），不用固定 sleep
#    回傳： 0=等到了 / 1=逾時 / 2=遊戲行程已死
# ---------------------------------------------------------------------------
wait_for_log() {
    local pattern="$1" timeout_s="$2" waited=0
    while [ "$waited" -lt "$timeout_s" ]; do
        if [ -f "$RUN_LOG" ] && grep -qE "$pattern" "$RUN_LOG" 2>/dev/null; then
            return 0
        fi
        if ! kill -0 "$GAME_PID" 2>/dev/null; then
            return 2
        fi
        sleep 1
        waited=$((waited + 1))
    done
    return 1
}

dump_tail_and_die() {
    warn "run.log 最後 40 行："
    tail -n 40 "$RUN_LOG" >&2
    die "$1"
}

# 不能用 Discord 的 "[Discord] updating state: \"Main Menu\"" 當作標記——
# 我們在上面把 disable_all_connectivity 設成 true（等同按了「Disable all online
# features」），engine/init.lua:103-109 一看到這個設定就會 `core.discord = nil`，
# 之後任何 Discord 狀態更新呼叫都直接不執行、不印任何東西（實測過：這行 log 因此
# 永遠不會出現，白等 90 秒逾時）。
# 改用主選單建立完成、開始播動畫背景時一定會印的兩行
# "[ENGINE] Switching to realtime, interval 125 ms"（不管有沒有 Discord 都會印，
# 實測在 DLC/addon 全部載入完、主選單背景地圖與 shader 建立之前穩定出現一次）。
wait_for_log 'Switching to realtime, interval 125 ms' 90
rc=$?
if [ "$rc" -eq 2 ]; then
    dump_tail_and_die "遊戲行程在到達主選單前就結束了"
elif [ "$rc" -eq 1 ]; then
    dump_tail_and_die "等待主選單逾時（90s）"
fi
# 再等一下讓主選單的 UI（setFocus 等）真正跑完，比固定 sleep 更穩的作法是再抓一個
# 明確會在稍後印出的畫面字串，但主選單背景地圖沒有穩定的「完成」字串可等，
# 這裡用一個短暫緩衝，寬限主選單完成 setupUI/setFocus。
sleep 2
ok "已到主選單（firstrun 彈窗已跳過）"

# 見上方筆記 3)、4)：主選單清單焦點預設在「New Game」，按 Return 即觸發；
# 因為只有 tome 一個相容模組、且 no_get_name=true，會自動略過選單清單畫面與
# 角色命名對話框，直接開始載入模組。
sleep 1   # 讓對話框完成 setFocus 的最短緩衝，不是等待條件本身
DISPLAY="$DISP" xdotool key Return
info "已送出 New Game（Return 鍵）"

# 見上方筆記 5)：hook 在模組載入過程中同步觸發，不必等到建角畫面
wait_for_log "hook complete|Lua Error|stack traceback" 90
rc=$?
if [ "$rc" -eq 2 ]; then
    dump_tail_and_die "載入 tome 模組／執行 hook 時遊戲行程當掉了"
elif [ "$rc" -eq 1 ]; then
    dump_tail_and_die "等待 addon 載入結果逾時（90s）"
fi

# ---------------------------------------------------------------------------
# 6) 判定
# ---------------------------------------------------------------------------
if grep -qE 'Lua Error|stack traceback' "$RUN_LOG"; then
    warn "偵測到 Lua Error："
    grep -n -A 8 'Lua Error' "$RUN_LOG" | head -n 40 >&2
    die "「$SHORT_NAME」載入失敗（見上方 Lua Error 原文）"
fi

if grep -qE "\[${UPPER_SHORT_NAME}\] hook complete" "$RUN_LOG"; then
    if grep -qE "\[${UPPER_SHORT_NAME}\] selfcheck .* = FAIL" "$RUN_LOG"; then
        warn "selfcheck 有 FAIL："
        grep -nE "\[${UPPER_SHORT_NAME}\] selfcheck" "$RUN_LOG" >&2
        die "「$SHORT_NAME」selfcheck 未全過"
    fi
    ok "「$SHORT_NAME」hook complete，selfcheck 全過："
    grep -nE "\[${UPPER_SHORT_NAME}\] selfcheck" "$RUN_LOG"
    ok "驗收通過"
    exit 0
fi

# 通用判定：addon 沒有自報格式時的退路
# （engine/Module.lua:411 "Checking addon" / :499 "with data" 是引擎自己印的載入痕跡）
if grep -qE "Checking addon.*$SHORT_NAME|with data.*$SHORT_NAME|loaded-addons/$SHORT_NAME/" "$RUN_LOG"; then
    ok "偵測到「$SHORT_NAME」的載入痕跡，且無 Lua Error"
    ok "驗收通過（通用判定，addon 未自報 hook complete）"
    exit 0
fi

dump_tail_and_die "沒看到「$SHORT_NAME」的載入痕跡，也沒有明確錯誤——判定為失敗"
