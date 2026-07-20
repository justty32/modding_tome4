"""walk_addon & parse_locale — extract.py 的 addon 遍歷邏輯。

import json, os, re
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
"""
import json, os, re
from luastr import extract_strings, line_of

CONSTRUCTORS = ['newTalent', 'newTalentType', 'newEntity', 'newEffect',
                'newBirthDescriptor', 'newAchievement', 'newDamageType',
                'newChat', 'newQuest', 'newInscription', 'newLore']

SKIP_FILES = re.compile(r'(^|/)(init\.lua|locales/)')
PATHY = re.compile(r'\.(png|lua|ogg|wav|ttf|fnt)\b|^/|^data/|^special/|^invis\b')
IDENT = re.compile(r'^[A-Za-z0-9_.:]+$')
FMT = re.compile(r'%[-\d.]*[a-zA-Z%]')
COLOR_ONLY = re.compile(r'^[#{}\w]*#$')

NAME_TAG = {'newTalent': 'talent name', 'newEntity': 'entity name',
            'newEffect': '_t', 'newBirthDescriptor': 'birth descriptor name',
            'newAchievement': 'achievement name', 'newDamageType': 'damage type',
            'newTalentType': 'talent type', 'newQuest': '_t', 'newLore': '_t'}

TAG_VOCAB = {'_t', 'tformat', 'log', 'logPlayer', 'logSeen', 'entity name',
             'entity subtype', 'entity type', 'entity keyword', 'entity short_name',
             'talent name', 'talent type', 'talent category', 'effect subtype',
             'damage type', 'achievement name', 'birth descriptor name', 'chat', 'say'}
ALLCAPS = re.compile(r'^[A-Z0-9_]+$')


def walk_addon(addon_dir, classify_fn):
    entries = []
    for root, _dirs, files in os.walk(addon_dir):
        for fn in sorted(files):
            if not fn.endswith('.lua'):
                continue
            path = os.path.join(root, fn)
            rel = os.path.relpath(path, addon_dir)
            if SKIP_FILES.search(rel):
                if fn == 'init.lua' and os.path.dirname(rel) == '':
                    with open(path, 'r', encoding='utf-8', errors='replace') as f:
                        itext = f.read()
                    for s in extract_strings(itext):
                        pfx = re.sub(r'\s+', ' ', s['prefix'].replace('\x00', ''))
                        mm = re.search(r'(long_name|description)\s*=\s*$', pfx)
                        if mm:
                            entries.append({'file': rel, 'line': line_of(itext, s['start']),
                                            'src': s['value'],
                                            'tag': 'init.lua ' + mm.group(1),
                                            'ctor': '', 'prefix': 'init-meta'})
                continue
            with open(path, 'r', encoding='utf-8', errors='replace') as f:
                text = f.read()
            strs = extract_strings(text)
            ctor_pos = []
            for c in CONSTRUCTORS:
                for m in re.finditer(re.escape(c) + r'\s*[({]', text):
                    ctor_pos.append((m.start(), c))
            ctor_pos.sort()
            for s in strs:
                cur = None
                for pos, c in ctor_pos:
                    if pos < s['start']:
                        cur = c
                    else:
                        break
                prefix = re.sub(r'\s+', ' ', s['prefix'].replace('\x00', '')).strip()
                prefix = prefix[-60:]
                tag = classify_fn(prefix + (' ' if prefix else ''), s['value'], cur)
                if tag:
                    entries.append({'file': rel, 'line': line_of(text, s['start']),
                                    'src': s['value'], 'tag': tag, 'ctor': cur or '',
                                    'prefix': prefix[-40:]})
            nocomment = re.sub(r'--\[\[.*?\]\]|--[^\n]*', '', text, flags=re.S)
            for m in re.finditer(r'subtype\s*=\s*\{([^{}]*)\}', nocomment):
                for key in re.findall(r'([A-Za-z_]\w*)\s*=', m.group(1)):
                    entries.append({'file': rel, 'line': 0, 'src': key,
                                    'tag': 'effect subtype', 'ctor': 'newEffect',
                                    'prefix': 'subtype-key'})
    seen, uniq = set(), []
    for e in entries:
        k = (e['src'], e['tag'])
        if k not in seen:
            seen.add(k)
            uniq.append(e)
    return uniq


def parse_locale(path):
    """從 locale 檔抽 (src, tag) 集合。"""
    with open(path, 'r', encoding='utf-8', errors='replace') as f:
        text = f.read()
    strs = extract_strings(text)
    out = []
    i = 0
    while i < len(strs):
        pfx = re.sub(r'\s+', '', strs[i]['prefix'].replace('\x00', ''))
        if pfx.endswith('t('):
            src = strs[i]['value']
            dst = strs[i + 1]['value'] if i + 1 < len(strs) else None
            tag = strs[i + 2]['value'] if i + 2 < len(strs) else None
            out.append((src, tag, dst))
            i += 3
        else:
            i += 1
    return out
