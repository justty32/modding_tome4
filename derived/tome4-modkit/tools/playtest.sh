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
#           探測手法全集見 knowledge/playtesting-parts/03-state-probes.md。
#
# 鐵律：全程綁在本腳本自己開的 Xvfb display，**絕不碰真實桌面**。
#       要在真實桌面用滑鼠鍵盤前，先問使用者。

source "$(dirname "$0")/lib.sh"
handle_help_flag "$@"
set +e

STATE_DIR="${TOME_PLAYTEST_STATE:-${TMPDIR:-/tmp}/tome4-playtest}"
SHOTS="$STATE_DIR/shots"
RUN_LOG="$STATE_DIR/run.log"
GAME_PID_FILE="$STATE_DIR/game.pid"
XVFB_PID_FILE="$STATE_DIR/xvfb.pid"

read_state() {
    [ -f "$STATE_DIR/display" ] || die "沒有進行中的 playtest。先跑 tools/playtest.sh start <addon> --cheat --birth default"
    DISP="$(cat "$STATE_DIR/display")"
}

require_cheat() {
    [ -f "$STATE_DIR/cheat" ] \
        || die "這個 session 沒開 Developer Mode。請用 start <addon> --cheat（沒有它就沒有 Lua console）"
}

# ---------------------------------------------------------------------------
# start
# ---------------------------------------------------------------------------
cmd_start() {
    [ "$#" -ge 1 ] || die "用法: tools/playtest.sh start <addon> [--cheat] [--birth ...]（-h 看說明）"
    require_game
    require_headless_tools
    require_screenshot_tools
    require_lua

    addon_names "$1"; shift
    local disp=":99" locale="zh_hant" size="1024x768" cheat=0 birth=""
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --display) disp="$2"; shift ;;
            --locale)  locale="$2"; shift ;;
            --size)    size="$2"; shift ;;
            --cheat)   cheat=1 ;;
            --birth)   birth="${2:-default}"; shift ;;
            *) die "未知參數: $1" ;;
        esac
        shift
    done

    cmd_stop >/dev/null 2>&1

    rm -rf "$STATE_DIR"
    mkdir -p "$SHOTS"
    local scratch="$STATE_DIR/home"
    local actual_home="$scratch/.t-engine"

    # 1024x768 塞不下快捷鍵列與訊息面板——要看技能特效請用 --size 1280x800 以上。
    local w="${size%x*}" h="${size#*x}"
    prepare_scratch_home "$actual_home" "$ADDON_SHORT" "$w" "$h" "$locale"
    if [ "$cheat" = "1" ]; then
        enable_cheat_mode "$actual_home"
        printf '1' > "$STATE_DIR/cheat"
        ok "已開啟 Developer Mode（lua / probe 可用）"
    fi
    "$MODKIT_ROOT/tools/deploy.sh" "$ADDON_DIR" --home "$actual_home" >/dev/null || die "佈署失敗"
    ok "已佈署「$ADDON_SHORT」到 scratch home"

    # --birth：加掛 tome-autobirth 夾具 + 寫規格檔，讓建角完全不碰滑鼠鍵盤。
    local birth_desc=""
    if [ -n "$birth" ]; then
        "$MODKIT_ROOT/tools/deploy.sh" tome-autobirth --home "$actual_home" >/dev/null \
            || die "autobirth 夾具佈署失敗"
        local b_race b_subrace b_class b_subclass
        if [ "$birth" = "default" ]; then
            b_race="Human"; b_subrace="Cornac"; b_class="Warrior"; b_subclass="Berserker"
        else
            IFS=/ read -r b_race b_subrace b_class b_subclass <<< "$birth"
            [ -n "$b_subclass" ] \
                || die "--birth 格式為 <race>/<subrace>/<class>/<subclass>（英文原名），或用 default"
        fi
        write_autobirth_spec "$actual_home" "$b_race" "$b_subrace" "$b_class" "$b_subclass"
        birth_desc="$b_subrace $b_subclass"
        ok "autobirth 已設定：$birth_desc"
    fi

    disp="$(pick_free_display "$disp")"
    DISP="$disp"
    start_xvfb "$disp" "$w" "$h" "$STATE_DIR/xvfb.log" "$XVFB_PID_FILE"
    printf '%s' "$disp" > "$STATE_DIR/display"
    ok "Xvfb 已啟動於 $disp"

    # 上限給大一點：實機遊玩會待很久（軟體 GL 很慢）
    launch_game "$scratch" "$disp" "$RUN_LOG" "$GAME_PID_FILE" 1800
    sleep 1
    local game_pid; game_pid="$(cat "$GAME_PID_FILE")"
    info "遊戲已啟動（pid $game_pid, DISPLAY=$disp）"

    wait_log "$RUN_LOG" 'Switching to realtime, interval 125 ms' 120 "$game_pid" \
        || { dump_tail "$RUN_LOG" 30; die "等不到主選單"; }
    ok "已到主選單"
    sleep 3

    # ⚠️ 不要靠 sleep 賭時機。"Switching to realtime" 在 log 裡會出現兩次
    #    （第一次是引擎啟動，第二次才是主選單模組），而 --cheat 會多載入東西讓時序偏移，
    #    於是 Return 可能落在選單畫出來之前，整個 start 就卡死。
    #    改成按了沒反應就重按，最多 4 次。
    _shot mainmenu >/dev/null   # 失敗時要有畫面可看
    local tries=0 started=0
    while [ "$tries" -lt 4 ]; do
        DISPLAY="$disp" xdotool key --clearmodifiers Return
        if wait_log "$RUN_LOG" "\[$ADDON_UPPER\] hook complete|Lua Error" 60 "$game_pid"; then
            started=1; break
        fi
        tries=$((tries + 1))
        warn "主選單的 Return 沒有生效（第 $tries 次），重試……"
    done
    [ "$started" = "1" ] || { dump_tail "$RUN_LOG" 30; die "等不到 addon 的 hook complete"; }

    if grep -qaE 'Lua Error' "$RUN_LOG"; then
        grep -na -A 8 'Lua Error' "$RUN_LOG" | head -n 30 >&2
        die "載入時就有 Lua Error（見上）"
    fi
    sleep 3

    if [ -z "$birth" ]; then
        _shot birth
        ok '已停在建角畫面。接下來用 tools/playtest.sh do ... 操作。'
        info "建角座標速查見 knowledge/playtesting-parts/01-why-and-usage.md"
        info "（下次可以加 --birth default，就不必碰滑鼠了）"
        return
    fi

    # 自動建角：夾具在 Birther:on_register 就把 descriptor 設好並 atEnd，
    # 之後等關卡真的生成完（[PLAYER BIRTH] resolved 之後才有 game.level）。
    wait_log "$RUN_LOG" '\[AUTOBIRTH\]' 60 "$game_pid" \
        || { dump_tail "$RUN_LOG" 20; die "夾具沒有作用（tome-autobirth 沒載入？規格檔沒寫進去？）"; }
    if grep -qa '\[AUTOBIRTH\] 放棄自動建角' "$RUN_LOG"; then
        grep -a '\[AUTOBIRTH\]' "$RUN_LOG" >&2
        _shot birth
        die "自動建角失敗，見上方 [AUTOBIRTH] 行（多半是 descriptor 名稱打錯）"
    fi
    wait_log "$RUN_LOG" '\[PLAYER BIRTH\] resolved' 180 "$game_pid" \
        || { grep -a '\[AUTOBIRTH\]' "$RUN_LOG" >&2; dump_tail "$RUN_LOG" 20; die "等不到建角完成"; }
    sleep 8
    _shot ingame
    ok "已自動建角（$birth_desc）並進入遊戲"
    info "取得狀態： tools/playtest.sh probe --list"
}

# ---------------------------------------------------------------------------
# 畫面
# ---------------------------------------------------------------------------
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

cmd_shot() { read_state; _shot "${1:?需要截圖名}"; }

cmd_zoom() {
    require_screenshot_tools
    local name="$1" w="$2" h="$3" x="$4" y="$5"
    magick "$SHOTS/p_$name.png" -crop "${w}x${h}+${x}+${y}" -resize 180% "$SHOTS/z_$name.png" \
        || die "裁切失敗"
    echo "$SHOTS/z_$name.png"
}

# ---------------------------------------------------------------------------
# 在活著的遊戲裡執行 Lua
# ---------------------------------------------------------------------------
# ctrl+L 開 Lua console（engine/data/keybinds/debug.lua:20-26），打字，Return 執行
# （engine/DebugConsole.lua:140-151 直接 loadstring + pcall），Escape 關掉。
#
# ⚠️ 執行結果只寫進 console 的畫面 history，**不會**進 stdout。
#    要拿到值就自己 print()——print 走 stdout 進 run.log。
#
# ⚠️ 這是 xdotool type：不吃換行，而且**只能 ASCII**——中文送不進去，
#    那一行會整個消失（不報錯，只是 print 不出來）。
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
#    彈窗會蓋在 console 上把後續輸入吃掉，sentinel 放後面就會誤判成失敗。
send_lua() {
    local code="$1"
    case "$code" in
        *$'\n'*) die "Lua 只能一行（xdotool type 不吃換行）" ;;
    esac

    local before after
    before="$(grep -ac '\[LUA\] ok' "$RUN_LOG" 2>/dev/null)"; before="${before:-0}"

    DISPLAY="$DISP" xdotool keydown ctrl; sleep 0.3
    DISPLAY="$DISP" xdotool key l;        sleep 0.3
    DISPLAY="$DISP" xdotool keyup ctrl;   sleep 3

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
        _shot lua >/dev/null
        die "Lua console 沒拿到焦點（它可能還沒畫出來，或當時有別的對話框擋著）"
    fi

    DISPLAY="$DISP" xdotool type --delay 25 "$code"; sleep 1
    DISPLAY="$DISP" xdotool key Return; sleep 2
    DISPLAY="$DISP" xdotool key Escape; sleep 1
}

cmd_lua() {
    read_state; require_cheat
    send_lua "${1:?需要一行 Lua}"
    _shot lua
}

# probe <名字> [ARG1 ARG2 ...]
#
# 跑 tools/probes/<名字>.lua：壓成單行 → 送進 console → 自動把它印的行撈回來。
# 比 `lua` 好用的地方是探測本體可以正常排版、寫中文註解、被語法檢查過，
# 而且**不必記得再跑一次 log**。
cmd_probe() {
    if [ "${1:-}" = "--list" ] || [ "$#" -eq 0 ]; then
        info "可用探測（tools/probes/）："
        local f n
        for f in "$MODKIT_PROBE_DIR"/*.lua; do
            [ -e "$f" ] || continue
            n="$(basename "$f" .lua)"
            printf '  %-12s %s\n' "$n" "$(sed -n '1s/^-- //p' "$f")"
        done
        info "用法: tools/playtest.sh probe <名字> [參數...]"
        return 0
    fi

    read_state; require_cheat; require_lua
    local name="$1"; shift
    local src="$MODKIT_PROBE_DIR/$name.lua"
    [ -f "$src" ] || die "沒有這個探測「$name」（tools/playtest.sh probe --list 看清單）"

    local code
    code="$("$LUA_BIN" "$MODKIT_LUA_DIR/flatten_probe.lua" "$src" "$@")" \
        || die "探測「$name」壓平失敗（見上方訊息）"

    local before
    before="$(wc -l < "$RUN_LOG" 2>/dev/null || echo 0)"
    send_lua "$code"

    # 只印這次新增的行，避免把先前的輸出重複撈出來
    local upper
    upper="$(printf '%s' "$name" | tr '[:lower:]' '[:upper:]')"
    local out
    out="$(tail -n "+$((before + 1))" "$RUN_LOG" 2>/dev/null | grep -aE "\[PROBE\.$upper\]|\[GAMELOG\]")"
    if [ -n "$out" ]; then
        printf '%s\n' "$out"
    else
        warn "探測「$name」沒有輸出。可能還沒進遊戲，或這支探測本來就只做事不印東西。"
        warn "看完整 log： tools/playtest.sh log"
    fi
}

cmd_log() {
    [ -f "$RUN_LOG" ] || die "沒有 run.log"
    local pat="${1:-\[[A-Z_.]+\] (selfcheck|hook|dbg)|\[PROBE\.|\[GAMELOG\]}"
    grep -aE "$pat" "$RUN_LOG"
    local n
    n="$(grep -ac 'Lua Error' "$RUN_LOG")"
    [ "$n" -gt 0 ] && { warn "Lua Error x$n："; grep -a -A 8 'Lua Error' "$RUN_LOG" | head -n 30; }
    return 0
}

cmd_status() {
    if [ -f "$GAME_PID_FILE" ] && kill -0 "$(cat "$GAME_PID_FILE")" 2>/dev/null; then
        ok "遊戲執行中（pid $(cat "$GAME_PID_FILE"), DISPLAY=$(cat "$STATE_DIR/display")）"
        info "state=$STATE_DIR  shots=$SHOTS"
    else
        info "沒有執行中的遊戲"
    fi
}

cmd_stop() {
    stop_game "$GAME_PID_FILE"
    [ -f "$XVFB_PID_FILE" ] && { kill "$(cat "$XVFB_PID_FILE")" 2>/dev/null; rm -f "$XVFB_PID_FILE"; }
    rm -f "$STATE_DIR/display"
    ok "已停止（截圖保留在 $SHOTS）"
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
