#!/usr/bin/env bash
# 遊戲行程與 X display 的編排。用 `source` 引入，不要直接執行。
#
# 這一層刻意留在 bash：本機沒有 lfs / luaposix，純 Lua 做不到 spawn、signal、
# process group 與輪詢，硬搬過去只會變成一堆 os.execute。
# 判讀 run.log 的邏輯不在這裡，在 tools/lua/verdict.lua。

# pick_free_display <起始 display>
# 挑一個沒被佔用的 X display（":97" → ":98" → ...）
pick_free_display() {
    local d="$1" n
    n="${d#:}"
    while [ -e "/tmp/.X${n}-lock" ]; do
        n=$((n + 1))
        d=":$n"
    done
    printf '%s' "$d"
}

# start_xvfb <display> <w> <h> <xvfb_log> <pid_file>
#
# 起 Xvfb 並確認它真的活著。失敗時把 Xvfb 自己的 log 印出來——
# 不然只會看到「連不上 display」這種查不出原因的錯誤。
start_xvfb() {
    local disp="$1" w="$2" h="$3" xvfb_log="$4" pid_file="$5"
    setsid Xvfb "$disp" -screen 0 "${w}x${h}x24" -nolisten tcp \
        </dev/null >"$xvfb_log" 2>&1 &
    local pid=$!
    echo "$pid" > "$pid_file"
    sleep 1
    if ! kill -0 "$pid" 2>/dev/null; then
        warn "Xvfb log："; cat "$xvfb_log" >&2
        die "Xvfb 啟動失敗（display $disp）"
    fi
}

# launch_game <scratch(--home 傳的那層)> <display> <run_log> <pid_file> [timeout_secs]
#
# 三件事改動前先讀：
#  1) 不可加 --no-debug。它會讓引擎吞掉 Lua 的 print 輸出，於是 addon 的
#     "[X] selfcheck ... = OK" / "[X] hook complete" 一行都不會出現，
#     連引擎自己的 "Checking addon" 也會消失——看起來像 addon 沒載入，其實只是我們瞎了。
#     （--logtofile 也不要用：它把輸出轉去 te4_log.txt 並改變啟動行為。）
#  2) cwd 必須是 TOME_GAME_DIR。執行檔靠相對路徑找 game/ 資料，
#     從別的目錄啟動會停在啟動早期、連主選單都到不了。
#  3) 一律 setsid。這讓遊戲成為自己 process group 的 leader，
#     stop_game() 才能用「殺整個 group」精準收掉它與 timeout 子行程，
#     而不必用 `pkill -x t-engine64`——那會**連使用者自己在桌面開的遊戲一起殺掉**。
launch_game() {
    local scratch="$1" disp="$2" run_log="$3" pid_file="$4" tmo="${5:-600}"
    (
        cd "$TOME_GAME_DIR" || exit 1
        DISPLAY="$disp" LIBGL_ALWAYS_SOFTWARE=1 setsid timeout "$tmo" ./t-engine64 \
            --no-steam --no-web --flush-stdout --home "$scratch" \
            </dev/null >"$run_log" 2>&1 &
        echo $! > "$pid_file"
    )
}

# stop_game <pid_file> [等待秒數]
#
# 殺掉 launch_game 起的整個 process group 並等它死透。
#
# 為什麼要等：kill 是非同步的。不等的話，緊接著的下一次 launch 會撞上還在收屍的
# 舊行程與它佔著的 X display。
#
# 為什麼是 group kill 而不是 pkill -x t-engine64：
#   setsid 讓遊戲成為 process group leader，`kill -- -<pid>` 只會殺到我們自己起的那棵樹。
#   pkill 是**全域**的，會誤殺使用者用 tools/run.sh 在真實桌面開的遊戲。
stop_game() {
    local pid_file="$1" tmo="${2:-15}" pid=""
    [ -f "$pid_file" ] && pid="$(cat "$pid_file" 2>/dev/null)"
    [ -n "$pid" ] || return 0

    kill -9 -- "-$pid" 2>/dev/null || kill -9 "$pid" 2>/dev/null

    local i=0
    while kill -0 "$pid" 2>/dev/null && [ "$i" -lt "$tmo" ]; do
        sleep 1; i=$((i + 1))
    done
    kill -0 "$pid" 2>/dev/null && warn "行程 $pid 仍未結束"
    rm -f "$pid_file"
}

# wait_log <run_log> <regex> <逾時秒數> [遊戲 pid]
#
# 輪詢 log 等某個字串出現。永遠用這個，不要用固定 sleep——軟體 GL 很慢且慢得不穩定。
# 給了 pid 就會順便偵測行程猝死，可以早點失敗而不是白等到逾時。
#
# 退出碼： 0=等到了 / 1=逾時 / 2=行程已死
wait_log() {
    local log="$1" pat="$2" tmo="$3" pid="${4:-}" i=0
    while [ "$i" -lt "$tmo" ]; do
        [ -f "$log" ] && grep -qaE "$pat" "$log" 2>/dev/null && return 0
        if [ -n "$pid" ] && ! kill -0 "$pid" 2>/dev/null; then return 2; fi
        sleep 1
        i=$((i + 1))
    done
    return 1
}

# dump_tail <run_log> [行數] —— 失敗時把現場印出來，別讓 agent 只看到一句逾時
dump_tail() {
    warn "run.log 最後 ${2:-40} 行："
    tail -n "${2:-40}" "$1" >&2
}
