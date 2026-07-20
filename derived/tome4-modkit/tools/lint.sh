#!/usr/bin/env bash
# 靜態檢查一個 addon：Lua 語法 + init.lua 欄位。
# 用法： tools/lint.sh <addon>        # addon 可為名稱或路徑
# 退出碼： 0 通過 / 1 有錯

source "$(dirname "$0")/lib.sh"
require_lua

[ "$#" -ge 1 ] || die "用法: tools/lint.sh <addon>"
ADDON_DIR="$(resolve_addon_dir "$1")"
info "lint: $ADDON_DIR"

fails=0
count=0

# 1) 每個 .lua 都要能編譯過（luajit -b 只編譯不執行）
while IFS= read -r -d '' f; do
    count=$((count + 1))
    if ! out="$("$LUA_BIN" -b "$f" /dev/null 2>&1)"; then
        printf '\033[31m[FAIL]\033[0m %s\n%s\n' "${f#"$ADDON_DIR"/}" "$out"
        fails=$((fails + 1))
    fi
done < <(find "$ADDON_DIR" -name '*.lua' -type f -print0)

if [ "$fails" -gt 0 ]; then
    die "$fails/$count 個 .lua 有語法錯誤"
fi
ok "$count 個 .lua 語法通過"

# 2) init.lua 欄位語意
"$LUA_BIN" "$MODKIT_ROOT/tools/check_init.lua" "$ADDON_DIR" || die "init.lua 檢查失敗"
ok "init.lua 欄位通過"

ok "lint 全部通過: $(basename "$ADDON_DIR")"
