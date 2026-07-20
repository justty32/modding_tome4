#!/usr/bin/env python3
"""組裝最終伴生 addon：salvage 翻譯 + agy 譯文 → data/locales/zh_hant.lua + init.lua。

用法：assemble.py <addon_name> <companion_dir_name> [salvage_locale...]
例：  assemble.py arcanum tome-arcanum-zh
"""
import json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from extract import parse_locale

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))  # 專案根（_tools/ 的上一層），隨資料夾搬移自動跟著


def lua_str(v):
    if '\n' in v or '"' in v:
        for eq in ('', '=', '=='):
            if ']' + eq + ']' not in v and not v.startswith('\n') and not v.endswith(']'):
                return '[' + eq + '[' + v + ']' + eq + ']'
    out = v.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\t', '\\t')
    return '"' + out + '"'


def main():
    name, comp = sys.argv[1], sys.argv[2]
    salvages = sys.argv[3:]
    wd = f'{ROOT}/_work/{name.replace("+", "-plus")}'
    entries = json.load(open(f'{wd}/all.json', encoding='utf-8'))
    tpath = f'{wd}/translations.json'
    trans = json.load(open(tpath, encoding='utf-8')) if os.path.exists(tpath) else {}

    # salvage 優先（人審過的 Claude 翻譯蓋掉 agy 版本）
    salv = {}
    for sv in salvages:
        p = os.path.join(ROOT, sv)
        if os.path.exists(p):
            for s, t, d in parse_locale(p):
                if d:
                    salv[(s, t)] = d

    final = {}       # (src,tag) -> (dst, file)
    missing = []
    for e in entries:
        k = (e['src'], e['tag'])
        dst = salv.get(k) or trans.get(e['src'] + '\x01' + e['tag'])
        if dst:
            final[k] = (dst, e['file'])
        else:
            missing.append(e)
    # salvage 中有、但 all.json 沒抽到的條目也保留（Claude 涵蓋較廣處）
    extra_salv = [(k, v) for k, v in salv.items() if k not in final]

    comp_dir = f'{ROOT}/{comp}'
    os.makedirs(f'{comp_dir}/data/locales', exist_ok=True)
    lines = ['locale "zh_hant"', '']
    by_file = {}
    for (s, t), (d, f) in final.items():
        by_file.setdefault(f, []).append((s, t, d))
    for f in sorted(by_file):
        lines.append(f'section "data-{name}/{f}"')
        lines.append('')
        for s, t, d in by_file[f]:
            lines.append(f't({lua_str(s)}, {lua_str(d)}, {lua_str(t)})')
        lines.append('')
    if extra_salv:
        lines.append('section "salvage-extra"')
        lines.append('')
        for (s, t), d in extra_salv:
            lines.append(f't({lua_str(s)}, {lua_str(d)}, {lua_str(t)})')
        lines.append('')
    with open(f'{comp_dir}/data/locales/zh_hant.lua', 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))

    if not os.path.exists(f'{comp_dir}/init.lua'):
        short = comp.replace('tome-', '')
        with open(f'{comp_dir}/init.lua', 'w', encoding='utf-8') as f:
            f.write(f'''long_name = "{name} 正體中文化"
short_name = "{short}"
for_module = "tome"
version = {{1,7,6}}
addon_version = {{1,0,0}}
weight = 1000000
author = {{'tome4-ch'}}
homepage = '-'
description = [[{name} 的正體中文翻譯（非侵入式 locale patch）。]]
tags = {{'translate'}}
data = true
''')
    print(f'{name}: 條目 {len(final)+len(extra_salv)}（salvage 追加 {len(extra_salv)}），未翻 {len(missing)}')
    for e in missing[:10]:
        print(f'  MISS [{e["tag"]}] {e["src"][:80]!r}')


if __name__ == '__main__':
    main()
