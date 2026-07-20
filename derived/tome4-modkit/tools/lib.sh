#!/usr/bin/env bash
# 共用路徑與工具偵測。用 `source` 引入，不要直接執行。
# 所有路徑可用同名環境變數覆寫。

set -euo pipefail

MODKIT_ROOT="${MODKIT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# 遊戲安裝（含 t-engine64 執行檔）
TOME_GAME_DIR="${TOME_GAME_DIR:-$HOME/.steam/steam/steamapps/common/TalesMajEyal}"
# 使用者 t-engine home（addons 佈署目標；引擎把它掛在 PhysFS 的 "/"）
TOME_HOME="${TOME_HOME:-$HOME/.t-engine}"
TOME_ADDONS_DIR="${TOME_ADDONS_DIR:-$TOME_HOME/4.0/addons}"
# 唯讀原始碼真相層
TOME_SRC="${TOME_SRC:-$HOME/repo/moddings/tome4/projects/t-engine4}"

# addon 原始碼放這裡，一個子目錄一個 addon
MODS_DIR="${MODS_DIR:-$MODKIT_ROOT/mods}"
BUILD_DIR="${BUILD_DIR:-$MODKIT_ROOT/build}"

LUA_BIN="${LUA_BIN:-$(command -v luajit || command -v lua5.1 || command -v lua || true)}"

die()  { printf '\033[31m[FAIL]\033[0m %s\n' "$*" >&2; exit 1; }
info() { printf '\033[36m[INFO]\033[0m %s\n' "$*"; }
ok()   { printf '\033[32m[ OK ]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$*" >&2; }

require_lua() {
    [ -n "$LUA_BIN" ] || die "找不到 lua/luajit。裝一個：pacman -S luajit"
}

require_game() {
    [ -x "$TOME_GAME_DIR/t-engine64" ] \
        || die "找不到執行檔 $TOME_GAME_DIR/t-engine64（用 TOME_GAME_DIR= 覆寫）"
}

# 解析 addon 目錄參數：接受 "runewright"、"tome-runewright" 或完整路徑
resolve_addon_dir() {
    local a="$1"
    if [ -d "$a" ] && [ -f "$a/init.lua" ]; then (cd "$a" && pwd); return; fi
    if [ -d "$MODS_DIR/$a" ]; then (cd "$MODS_DIR/$a" && pwd); return; fi
    if [ -d "$MODS_DIR/tome-$a" ]; then (cd "$MODS_DIR/tome-$a" && pwd); return; fi
    die "找不到 addon「$a」（找過：$a、$MODS_DIR/$a、$MODS_DIR/tome-$a）"
}

# 從 init.lua 取出某個頂層欄位（用 lua 求值，不用 grep，避免註解誤判）
# 注意：`luajit -e` 的 chunk 拿不到命令列參數的 `...`（只有跑檔案時才有），
# 所以參數要透過環境變數傳進去。
addon_field() {
    local dir="$1" field="$2"
    require_lua
    AF_DIR="$dir" AF_FIELD="$field" "$LUA_BIN" -e '
        local dir, field = os.getenv("AF_DIR"), os.getenv("AF_FIELD")
        local env = {}
        local f = loadfile(dir.."/init.lua")
        if not f then return end
        setfenv(f, env); pcall(f)
        local v = env[field]
        if type(v) == "table" then io.write(table.concat(v, "."))
        elseif v ~= nil then io.write(tostring(v)) end
    '
}
