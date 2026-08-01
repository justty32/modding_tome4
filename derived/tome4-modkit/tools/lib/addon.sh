#!/usr/bin/env bash
# addon 目錄解析與 init.lua 欄位讀取。用 `source` 引入，不要直接執行。

# resolve_addon_dir <名稱或路徑>
#
# 接受三種寫法，回傳絕對路徑：
#   runewright        → $MODS_DIR/tome-runewright
#   tome-runewright   → $MODS_DIR/tome-runewright
#   /path/to/addon    → 原路徑（需含 init.lua）
resolve_addon_dir() {
    local a="$1"
    if [ -d "$a" ] && [ -f "$a/init.lua" ]; then (cd "$a" && pwd); return; fi
    if [ -d "$MODS_DIR/$a" ]; then (cd "$MODS_DIR/$a" && pwd); return; fi
    if [ -d "$MODS_DIR/tome-$a" ]; then (cd "$MODS_DIR/tome-$a" && pwd); return; fi
    die "找不到 addon「$a」（找過：$a、$MODS_DIR/$a、$MODS_DIR/tome-$a）"
}

# addon_names <名稱或路徑>
#
# 一次算出四個到處都要用的字串，設進呼叫端的變數：
#   ADDON_DIR   絕對路徑
#   ADDON_BASE  目錄名，形如 tome-runewright
#   ADDON_SHORT 去掉 tome- 前綴，形如 runewright
#   ADDON_UPPER 全大寫，形如 RUNEWRIGHT
#
# ADDON_UPPER 是 addon 自報 log 的前綴慣例：`[RUNEWRIGHT] hook complete`、
# `[RUNEWRIGHT] selfcheck xxx = OK`。verify.sh 靠它判定成功與否，
# 所以新 addon 的 hooks 一定要用**大寫 short_name**當標籤。
addon_names() {
    ADDON_DIR="$(resolve_addon_dir "$1")"
    ADDON_BASE="$(basename "$ADDON_DIR")"
    ADDON_SHORT="${ADDON_BASE#tome-}"
    ADDON_UPPER="$(printf '%s' "$ADDON_SHORT" | tr '[:lower:]' '[:upper:]')"
}

# addon_field <addon 目錄> <欄位名>
#
# 從 init.lua 取出某個頂層欄位（table 會串成 "1.7.6" 這種形式）。
# 實作在 tools/lua/addon_field.lua——那是真的用 Lua 求值，不是 grep。
addon_field() {
    require_lua
    "$LUA_BIN" "$MODKIT_ROOT/tools/lua/addon_field.lua" "$1" "$2"
}
