#!/usr/bin/env bash
# 靜態檢查一個 addon：Lua 語法 + init.lua 欄位語意。不啟動遊戲，秒級完成。
#
# 用法： tools/lint.sh <addon>
#        <addon> 可以是 runewright、tome-runewright、或完整路徑
# 退出碼：0 通過 / 1 有錯
#
# 這是最便宜的一關，改完程式碼**一定先跑這支**再談其他。
# 它抓得到：語法錯誤、init.lua 缺欄位、version 與模組不相容、hooks 忘了 require。
# 它抓不到：任何執行期行為——那要 tools/verify.sh（載入）與 tools/playtest.sh（遊玩）。

source "$(dirname "$0")/lib.sh"
handle_help_flag "$@"
require_lua

[ "$#" -ge 1 ] || die "用法: tools/lint.sh <addon>（-h 看說明）"
addon_names "$1"
info "lint: $ADDON_DIR"

fails=0
count=0

# 1) 每個 .lua 都要能編譯過（luajit -b 只編譯不執行，所以不會有副作用）
while IFS= read -r -d '' f; do
    count=$((count + 1))
    if ! out="$("$LUA_BIN" -b "$f" /dev/null 2>&1)"; then
        printf '\033[31m[FAIL]\033[0m %s\n%s\n' "${f#"$ADDON_DIR"/}" "$out"
        fails=$((fails + 1))
    fi
done < <(find "$ADDON_DIR" -name '*.lua' -type f -print0)

[ "$fails" -eq 0 ] || die "$fails/$count 個 .lua 有語法錯誤"
ok "$count 個 .lua 語法通過"

# 2) init.lua 欄位語意（規則與引擎行號都在該檔檔頭）
"$LUA_BIN" "$MODKIT_LUA_DIR/check_init.lua" "$ADDON_DIR" || die "init.lua 檢查失敗"
ok "init.lua 欄位通過"

ok "lint 全部通過: $ADDON_BASE"
