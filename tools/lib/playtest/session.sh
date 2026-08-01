#!/usr/bin/env bash
# playtest 的 session 生命週期：開起來、看狀態、收乾淨。
# 用 `source` 引入，不要直接執行。只給 tools/playtest.sh 用。
#
# 相依：lib.sh 的全部（addon_names / prepare_scratch_home / launch_game / wait_log …），
#       以及同層 screen.sh 的 _shot（失敗時要留畫面給使用者看）。
#
# 依賴的外部變數（由 playtest.sh 定義）：
#   STATE_DIR SHOTS RUN_LOG GAME_PID_FILE XVFB_PID_FILE
# 會設定的全域：DISP（目前這個 session 綁的 X display）

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

    BIRTH_DESC=""
    [ -n "$birth" ] && _setup_autobirth "$actual_home" "$birth"

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

    _wait_main_menu "$game_pid"
    _enter_new_game "$game_pid"

    if [ -z "$birth" ]; then
        _shot birth
        ok '已停在建角畫面。接下來用 tools/playtest.sh do ... 操作。'
        info "建角座標速查見 docs/knowledge/playtesting-parts/01-why-and-usage.md"
        info "（下次可以加 --birth default，就不必碰滑鼠了）"
        return
    fi

    _wait_birth_done "$game_pid"
    sleep 8
    _shot ingame
    ok "已自動建角（$BIRTH_DESC）並進入遊戲"
    info "取得狀態： tools/playtest.sh probe --list"
}

# --birth：加掛 tome-autobirth 夾具 + 寫規格檔，讓建角完全不碰滑鼠鍵盤。
# 把人看的描述字串放進全域 BIRTH_DESC（不走 stdout——`ok` 也印 stdout，
# 用 $() 捕捉會把進度訊息一起吃掉）。
_setup_autobirth() {
    local actual_home="$1" birth="$2"
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
    BIRTH_DESC="$b_subrace $b_subclass"
    ok "autobirth 已設定：$BIRTH_DESC"
}

_wait_main_menu() {
    local game_pid="$1"
    wait_log "$RUN_LOG" 'Switching to realtime, interval 125 ms' 120 "$game_pid" \
        || { dump_tail "$RUN_LOG" 30; die "等不到主選單"; }
    ok "已到主選單"
    sleep 3
}

# ⚠️ 不要靠 sleep 賭時機。"Switching to realtime" 在 log 裡會出現兩次
#    （第一次是引擎啟動，第二次才是主選單模組），而 --cheat 會多載入東西讓時序偏移，
#    於是 Return 可能落在選單畫出來之前，整個 start 就卡死。
#    改成按了沒反應就重按，最多 4 次。
_enter_new_game() {
    local game_pid="$1"
    _shot mainmenu >/dev/null   # 失敗時要有畫面可看
    local tries=0 started=0
    while [ "$tries" -lt 4 ]; do
        DISPLAY="$DISP" xdotool key --clearmodifiers Return
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
}

# 夾具在 Birther:on_register 就把 descriptor 設好並 atEnd，
# 之後等關卡真的生成完（[PLAYER BIRTH] resolved 之後才有 game.level）。
_wait_birth_done() {
    local game_pid="$1"
    wait_log "$RUN_LOG" '\[AUTOBIRTH\]' 60 "$game_pid" \
        || { dump_tail "$RUN_LOG" 20; die "夾具沒有作用（tome-autobirth 沒載入？規格檔沒寫進去？）"; }
    if grep -qa '\[AUTOBIRTH\] 放棄自動建角' "$RUN_LOG"; then
        grep -a '\[AUTOBIRTH\]' "$RUN_LOG" >&2
        _shot birth
        die "自動建角失敗，見上方 [AUTOBIRTH] 行（多半是 descriptor 名稱打錯）"
    fi
    wait_log "$RUN_LOG" '\[PLAYER BIRTH\] resolved' 180 "$game_pid" \
        || { grep -a '\[AUTOBIRTH\]' "$RUN_LOG" >&2; dump_tail "$RUN_LOG" 20; die "等不到建角完成"; }
}

# ---------------------------------------------------------------------------
# status / stop
# ---------------------------------------------------------------------------
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
