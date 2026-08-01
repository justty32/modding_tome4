#!/usr/bin/env bash
# 把 zh_mods 下所有 tome-*-zh/ 打包成 build/tome-*-zh.teaa（zip 格式、內容在封存根層）
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/build"
for dir in "$ROOT"/tome-*-zh/; do
    [ -d "$dir" ] || continue
    name=$(basename "$dir")
    [ -f "$dir/init.lua" ] || { echo "SKIP $name（無 init.lua）"; continue; }
    out="$ROOT/build/$name.teaa"
    rm -f "$out"
    (cd "$dir" && zip -qr "$out" init.lua data/)
    echo "BUILT $out ($(du -h "$out" | cut -f1))"
done
