#!/usr/bin/env bash
# 共用函式庫的**聚合入口**。用 `source "$(dirname "$0")/lib.sh"` 引入，不要直接執行。
#
# 實作按職責拆在 tools/lib/ 底下，本檔只負責照順序載入（有相依關係，順序不能亂）：
#
#   lib/log.sh      die / info / ok / warn、--help 從檔頭生成
#   lib/paths.sh    MODKIT_ROOT、TOME_* 等所有路徑常數（皆可用環境變數覆寫）
#   lib/deps.sh     require_lua / require_game / require_headless_tools ...
#   lib/addon.sh    resolve_addon_dir / addon_names / addon_field
#   lib/scratch.sh  prepare_scratch_home / enable_cheat_mode / write_autobirth_spec
#   lib/game.sh     pick_free_display / start_xvfb / launch_game / stop_game / wait_log
#
# 只放**共用**的部分。單一進入口專屬的實作放自己的子目錄，由該進入口自己 source：
#   lib/playtest/  只有 playtest.sh 需要（session / screen / console 三塊）
#
# Lua 那一側的邏輯（判讀、欄位檢查、探測）在 tools/lua/ 與 tools/probes/，
# 不由本檔載入——各進入口自己呼叫。分工理由見 tools/README.md。

set -euo pipefail

_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"

# shellcheck source=lib/log.sh
source "$_LIB_DIR/log.sh"
# shellcheck source=lib/paths.sh
source "$_LIB_DIR/paths.sh"
# shellcheck source=lib/deps.sh
source "$_LIB_DIR/deps.sh"
# shellcheck source=lib/addon.sh
source "$_LIB_DIR/addon.sh"
# shellcheck source=lib/scratch.sh
source "$_LIB_DIR/scratch.sh"
# shellcheck source=lib/game.sh
source "$_LIB_DIR/game.sh"

# Lua 邏輯層與探測庫的位置，給各進入口用
MODKIT_LUA_DIR="$MODKIT_ROOT/tools/lua"
MODKIT_PROBE_DIR="$MODKIT_ROOT/tools/probes"
