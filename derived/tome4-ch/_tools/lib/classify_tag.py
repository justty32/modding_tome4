"""Tag 分類器 — 用 context prefix 推測字串 tag。

共用 extract.py 的 classify() 函式。
"""
import re

PATHY = re.compile(r'\.(png|lua|ogg|wav|ttf|fnt)\b|^/|^data/|^special/|^invis\b')
IDENT = re.compile(r'^[A-Za-z0-9_.:]+$')
FMT = re.compile(r'%[-\d.]*[a-zA-Z%]')
ALL_CAPS = re.compile(r'^[A-Z0-9_]+$')
COLOR_ONLY = re.compile(r'^[#{}\w]*#$')
TAG_VOCAB = {'_t', 'tformat', 'log', 'logPlayer', 'logSeen', 'entity name',
             'entity subtype', 'entity type', 'entity keyword', 'entity short_name',
             'talent name', 'talent type', 'talent category', 'effect subtype',
             'damage type', 'achievement name', 'birth descriptor name', 'chat', 'say'}

NAME_TAG = {'newTalent': 'talent name', 'newEntity': 'entity name',
            'newEffect': '_t', 'newBirthDescriptor': 'birth descriptor name',
            'newAchievement': 'achievement name', 'newDamageType': 'damage type',
            'newTalentType': 'talent type', 'newQuest': '_t', 'newLore': '_t'}


def classify(prefix, value, cur_ctor):
    """回傳 tag 或 None（略過）。prefix 已壓縮空白、結尾補一空格。

    傳回值可以是 _t / tformat / entity name / talent name / log / say 等。
    """
    p = prefix
    W = r'(_t\s*\(?\s*)?$'

    if PATHY.search(value) or ('/' in value and ' ' not in value):
        return None
    if not re.search(r'[A-Za-z]', FMT.sub('', value)):
        return None
    if ALL_CAPS.match(value) or value in TAG_VOCAB or COLOR_ONLY.match(value):
        return None
    if re.search(r'(==|~=)\s*$', p):
        return None
    if re.search(r'%q|\btypedef\b|\bstruct\b|^\s*(local|function|require)\b'
                 r'|^[\w.]+\s*=\s*$|config\.settings', value):
        return None
    if re.search(r'(ShaderAura|isAddonActive|findMember|hasEffect|knowTalent|'
                 r'getTalentTypeFrom|require|attr)\s*\(\s*$', p):
        return None
    if re.search(r'(define_as|image|display|color|sound|particle|uid|derived|'
                 r'money_value|mode|category|type_requires|kr_name|shader|name_scheme)'
                 r'\s*=\s*' + W, p):
        return None

    m = re.search(r'\b(log|logPlayer|logSeen|logCombat)\s*\(([^()]*)$', p)
    if m:
        return m.group(1)
    if re.search(r'(doEmote|:say)\s*\(\s*$', p):
        return 'say'

    if re.search(r'\bname\s*=\s*' + W, p):
        if cur_ctor == 'newEffect':
            return None if ALL_CAPS.match(value) else '_t'
        return NAME_TAG.get(cur_ctor, '_t')
    if re.search(r'unided_name\s*=\s*' + W, p):
        return 'entity name' if cur_ctor == 'newEntity' else '_t'
    if re.search(r'\bdesc\s*=\s*' + W, p) and cur_ctor == 'newEffect':
        return '_t'
    if re.search(r'\blong_desc\s*=\s*' + W, p):
        return 'tformat'
    if re.search(r'\bsubtype\s*=\s*' + W, p):
        return 'entity subtype' if cur_ctor == 'newEntity' else 'effect subtype'
    if re.search(r'\btype\s*=\s*\{\s*$', p) and cur_ctor == 'newTalent':
        return 'talent type'
    if re.search(r'\btype\s*=\s*' + W, p) and cur_ctor == 'newEntity':
        return 'entity type'
    if re.search(r'keywords\s*=\s*\{[^}]*$', p):
        return 'entity keyword'
    if re.search(r'short_name\s*=\s*' + W, p):
        return 'entity short_name' if cur_ctor == 'newEntity' else None
    if IDENT.match(value):
        return None
    if re.search(r'return\s*\(?\s*$', p):
        return 'tformat'
    return 'tformat' if FMT.search(value) else '_t'
