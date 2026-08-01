#!/usr/bin/env bash
# 從使用者的 Steam 安裝把四類素材解進 vendor/。固化 AGENTS.md「Fresh clone / 環境還原」那節的手動步驟。
#
# 用法：
#   tools/fetch-vendor.sh                       # 全部四步，已存在且完整的自動跳過
#   tools/fetch-vendor.sh --only gfx            # 只跑一步（gfx 306MB 最慢，單獨跑方便重試）
#   tools/fetch-vendor.sh --only dlc-ashes-urhrok --force   # 只重解一個最小的 DLC（35MB）
#   tools/fetch-vendor.sh --steam-dir /path/to/TalesMajEyal # 手動指定 Steam 安裝目錄
#   tools/fetch-vendor.sh --force                # 忽略已存在標記，全部重解
#
# 步驟名（--only 可重複給多個）：
#   engine           game/engines/te4-1.7.6.teae     → vendor/t-engine4/engines/te4-1.7.6/
#   tome             game/modules/tome.team          → vendor/t-engine4/modules/tome/（35MB）
#   gfx              game/modules/tome-gfx.team       → vendor/t-engine4/modules/tome/（疊上去，306MB）
#   dlc              三包 DLC 一次解（等於 dlc-orcs + dlc-cults + dlc-ashes-urhrok）
#   dlc-orcs         game/dlcs/orcs.teaac             → vendor/dlc/（151MB）
#   dlc-cults        game/dlcs/cults.teaac            → vendor/dlc/（146MB）
#   dlc-ashes-urhrok game/dlcs/ashes-urhrok.teaac     → vendor/dlc/（35MB，四包裡最小）
#
# 全部都是純 zip，用 unzip -qo 解，不執行、不改動來源檔——只從 Steam 目錄讀，絕不寫進去
# （AGENTS.md 鐵律 3）。
#
# 冪等：每一步在解壓前先檢查目的地是否已有該步驟獨有的標記檔／目錄，有就印「已存在，跳過」
# 並直接下一步；--force 忽略標記、強制重解該步驟。
#
# Steam 安裝目錄的偵測順序：
#   1. --steam-dir 參數
#   2. TOME_GAME_DIR 環境變數（與其他 tools/ 腳本共用同一個變數，見 lib/paths.sh）
#   3. 幾個常見的固定安裝路徑（原生 Steam / Flatpak Steam）
#   都找不到就報錯並列出試過的路徑，同時提示怎麼手動指定。

source "$(dirname "$0")/lib.sh"
handle_help_flag "$@"
require_cmd unzip "pacman -S unzip"

VENDOR_DIR="$MODKIT_ROOT/vendor"
DLC_DIR="$VENDOR_DIR/dlc"
# TOME_SRC 來自 lib/paths.sh，預設就是 vendor/t-engine4，可被同名環境變數蓋掉
ENGINE_DST="$TOME_SRC/engines/te4-1.7.6"
MODULE_DST="$TOME_SRC/modules/tome"

STEAM_DIR_ARG=""
FORCE=0
declare -a ONLY_STEPS=()

while [ "$#" -gt 0 ]; do
    case "$1" in
        --steam-dir) STEAM_DIR_ARG="$2"; shift ;;
        --only) ONLY_STEPS+=("$2"); shift ;;
        --force) FORCE=1 ;;
        -h|--help) usage_from_header "$0"; exit 0 ;;
        *) die "未知參數: $1（-h 看說明）" ;;
    esac
    shift
done

# ---- 偵測 Steam 安裝目錄 ----------------------------------------------------

resolve_steam_dir() {
    local candidates=() c
    if [ -n "$STEAM_DIR_ARG" ]; then
        candidates=("$STEAM_DIR_ARG")
    else
        candidates=(
            "$TOME_GAME_DIR"
            "$HOME/.steam/steam/steamapps/common/TalesMajEyal"
            "$HOME/.local/share/Steam/steamapps/common/TalesMajEyal"
            "$HOME/.steam/root/steamapps/common/TalesMajEyal"
            "$HOME/.var/app/com.valvesoftware.Steam/data/Steam/steamapps/common/TalesMajEyal"
            "/usr/share/steam/steamapps/common/TalesMajEyal"
        )
    fi
    TRIED_STEAM_DIRS=()
    for c in "${candidates[@]}"; do
        [ -n "$c" ] || continue
        # 去重，避免同一個路徑在錯誤訊息裡印兩次
        case " ${TRIED_STEAM_DIRS[*]} " in *" $c "*) continue ;; esac
        TRIED_STEAM_DIRS+=("$c")
        if [ -d "$c/game" ]; then
            echo "$c"
            return 0
        fi
    done
    return 1
}

STEAM_DIR="$(resolve_steam_dir)" || {
    info "試過以下路徑，都找不到 game/ 子目錄："
    for c in "${TRIED_STEAM_DIRS[@]}"; do info "  - $c"; done
    die "找不到 Tales of Maj'Eyal 的 Steam 安裝。用 --steam-dir <路徑> 或 export TOME_GAME_DIR=<路徑> 指定。"
}
ok "Steam 安裝目錄: $STEAM_DIR"

# ---- 單步解壓的共用邏輯 ------------------------------------------------------

# extract_one <來源.zip 絕對路徑> <解到哪個目錄> <完成標記檔/目錄(相對解到目錄)> <人看的名字>
extract_one() {
    local src="$1" dst="$2" marker="$3" label="$4"
    [ -f "$src" ] || die "來源檔不存在: $src（Steam 安裝可能不完整或版本不是 1.7.6）"
    if [ "$FORCE" -ne 1 ] && [ -e "$dst/$marker" ]; then
        ok "$label 已存在，跳過（$dst/$marker）"
        return 0
    fi
    mkdir -p "$dst"
    info "$label 解壓中：$src → $dst"
    unzip -qo "$src" -d "$dst"
    [ -e "$dst/$marker" ] || die "$label 解壓完但沒看到預期的 $marker，解壓可能不完整"
    ok "$label 完成"
}

step_engine() {
    extract_one "$STEAM_DIR/game/engines/te4-1.7.6.teae" "$ENGINE_DST" "engine" "engine"
}

step_tome() {
    extract_one "$STEAM_DIR/game/modules/tome.team" "$MODULE_DST" "mod" "tome 模組 Lua"
}

step_gfx() {
    extract_one "$STEAM_DIR/game/modules/tome-gfx.team" "$MODULE_DST" "data/gfx" "tome 美術資產(gfx)"
}

step_dlc_one() {
    local name="$1" label="$2"
    extract_one "$STEAM_DIR/game/dlcs/$name.teaac" "$DLC_DIR" "tome-$name" "DLC $label"
}
step_dlc_orcs()          { step_dlc_one "orcs" "orcs"; }
step_dlc_cults()         { step_dlc_one "cults" "cults"; }
step_dlc_ashes_urhrok()  { step_dlc_one "ashes-urhrok" "ashes-urhrok"; }
step_dlc() { step_dlc_orcs; step_dlc_cults; step_dlc_ashes_urhrok; }

# ---- 決定要跑哪些步驟 --------------------------------------------------------

if [ "${#ONLY_STEPS[@]}" -eq 0 ]; then
    ONLY_STEPS=(engine tome gfx dlc)
fi

for step in "${ONLY_STEPS[@]}"; do
    case "$step" in
        engine)            step_engine ;;
        tome)               step_tome ;;
        gfx)                step_gfx ;;
        dlc)                step_dlc ;;
        dlc-orcs)           step_dlc_orcs ;;
        dlc-cults)          step_dlc_cults ;;
        dlc-ashes-urhrok)   step_dlc_ashes_urhrok ;;
        *) die "未知步驟: $step（可用: engine tome gfx dlc dlc-orcs dlc-cults dlc-ashes-urhrok）" ;;
    esac
done

ok "vendor/ 還原完成（$(du -sh "$VENDOR_DIR" 2>/dev/null | cut -f1)）"
