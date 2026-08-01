#!/usr/bin/env bash
# playtest 的畫面與輸入：截圖、裁切、送滑鼠鍵盤。
# 用 `source` 引入，不要直接執行。只給 tools/playtest.sh 用。
#
# ⚠️ 這裡每個動作都綁在 $DISP（本腳本自己開的 Xvfb），**絕不碰真實桌面**。
#
# ⚠️ 截圖是**產給使用者看的**——畫面、渲染、手感、平衡由使用者判斷。
#    AI 要取得狀態請用 console.sh 的 probe / lua（回傳純文字），不要讀圖。
#
# 依賴的外部變數（由 playtest.sh 定義）：SHOTS、DISP

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
