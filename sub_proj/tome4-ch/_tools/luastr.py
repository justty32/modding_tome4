#!/usr/bin/env python3
"""Lua 原始碼字串抽取共用函式庫：註解感知 tokenizer。

extract_strings(text) -> list of dict:
  { 'value': 執行期字串值, 'start','end': byte offsets,
    'kind': 'dq'|'sq'|'long', 'prefix': 字串前最近 80 字元的程式碼（不含其他字串內容） }
"""

ESCAPES = {'n': '\n', 't': '\t', 'r': '\r', 'a': '\a', 'b': '\b',
           'f': '\f', 'v': '\v', '"': '"', "'": "'", '\\': '\\', '\n': '\n'}


def extract_strings(text):
    out = []
    code_chars = []          # 程式碼字元（字串內容以 \x00 佔位一格），供 prefix 用
    i, n = 0, len(text)
    while i < n:
        c = text[i]
        # 註解
        if c == '-' and i + 1 < n and text[i+1] == '-':
            j = i + 2
            # 塊註解 --[[ or --[=*[
            if j < n and text[j] == '[':
                k = j + 1
                eq = 0
                while k < n and text[k] == '=':
                    eq += 1; k += 1
                if k < n and text[k] == '[':
                    close = ']' + '=' * eq + ']'
                    end = text.find(close, k + 1)
                    i = (end + len(close)) if end != -1 else n
                    code_chars.append(' ')
                    continue
            end = text.find('\n', i)
            i = (end + 1) if end != -1 else n
            code_chars.append('\n')
            continue
        # 長字串
        if c == '[':
            k = i + 1
            eq = 0
            while k < n and text[k] == '=':
                eq += 1; k += 1
            if k < n and text[k] == '[':
                close = ']' + '=' * eq + ']'
                body_start = k + 1
                end = text.find(close, body_start)
                if end == -1:
                    break
                body = text[body_start:end]
                if body.startswith('\r\n'):
                    body = body[2:]
                elif body.startswith('\n'):
                    body = body[1:]
                out.append({'value': body, 'start': i, 'end': end + len(close),
                            'kind': 'long',
                            'prefix': ''.join(code_chars[-100:])})
                code_chars.append('\x00')
                i = end + len(close)
                continue
        # 引號字串
        if c in ('"', "'"):
            q = c
            j = i + 1
            buf = []
            while j < n:
                ch = text[j]
                if ch == '\\':
                    nx = text[j+1] if j + 1 < n else ''
                    if nx in ESCAPES:
                        buf.append(ESCAPES[nx]); j += 2; continue
                    if nx.isdigit():
                        k = j + 1
                        num = ''
                        while k < n and text[k].isdigit() and len(num) < 3:
                            num += text[k]; k += 1
                        buf.append(chr(int(num))); j = k; continue
                    buf.append(nx); j += 2; continue
                if ch == q:
                    break
                if ch == '\n':
                    break  # 未閉合，容錯
                buf.append(ch); j += 1
            out.append({'value': ''.join(buf), 'start': i, 'end': j + 1,
                        'kind': 'dq' if q == '"' else 'sq',
                        'prefix': ''.join(code_chars[-100:])})
            code_chars.append('\x00')
            i = j + 1
            continue
        code_chars.append(c)
        i += 1
    return out


def line_of(text, pos):
    return text.count('\n', 0, pos) + 1
