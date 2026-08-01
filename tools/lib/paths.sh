#!/usr/bin/env bash
# 所有路徑常數。用 `source` 引入，不要直接執行。
#
# 每一個都可以用同名環境變數覆寫，例如：
#   TOME_GAME_DIR=/opt/tome tools/verify.sh tome-relics
#
# MODKIT_ROOT 由本檔位置往上兩層推導（tools/lib/paths.sh → modkit 根），
# 所以整包 modkit 搬到任何路徑都不用改設定。

# modkit 自身的根目錄
MODKIT_ROOT="${MODKIT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

# 遊戲安裝（含 t-engine64 執行檔）
TOME_GAME_DIR="${TOME_GAME_DIR:-$HOME/.steam/steam/steamapps/common/TalesMajEyal}"
# 使用者 t-engine home（addons 佈署目標；引擎把它掛在 PhysFS 的 "/"）
TOME_HOME="${TOME_HOME:-$HOME/.t-engine}"
TOME_ADDONS_DIR="${TOME_ADDONS_DIR:-$TOME_HOME/4.0/addons}"
# 唯讀原始碼真相層（引擎 + tome 模組的 Lua 源碼）
TOME_SRC="${TOME_SRC:-$HOME/repo/moddings/tome4/vendor/t-engine4}"

# addon 原始碼放這裡，一個子目錄一個 addon
MODS_DIR="${MODS_DIR:-$MODKIT_ROOT/self_mods}"
BUILD_DIR="${BUILD_DIR:-$MODS_DIR/build}"

LUA_BIN="${LUA_BIN:-$(command -v luajit || command -v lua5.1 || command -v lua || true)}"
