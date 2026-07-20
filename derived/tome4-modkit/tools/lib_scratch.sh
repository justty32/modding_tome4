#!/usr/bin/env bash
# 準備一個乾淨、可拋棄的 t-engine 家目錄，並挑一個空的 X display。
# 由 tools/verify.sh（無頭載入驗證）與 tools/playtest.sh（實機遊玩）共用。
# 用 `source` 引入，需先 source lib.sh。

# --- `--home` 的真實語意（實測，別踩） -------------------------------------
# `t-engine64 --home <dir>` 只覆寫 fs.getUserPath()；引擎會**無條件再接上**
# `/.t-engine/4.0`。所以真正的 settings / profiles / addons 根目錄是
#     <dir>/.t-engine/4.0/{settings,addons,profiles}/
# 不是 <dir>/4.0/...
# ---------------------------------------------------------------------------

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

# prepare_scratch_home <actual_home> <keep_addon_short_name> <w> <h> [locale]
#
# 在 <actual_home>（也就是 <scratch>/.t-engine）底下寫好所有能「少一個彈窗」的狀態。
# 每一項都是實測必要的，刪掉任何一項自動化就會卡在某個對話框上。
prepare_scratch_home() {
    local actual_home="$1" keep_addon="$2" w="$3" h="$4" locale="${5:-zh_hant}"
    local settings="$actual_home/4.0/settings"
    local profile="$actual_home/4.0/profiles/online/generic"

    mkdir -p "$settings" "$profile" "$actual_home/4.0/addons"

    # 跳過開場「歡迎／線上功能」彈窗。
    # 這個**不是** .cfg，而是另一份序列化的 profile 檔（mod/class/Game.lua:596 checkFirstTime），
    # 所以光靠 settings/*.cfg 殺不掉它。
    printf 'firstrun = 1\n' > "$profile/firstrun.profile"

    printf 'firstrun_gdpr = true\n'        > "$settings/firstrun_gdpr.cfg"
    printf 'disable_all_connectivity = true\n' > "$settings/disable_all_connectivity.cfg"
    printf 'background_saves = true\n'     > "$settings/background_saves.cfg"

    # 跳過三個 DLC「感謝購買」宣傳彈窗
    # （game/dlcs/{ashes-urhrok,orcs,cults}.teaac 的 superload/mod/dialogs/Birther.lua
    #  各自檢查下列旗標，true 就跳過）
    printf 'tome.ashes_urhrok_started = true\n'    > "$settings/tome_ashes_urhrok_started.cfg"
    printf 'tome.embers_of_rage_started = true\n'  > "$settings/tome_embers_of_rage_started.cfg"
    printf 'tome.forbidden_cults_started = true\n' > "$settings/tome_forbidden_cults_started.cfg"

    # 語系。預設 zh_hant，與使用者真實環境一致。
    # ⚠️ 英文語系的字型**沒有 CJK 字符**，中文的技能樹名會渲染成空白——
    #    用滑鼠座標驅動 UI 時，語系不同版面行距也會不同。
    printf 'locale = "%s"\n' "$locale" > "$settings/locale.cfg"

    # 視窗模式，解析度與 Xvfb 一致，讓滑鼠座標可預期。
    printf "window.size = '%sx%s Windowed'\n" "$w" "$h" > "$settings/resolution.cfg"

    # 停用 game/addons/ 下**全部**第三方社群 addon。
    # 非做不可：Odyssey of The Summoner（neka_therianthropy_summoner）在 New Game 時
    # 必定拋 EFF_EXHAUSTION 重複定義的 Lua Error（engine/interface/ActorTemporaryEffects.lua:59），
    # 與本專案無關，桌面版一樣會炸。
    #
    # engine/Module.lua:583-598：列在 cfg 且為 false 才會被移除；**沒列到的維持預設啟用**。
    # 所以待測 addon 不列進去。
    {
        echo 'addons = {}'
        echo 'addons["tome"] = {}'
        if [ -d "$TOME_GAME_DIR/game/addons" ]; then
            for f in "$TOME_GAME_DIR"/game/addons/tome-*.teaa; do
                [ -e "$f" ] || continue
                local n
                n="$(basename "$f" .teaa)"; n="${n#tome-}"
                [ "$n" = "$keep_addon" ] && continue
                printf 'addons["tome"]["%s"] = false\n' "$n"
            done
        fi
    } > "$settings/addons.cfg"
}

# enable_cheat_mode <actual_home>
#
# 開啟引擎的 Developer Mode。這會多綁兩個鍵（engine/data/keybinds/debug.lua:20-33，
# 兩個 defineAction 都標了 only_on_cheat = true）：
#   ctrl+L → LUA_CONSOLE   ctrl+A → DEBUG_MODE
# 兩個 handler 在 mod/class/Game.lua:2405-2415 還會再檢查一次 config.settings.cheat。
#
# 開關就是 settings/cheat.cfg，遊戲自己也是這樣寫的（engine/dialogs/GameMenu.lua:117）。
#
# ⚠️ 只給 playtest.sh 用，不要塞進 verify.sh：cheat 模式會改變引擎行為
#    （例如 engine/Particles.lua:61,81 對缺檔粒子的處理），
#    而 verify 的職責是「在最接近使用者的環境下確認 addon 載入」。
enable_cheat_mode() {
    local actual_home="$1"
    printf 'cheat = true\n' > "$actual_home/4.0/settings/cheat.cfg"
}

# launch_game <actual_home_parent(scratch)> <display> <run_log> <pid_file> [timeout_secs]
#
# 兩件事改動前先讀：
#  1) 不可加 --no-debug。它會讓引擎吞掉 Lua 的 print 輸出，於是 addon 的
#     "[X] selfcheck ... = OK" / "[X] hook complete" 一行都不會出現，
#     連引擎自己的 "Checking addon" 也會消失——看起來像 addon 沒載入，其實只是我們瞎了。
#  2) cwd 必須是 TOME_GAME_DIR。執行檔靠相對路徑找 game/ 資料。
#     （--logtofile 也不要用：它把輸出轉去 te4_log.txt 並改變啟動行為。）
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

# wait_log_file <run_log> <regex> <timeout_secs> —— 輪詢 log，不要用固定 sleep
wait_log_file() {
    local log="$1" pat="$2" tmo="$3" i=0
    while [ "$i" -lt "$tmo" ]; do
        grep -qE "$pat" "$log" 2>/dev/null && return 0
        sleep 1
        i=$((i + 1))
    done
    return 1
}
