"""翻譯驗證工具 — validate() 與規格解析。

用法：validate(src, dst) → err_msg（None 表示通過）
"""
import re

FMT = re.compile(r'%[-\d.]*[a-zA-Z%]')
COLORTOK = re.compile(r'#\{?[A-Za-z_0-9/]+\}?#')
DIGITS = re.compile(r'\d+')
CJK = re.compile(r'[一-鿿]')

NAME_TAGS = {'talent name', 'entity name', 'talent type', 'entity subtype',
             'entity type', 'entity keyword', 'entity short_name', 'effect subtype',
             'damage type', 'achievement name', 'birth descriptor name',
             'talent category', 'init.lua long_name'}


def specs(s):
    return FMT.findall(s)


def validate(src, dst):
    if not isinstance(dst, str) or not dst.strip():
        return '譯文為空'
    if specs(src) != specs(dst):
        return f'格式符不一致：原文 {specs(src)} 譯文 {specs(dst)}'
    if COLORTOK.findall(src) != COLORTOK.findall(dst):
        return '色碼標記不一致'
    if sorted(DIGITS.findall(src)) != sorted(DIGITS.findall(dst)):
        return f'數字改變：原文 {sorted(DIGITS.findall(src))} 譯文 {sorted(DIGITS.findall(dst))}'
    letters = re.sub(r'[^A-Za-z]', '', FMT.sub('', COLORTOK.sub('', src)))
    if len(letters) > 3 and not CJK.search(dst):
        return '譯文無中文'
    return None
