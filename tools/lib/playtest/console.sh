#!/usr/bin/env bash
# playtest 取得純文字狀態的唯一通道：把 Lua 送進活著的遊戲，再從 run.log 撈回來。
# 用 `source` 引入，不要直接執行。只給 tools/playtest.sh 用。
#
# 這是**分工鐵律的落點**：AI 要的狀態一律走這裡（probe / lua / log 都回純文字），
# 截圖那條路（screen.sh）是產給使用者看的。探測手法全集見
# knowledge/playtesting-parts/03-state-probes.md。
#
# 依賴的外部變數（由 playtest.sh 定義）：RUN_LOG、DISP

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
