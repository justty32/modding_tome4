#!/usr/bin/env bash
# 把 addon 目錄打包成 .teaa（zip，內容位於封存根層）。
# 用法： tools/build.sh <addon> [--out <dir>]
# 產物： build/<tome-short_name>.teaa
#
# .teaa 就是 zip：engine/Module.lua:338 用副檔名判斷，:409 掃描 addons 目錄。

source "$(dirname "$0")/lib.sh"
handle_help_flag "$@"

[ "$#" -ge 1 ] || die "用法: tools/build.sh <addon> [--out <dir>]"
ADDON_DIR="$(resolve_addon_dir "$1")"; shift
out_dir="$BUILD_DIR"
while [ "$#" -gt 0 ]; do
    case "$1" in
        --out) out_dir="$2"; shift 2 ;;
        *) die "未知參數: $1" ;;
    esac
done

command -v zip >/dev/null || die "找不到 zip"

# 先 lint，壞的東西不該被打包
"$MODKIT_ROOT/tools/lint.sh" "$ADDON_DIR" >/dev/null || die "lint 未通過，拒絕打包"

name="$(basename "$ADDON_DIR")"
mkdir -p "$out_dir"
out="$out_dir/$name.teaa"
rm -f "$out"

# 只收引擎會讀的東西；排除開發用檔案
(
    cd "$ADDON_DIR"
    zip -qr "$out" . \
        -x '*.git*' -x '*/.*' -x 'NOTES.md' -x 'README.md' -x '*.orig' -x '*.rej'
)

[ -f "$out" ] || die "打包失敗"
ok "BUILT $out ($(du -h "$out" | cut -f1), $(unzip -l "$out" | tail -1 | awk '{print $2}') 個檔案)"
echo "$out"
