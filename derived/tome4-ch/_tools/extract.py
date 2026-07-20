#!/usr/bin/env python3
"""從 ToME addon 原始碼機械抽取可翻譯字串。 CLI 入口。

用法：extract.py --addon <dir> [--drop-official <locale>]
     extract.py --calibrate <locale.lua> <addon_dir>
     extract.py --parse-locale <locale.lua>
"""
import json, os, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lib.classify_tag import classify
from lib.extract_addon import walk_addon, parse_locale


def main():
    if sys.argv[1] == '--addon':
        entries = walk_addon(sys.argv[2], classify)
        if '--drop-official' in sys.argv:
            off = sys.argv[sys.argv.index('--drop-official') + 1]
            oset = {(s, t) for s, t, _ in parse_locale(off)}
            entries = [e for e in entries if (e['src'], e['tag']) not in oset]
        json.dump(entries, sys.stdout, ensure_ascii=False, indent=1)
        print(f"\n-- total {len(entries)}", file=sys.stderr)
    elif sys.argv[1] == '--calibrate':
        oracle = parse_locale(sys.argv[2])
        got = walk_addon(sys.argv[3], classify)
        oset, gset = {(s, t) for s, t, _ in oracle}, {(e['src'], e['tag']) for e in got}
        osrc, gsrc = {s for s, _, _ in oracle}, {e['src'] for e in got}
        missing, extra = osrc - gsrc, gsrc - osrc
        tagdiff = [(s, t) for s, t, _ in oracle if s in gsrc and (s, t) not in gset]
        print(f"oracle={len(osrc)} extracted={len(gsrc)} "
              f"missing={len(missing)} extra={len(extra)} tag_mismatch={len(tagdiff)}")
        for s in sorted(missing)[:15]: print(f"  MISS: {s[:90]!r}")
        gmap = {e['src']: e['tag'] for e in got}
        for s, t in tagdiff[:15]: print(f"  TAG : oracle={t!r} got={gmap.get(s)!r} src={s[:70]!r}")
        for s in sorted(extra)[:25]: print(f"  XTRA: {s[:90]!r}")
    elif sys.argv[1] == '--parse-locale':
        for s, t, d in parse_locale(sys.argv[2]):
            print(json.dumps({'src': s, 'tag': t, 'dst': d}, ensure_ascii=False))


if __name__ == '__main__':
    main()
