#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ADDON="${1:-tome-fall-from-heaven}"
SRC="${FFH_ASSETS_DIR:-/tmp/ffh2_unpack.ecgdxe/Fall from Heaven 2/Assets}"
DST="$ROOT/self_mods/$ADDON/data/gfx/ffh"
FINDINGS="$ROOT/wf/workflows/investigation/findings/ffh-import"

if [ ! -d "$SRC" ]; then
    echo "[FAIL] FFH assets dir not found: $SRC" >&2
    echo "       Set FFH_ASSETS_DIR=/path/to/Fall\\ from\\ Heaven\\ 2/Assets" >&2
    exit 1
fi

MAGICK="$(command -v magick || command -v convert || true)"
if [ -z "$MAGICK" ]; then
    echo "[FAIL] ImageMagick not found; cannot convert DDS/TGA to PNG" >&2
    exit 1
fi

mkdir -p "$DST/icons/units" "$DST/icons/proxy" "$DST/sprites/nif-proxy" "$FINDINGS"

convert_one() {
    local rel="$1"
    local out="$2"
    local in="$SRC/$rel"
    if [ ! -f "$in" ]; then
        echo "[WARN] missing: $rel" >&2
        return 0
    fi
    "$MAGICK" "$in" -auto-orient -resize 64x64 "$DST/$out"
    echo "[OK] $rel -> data/gfx/ffh/$out"
}

texture_proxy() {
    local rel="$1"
    local out="$2"
    local in="$SRC/$rel"
    if [ ! -f "$in" ]; then
        echo "[WARN] missing texture proxy source: $rel" >&2
        return 0
    fi
    "$MAGICK" "$in" -auto-orient -resize '96x96^' -gravity center -extent 96x96 -resize 64x64 "$DST/$out"
    echo "[OK] $rel -> data/gfx/ffh/$out"
}

convert_one "Art/Interface/Buttons/Units/Archer Elohim.dds"           "icons/units/archer-elohim.png"
convert_one "Art/Interface/Buttons/Units/Beast of Agares.dds"        "icons/units/beast-of-agares.png"
convert_one "Art/Interface/Buttons/Units/Scorpion.dds"               "icons/units/scorpion.png"
convert_one "Art/Interface/Buttons/Units/Son of the Inferno.dds"     "icons/units/son-of-the-inferno.png"
convert_one "Art/Interface/Buttons/Units/Vampire.dds"                "icons/units/vampire.png"
convert_one "Art/Interface/Buttons/Units/Vampire Lord.dds"           "icons/units/vampire-lord.png"
convert_one "Art/Interface/Buttons/Units/Warrior Elohim.dds"         "icons/units/warrior-elohim.png"
convert_one "Art/Interface/Buttons/Units/Wrath.dds"                  "icons/units/wrath.png"
convert_one "Art/Interface/Main Menu/Fallen Angel/carre.dds"         "icons/proxy/fallen-angel.png"

"$MAGICK" -size 64x64 radial-gradient:"#3b0d0d-#090202" -fill "#f6b24f" -draw "circle 32,32 32,10" "$DST/icons/proxy/city-sheaim.png"
"$MAGICK" -size 64x64 radial-gradient:"#26340d-#070902" -fill "#f0d268" -draw "rectangle 16,20 48,44" "$DST/icons/proxy/city-clan.png"
"$MAGICK" -size 64x64 radial-gradient:"#0d2634-#020709" -fill "#d9e8ff" -draw "polygon 14,48 32,12 50,48" "$DST/icons/proxy/landing-camp.png"
"$MAGICK" -size 64x64 radial-gradient:"#241338-#040207" -fill "#b884ff" -draw "circle 32,32 32,18" "$DST/icons/proxy/warband.png"

texture_proxy "Art/Units/Heroes/Avatar of Wrath/AbaddonBase.dds"                         "sprites/nif-proxy/abaddon.png"
texture_proxy "Art/Units/Religions/Ashen Veil/Beast of Agares/beast Kopie.dds"           "sprites/nif-proxy/beast-of-agares.png"
texture_proxy "Art/Units/Son of the Inferno/grenadier_128.dds"                           "sprites/nif-proxy/son-of-the-inferno.png"
texture_proxy "Art/Units/Scorpion/ScorpionBase.dds"                                      "sprites/nif-proxy/scorpion.png"
texture_proxy "Art/Units/Civs/Elohim/Archer/archer_128.dds"                              "sprites/nif-proxy/archer.png"
texture_proxy "Art/Units/Civs/Calabim/Mage/spy_128.dds"                                  "sprites/nif-proxy/mage-spy.png"
texture_proxy "Art/Units/Civs/Calabim/Vampire Lord/Vampire Lord.dds"                     "sprites/nif-proxy/vampire-lord.png"
texture_proxy "Art/Units/Civs/Balseraphs/Chariot/Celtic_Chariot_128.dds"                 "sprites/nif-proxy/chariot.png"

python - "$SRC" "$DST" "$FINDINGS/nif-sprite-manifest.tsv" <<'PY'
import os
import sys
from pathlib import Path

src = Path(sys.argv[1])
dst = Path(sys.argv[2])
out = Path(sys.argv[3])
proxy_by_rel = {
    "Art/Units/Heroes/Avatar of Wrath/Abaddon.nif": "sprites/nif-proxy/abaddon.png",
    "Art/Units/Religions/Ashen Veil/Beast of Agares/panther.nif": "sprites/nif-proxy/beast-of-agares.png",
    "Art/Units/Son of the Inferno/grenadier.nif": "sprites/nif-proxy/son-of-the-inferno.png",
    "Art/Units/Scorpion/scorp.nif": "sprites/nif-proxy/scorpion.png",
    "Art/Units/Civs/Elohim/Archer/archer.nif": "sprites/nif-proxy/archer.png",
    "Art/Units/Civs/Calabim/Mage/spy.nif": "sprites/nif-proxy/mage-spy.png",
    "Art/Units/Civs/Calabim/Vampire Lord/Unique_Sumerian_Vulture.nif": "sprites/nif-proxy/vampire-lord.png",
    "Art/Units/Civs/Balseraphs/Chariot/Chariot_Celtic.nif": "sprites/nif-proxy/chariot.png",
}
rows = []
for path in sorted(src.rglob("*")):
    if path.suffix.lower() != ".nif":
        continue
    rel = path.relative_to(src).as_posix()
    folder = path.parent
    textures = sorted(p.name for p in folder.iterdir() if p.suffix.lower() in {".dds", ".tga"})
    proxy = proxy_by_rel.get(rel, "")
    status = "texture_proxy_generated" if proxy and (dst / proxy).exists() else "needs_nif_renderer"
    rows.append((rel, str(path.stat().st_size), ",".join(textures[:8]), status, proxy))

with out.open("w", encoding="utf-8") as f:
    f.write("path\tsize_bytes\tnearby_textures\tstatus\tproxy_png\n")
    for row in rows:
        f.write("\t".join(row) + "\n")
print(f"[OK] wrote {out} ({len(rows)} NIF models)")
PY

echo "[OK] imported FFH assets into $DST"
