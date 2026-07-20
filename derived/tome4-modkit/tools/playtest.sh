#!/usr/bin/env bash
# 實機遊玩：在 Xvfb 裡把遊戲真的開起來、真的建角、真的按技能，並截圖。
#
# 為什麼需要這支：`tools/verify.sh` 只能證明「addon 載入、定義註冊成功、沒有 Lua Error」。
# 它證明不了遊戲邏輯是對的。2026-07-10 實機遊玩抓到三個 verify 全綠卻仍然壞掉的 bug：
#   1. 共鳴比對用了 `t.name`——那是 _t() 翻譯過的，中文語系下永遠比不中
#   2. 起始銘文因為欄位已滿被 setInscription 靜默丟棄
#   3. 古弗薩克文字符在遊戲字型是豆腐方塊
# 這三個都是「載入成功但行為錯誤」，只有真的玩才看得到。
#
# 用法：
#   tools/playtest.sh start <addon> [--display :99] [--locale zh_hant] [--size 1280x800] [--cheat]
#   tools/playtest.sh do <截圖名> <動作...>      # 動作: click X Y | key K | type TEXT | wait N
#   tools/playtest.sh shot <截圖名>
#   tools/playtest.sh lua '<一行 Lua>'          # 需要 start --cheat；用 print() 取值
#   tools/playtest.sh log [regex]                # 預設印 addon 自報的行
#   tools/playtest.sh zoom <截圖名> <W> <H> <X> <Y>   # 裁切放大，方便看清數字
#   tools/playtest.sh status
#   tools/playtest.sh stop                       # 一定要收尾，否則遊戲會留在背景
#
# 截圖落在 <state>/shots/p_<名字>.png，路徑會印出來。
#
# 鐵律：全程綁在本腳本自己開的 Xvfb display，**絕不碰真實桌面**。
#       要在真實桌面用滑鼠鍵盤前，先問使用者。

source "$(dirname "$0")/lib.sh"
source "$(dirname "$0")/lib_scratch.sh"
set +e

STATE_DIR="${TOME_PLAYTEST_STATE:-${TMPDIR:-/tmp}/tome4-playtest}"
SHOTS="$STATE_DIR/shots"
RUN_LOG="$STATE_DIR/run.log"

read_state() {
    [ -f "$STATE_DIR/display" ] || die "沒有進行中的 playtest。先跑 tools/playtest.sh start <addon>"
    DISP="$(cat "$STATE_DIR/display")"
    GAME_PID="$(cat "$STATE_DIR/game.pid" 2>/dev/null)"
}

cmd_start() {
    [ "$#" -ge 1 ] || die "用法: tools/playtest.sh start <addon> [--display :99] [--locale zh_hant]"
    require_game
    command -v xdotool >/dev/null || die "找不到 xdotool"
    command -v Xvfb    >/dev/null || die "找不到 Xvfb"
    command -v import  >/dev/null || die "找不到 import（imagemagick）"

    local addon="$1"; shift
    local disp=":99" locale="zh_hant" size="1024x768" cheat=0
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --display) disp="$2"; shift ;;
            --locale)  locale="$2"; shift ;;
            --size)    size="$2"; shift ;;
            --cheat)   cheat=1 ;;
            *) die "未知參數: $1" ;;
        esac
        shift
    done

    cmd_stop >/dev/null 2>&1

    local addon_dir base short
    addon_dir="$(resolve_addon_dir "$addon")"
    base="$(basename "$addon_dir")"
    short="${base#tome-}"
    local upper
    upper="$(printf '%s' "$short" | tr '[:lower:]' '[:upper:]')"

    rm -rf "$STATE_DIR"
    mkdir -p "$SHOTS"
    local scratch="$STATE_DIR/home"
    local actual_home="$scratch/.t-engine"

    # 1024x768 塞不下快捷鍵列與訊息面板——要看技能特效請用 --size 1280x800 以上。
    local w="${size%x*}" h="${size#*x}"
    prepare_scratch_home "$actual_home" "$short" "$w" "$h" "$locale"
    if [ "$cheat" = "1" ]; then
        enable_cheat_mode "$actual_home"
        printf '1' > "$STATE_DIR/cheat"
        ok "已開啟 Developer Mode（可用 playtest.sh lua）"
    fi
    "$MODKIT_ROOT/tools/deploy.sh" "$addon" --home "$actual_home" >/dev/null || die "佈署失敗"
    ok "已佈署「$short」到 scratch home"

    disp="$(pick_free_display "$disp")"
    DISP="$disp"   # _shot 用
    setsid Xvfb "$disp" -screen 0 "${w}x${h}x24" -nolisten tcp </dev/null >"$STATE_DIR/xvfb.log" 2>&1 &
    echo $! > "$STATE_DIR/xvfb.pid"
    sleep 2
    printf '%s' "$disp" > "$STATE_DIR/display"
    ok "Xvfb 已啟動於 $disp"

    # 上限給大一點：實機遊玩會待很久（軟體 GL 很慢）
    launch_game "$scratch" "$disp" "$RUN_LOG" "$STATE_DIR/game.pid" 1800
    sleep 1
    GAME_PID="$(cat "$STATE_DIR/game.pid")"
    info "遊戲已啟動（pid $GAME_PID, DISPLAY=$disp）"

    wait_log_file "$RUN_LOG" 'Switching to realtime, interval 125 ms' 120 \
        || { tail -n 30 "$RUN_LOG" >&2; die "等不到主選單"; }
    ok "已到主選單"
    sleep 3

    # 主選單第一項就是 New Game 且預設有焦點，按 Return 即可（別按 Escape，會 core dump）。
    #
    # ⚠️ 不要靠 sleep 賭時機。"Switching to realtime" 在 log 裡會出現兩次
    #    （第一次是引擎啟動，第二次才是主選單模組），而 --cheat 會多載入東西讓時序偏移，
    #    於是 Return 可能落在選單畫出來之前，整個 start 就卡死等 hook complete。
    #    改成按了沒反應就重按，最多 4 次。
    _shot mainmenu >/dev/null   # 失敗時要有畫面可看，別只剩一行「等不到 hook complete」
    local tries=0 started=0
    while [ "$tries" -lt 4 ]; do
        DISPLAY="$disp" xdotool key --clearmodifiers Return
        if wait_log_file "$RUN_LOG" "\[$upper\] hook complete|Lua Error" 60; then
            started=1; break
        fi
        tries=$((tries + 1))
        warn "主選單的 Return 沒有生效（第 $tries 次），重試……"
    done
    [ "$started" = "1" ] || { tail -n 30 "$RUN_LOG" >&2; die "等不到 addon 的 hook complete"; }

    if grep -qE 'Lua Error' "$RUN_LOG"; then
        grep -n -A 8 'Lua Error' "$RUN_LOG" | head -n 30 >&2
        die "載入時就有 Lua Error（見上）"
    fi
    sleep 3
    _shot birth
    ok '已停在建角畫面。接下來用 tools/playtest.sh do ... 操作。'
    info "座標速查見 knowledge/playtesting.md"
}

_shot() {
    local name="$1"
    DISPLAY="$DISP" import -window root "$SHOTS/p_$name.png" 2>/dev/null \
        || die "截圖失敗（遊戲可能已結束）"
    echo "$SHOTS/p_$name.png"
}

cmd_do() {
    read_state
    [ "$#" -ge 1 ] || die "用法: tools/playtest.sh do <截圖名> <動作...>"
    local name="$1"; shift
    while [ "$#" -gt 0 ]; do
        case "$1" in
            click) DISPLAY="$DISP" xdotool mousemove "$2" "$3" click 1; shift 3; sleep 1 ;;
            key)   DISPLAY="$DISP" xdotool key --clearmodifiers "$2"; shift 2; sleep 1 ;;
            type)  DISPLAY="$DISP" xdotool type --delay 40 "$2"; shift 2; sleep 1 ;;
            wait)  sleep "$2"; shift 2 ;;
            *) die "未知動作: $1（可用 click/key/type/wait）" ;;
        esac
    done
    sleep 1
    _shot "$name"
}

cmd_shot()  { read_state; _shot "${1:?需要截圖名}"; }

# 在遊戲裡執行一行 Lua（需要 start --cheat）。
#
# ctrl+L 開 Lua console（engine/data/keybinds/debug.lua:20-26），打字，Return 執行
# （engine/DebugConsole.lua:140-151 直接 loadstring + pcall），Escape 關掉。
#
# ⚠️ 執行結果只寫進 console 的畫面 history，**不會**進 stdout。
#    要拿到值就自己 print()——print 走 stdout 進 run.log，可用 `playtest.sh log` 撈。
#    例：tools/playtest.sh lua 'print("[DBG] hp="..game.player.life)'
#
# ⚠️ 這是 xdotool type，字串裡不要有換行，而且**只能用 ASCII**——中文送不進去，
#    那一行會整個消失（不報錯，只是 print 不出來）。要印中文請讓 addon 自己 print。
#    單引號包外層、Lua 用雙引號最省事。
#
# ⚠️ 兩個實測出來的坑：
#
# 1) `xdotool key --clearmodifiers ctrl+l` 在 Xvfb 下**時靈時不靈**——它會在按鍵送達前
#    就把 Ctrl 放掉，於是遊戲只收到一個 `l`（變成一個遊戲指令）。
#    必須拆成 keydown ctrl → key l → keyup ctrl。實測這樣 3/3 穩定。
#
# 2) console 要好幾秒才畫出來（軟體 GL）。太早打字的話字元會被**遊戲本體**收走。
#    所以先送一行 sentinel 並等它出現在 run.log，確認 console 真的拿到焦點，才送真正的程式碼。
#    sentinel 一定要放在使用者程式碼**之前**：像 grantQuest 這種會跳出彈窗的程式碼，
#    彈窗會蓋在 console 上面把後續輸入吃掉，sentinel 放後面就會誤判成失敗。
cmd_lua() {
    read_state
    [ -f "$STATE_DIR/cheat" ] || die "這個 session 沒開 Developer Mode。請用 tools/playtest.sh start <addon> --cheat"
    local code="${1:?需要一行 Lua}"
    case "$code" in
        *$'\n'*) die "Lua 只能一行（xdotool type 不吃換行）" ;;
    esac

    local before after
    before="$(grep -ac '\[LUA\] ok' "$RUN_LOG" 2>/dev/null)"; before="${before:-0}"

    DISPLAY="$DISP" xdotool keydown ctrl; sleep 0.3
    DISPLAY="$DISP" xdotool key l;        sleep 0.3
    DISPLAY="$DISP" xdotool keyup ctrl;   sleep 3

    # sentinel 先行：確認 console 真的拿到鍵盤焦點
    DISPLAY="$DISP" xdotool type --delay 25 'print("[LUA] ok")'; sleep 1
    DISPLAY="$DISP" xdotool key Return

    local i=0
    while [ "$i" -lt 12 ]; do
        after="$(grep -ac '\[LUA\] ok' "$RUN_LOG" 2>/dev/null)"; after="${after:-0}"
        [ "$after" -gt "$before" ] && break
        sleep 1; i=$((i + 1))
    done
    if [ "${after:-0}" -le "$before" ]; then
        DISPLAY="$DISP" xdotool key Escape; sleep 1
        _shot lua
        die "Lua console 沒拿到焦點（它可能還沒畫出來，或當時有別的對話框擋著）"
    fi

    DISPLAY="$DISP" xdotool type --delay 25 "$code"; sleep 1
    DISPLAY="$DISP" xdotool key Return; sleep 2
    DISPLAY="$DISP" xdotool key Escape; sleep 1
    _shot lua
}

cmd_zoom() {
    local name="$1" w="$2" h="$3" x="$4" y="$5"
    command -v magick >/dev/null || die "找不到 magick"
    magick "$SHOTS/p_$name.png" -crop "${w}x${h}+${x}+${y}" -resize 180% "$SHOTS/z_$name.png" \
        || die "裁切失敗"
    echo "$SHOTS/z_$name.png"
}

cmd_log() {
    [ -f "$RUN_LOG" ] || die "沒有 run.log"
    local pat="${1:-\[[A-Z_]+\] (selfcheck|hook|dbg)}"
    grep -aE "$pat" "$RUN_LOG"
    local n
    n="$(grep -ac 'Lua Error' "$RUN_LOG")"
    [ "$n" -gt 0 ] && { warn "Lua Error x$n："; grep -a -A 8 'Lua Error' "$RUN_LOG" | head -n 30; }
    return 0
}

cmd_status() {
    if [ -f "$STATE_DIR/game.pid" ] && kill -0 "$(cat "$STATE_DIR/game.pid")" 2>/dev/null; then
        ok "遊戲執行中（pid $(cat "$STATE_DIR/game.pid"), DISPLAY=$(cat "$STATE_DIR/display")）"
        info "state=$STATE_DIR  shots=$SHOTS"
    else
        info "沒有執行中的遊戲"
    fi
}

cmd_stop() {
    [ -f "$STATE_DIR/game.pid" ] && kill -9 "$(cat "$STATE_DIR/game.pid")" 2>/dev/null
    [ -f "$STATE_DIR/xvfb.pid" ] && kill -9 "$(cat "$STATE_DIR/xvfb.pid")" 2>/dev/null
    # setsid 讓遊戲脫離本 shell 的行程群，殘留要靠名字掃
    pkill -x t-engine64 2>/dev/null

    # 等它真的死透再返回。kill 是非同步的：不等的話，緊接著的 `start` 會撞上
    # 還在收屍的舊行程與它佔著的 X display。
    local i=0
    while pgrep -x t-engine64 >/dev/null 2>&1 && [ "$i" -lt 15 ]; do
        sleep 1; i=$((i + 1))
    done
    pgrep -x t-engine64 >/dev/null 2>&1 && warn "t-engine64 仍未結束，可能需要手動 pkill"

    rm -f "$STATE_DIR/display" "$STATE_DIR/game.pid" "$STATE_DIR/xvfb.pid"
    ok "已停止（截圖保留在 $SHOTS）"
}

case "${1:-}" in
    start)  shift; cmd_start  "$@" ;;
    do)     shift; cmd_do     "$@" ;;
    shot)   shift; cmd_shot   "$@" ;;
    lua)    shift; cmd_lua    "$@" ;;
    zoom)   shift; cmd_zoom   "$@" ;;
    log)    shift; cmd_log    "$@" ;;
    status) shift; cmd_status "$@" ;;
    stop)   shift; cmd_stop   "$@" ;;
    *) die "用法: tools/playtest.sh {start|do|shot|lua|zoom|log|status|stop} ...（詳見檔頭）" ;;
esac
