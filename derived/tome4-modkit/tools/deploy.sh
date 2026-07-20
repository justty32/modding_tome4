#!/usr/bin/env bash
# 冪等地把 addon 佈署到 t-engine 的 addons 目錄。
# 用法：
#   tools/deploy.sh <addon>                 # 目錄形式佈署（開發用，改檔即生效）
#   tools/deploy.sh <addon> --teaa          # 打包後佈署 .teaa（發佈前驗收用）
#   tools/deploy.sh <addon> --undeploy      # 移除（兩種形式都清）
#   tools/deploy.sh <addon> --home /tmp/x   # 佈署到 scratch home（無頭測試用）
#
# 為什麼佈署到 ~/.t-engine 而不是 Steam 目錄：
#   game/loader/init.lua:22   fs.mount(homepath, "/")   把使用者 home 掛在 PhysFS 根
#   engine/Module.lua:434     parse("/addons/")         走的是所有掛載點的聯集
#   engine/Module.lua:409-411 目錄只要叫 tome-* 且有 init.lua 就會被掃到
# 所以 ~/.t-engine/4.0/addons/tome-foo/ 與 Steam 的 game/addons/ 等價，且不污染遊戲安裝。
#
# 未列在 addons.cfg 的 addon 預設會載入（engine/Module.lua:583-598 的 else 分支只檢查
# natural_compatible），所以不需要手動 enable。

source "$(dirname "$0")/lib.sh"

[ "$#" -ge 1 ] || die "用法: tools/deploy.sh <addon> [--teaa] [--undeploy] [--home <dir>]"
ADDON_DIR="$(resolve_addon_dir "$1")"; shift

mode="dir"; action="deploy"; home_override=""
while [ "$#" -gt 0 ]; do
    case "$1" in
        --teaa) mode="teaa" ;;
        --dir) mode="dir" ;;
        --undeploy) action="undeploy" ;;
        --home) home_override="$2"; shift ;;
        *) die "未知參數: $1" ;;
    esac
    shift
done

if [ -n "$home_override" ]; then
    TOME_ADDONS_DIR="$home_override/4.0/addons"
fi

name="$(basename "$ADDON_DIR")"          # tome-<short_name>
dst_dir="$TOME_ADDONS_DIR/$name"
dst_teaa="$TOME_ADDONS_DIR/$name.teaa"

if [ "$action" = "undeploy" ]; then
    removed=0
    [ -e "$dst_dir" ]  && { rm -rf "$dst_dir";  info "移除 $dst_dir";  removed=1; }
    [ -e "$dst_teaa" ] && { rm -f  "$dst_teaa"; info "移除 $dst_teaa"; removed=1; }
    [ "$removed" -eq 1 ] && ok "已 undeploy $name" || warn "$name 本來就沒佈署"
    exit 0
fi

"$MODKIT_ROOT/tools/lint.sh" "$ADDON_DIR" >/dev/null || die "lint 未通過，拒絕佈署"

mkdir -p "$TOME_ADDONS_DIR"
# 先清掉另一種形式，避免同一個 addon 被載入兩次
rm -rf "$dst_dir" "$dst_teaa"

if [ "$mode" = "dir" ]; then
    # 用 cp 而非 symlink：PhysFS 預設不跟隨符號連結，symlink 的目錄會被 enumerate 跳過
    cp -r "$ADDON_DIR" "$dst_dir"
    ok "已佈署（目錄）$dst_dir"
else
    teaa="$("$MODKIT_ROOT/tools/build.sh" "$ADDON_DIR" | tail -1)"
    cp "$teaa" "$dst_teaa"
    ok "已佈署（.teaa）$dst_teaa"
fi

info "short_name = $(addon_field "$ADDON_DIR" short_name) / version = $(addon_field "$ADDON_DIR" version)"
info "未列在 addons.cfg 的 addon 預設啟用；若遊戲沒載入，檢查 version 是否與模組 1.7.6 相容"
