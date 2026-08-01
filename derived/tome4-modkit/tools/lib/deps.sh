#!/usr/bin/env bash
# 外部相依檢查。用 `source` 引入，不要直接執行。
#
# 原則：缺東西要在**動手之前**就講清楚缺哪個、怎麼裝，
# 不要跑到一半才用一句看不懂的錯誤炸掉。

# require_cmd <指令> [安裝提示]
require_cmd() {
    command -v "$1" >/dev/null 2>&1 \
        || die "找不到指令「$1」${2:+（$2）}"
}

require_lua() {
    [ -n "${LUA_BIN:-}" ] || die "找不到 lua/luajit。裝一個：pacman -S luajit"
}

require_game() {
    [ -x "$TOME_GAME_DIR/t-engine64" ] \
        || die "找不到執行檔 $TOME_GAME_DIR/t-engine64（用 TOME_GAME_DIR= 覆寫）"
}

# 無頭測試（verify.sh / playtest.sh）共同需要的一組工具
require_headless_tools() {
    require_cmd Xvfb    "pacman -S xorg-server-xvfb"
    require_cmd xdotool "pacman -S xdotool"
}

# playtest.sh 額外需要截圖與裁切
require_screenshot_tools() {
    require_cmd import  "pacman -S imagemagick"
    require_cmd magick  "pacman -S imagemagick"
}
