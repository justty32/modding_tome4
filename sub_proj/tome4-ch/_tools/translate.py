#!/usr/bin/env python3
"""agy 批次翻譯驅動器。CLI 入口。

用法：translate.py <workdir>
"""
import json, os, re, subprocess, sys, time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lib.trans_validate import validate, NAME_TAGS, specs, COLORTOK, CJK
from lib.prompt_template import PROMPT

TOOLS = os.path.dirname(os.path.abspath(__file__))
GLOSSARY = open(os.path.join(TOOLS, 'glossary_core.txt'), encoding='utf-8').read().strip()


def agy_call(inp, out, extra, log):
    if os.path.exists(out):
        os.remove(out)
    prompt = PROMPT.format(inp=inp, out=out, glossary=GLOSSARY, extra=extra)
    t0 = time.time()
    try:
        r = subprocess.run(
            ['agy', '--dangerously-skip-permissions', '--print-timeout', '10m',
             '--add-dir', os.path.dirname(out), '-p', prompt],
            capture_output=True, text=True, timeout=700)
    except subprocess.TimeoutExpired:
        log(f'  agy 逾時 ({inp})')
        return None
    dt = time.time() - t0
    if not os.path.exists(out):
        log(f'  agy 未產出檔案 ({dt:.0f}s) stdout尾: {r.stdout[-200:]!r}')
        return None
    try:
        return json.load(open(out, encoding='utf-8'))
    except Exception as e:
        log(f'  輸出 JSON 壞掉: {e}')
        return None


def run_phase(entries, per_batch, phase, trans, bdir, log, save_fn):
    fails = []
    batches = [entries[i:i + per_batch] for i in range(0, len(entries), per_batch)]
    for bi, batch in enumerate(batches):
        inp = os.path.abspath(f'{bdir}/{phase}_{bi:03d}_in.json')
        out = os.path.abspath(f'{bdir}/{phase}_{bi:03d}_out.json')
        json.dump({str(i + 1): e['src'] for i, e in enumerate(batch)},
                  open(inp, 'w', encoding='utf-8'), ensure_ascii=False, indent=0)
        extra = ''
        if phase.startswith('prose'):
            ng = name_glossary(batch, trans)
            if ng:
                extra = '6. 本 mod 專有名詞（同批已定譯，遇到必須沿用）：\n' + '\n'.join(ng) + '\n'
        data = agy_call(inp, out, extra, log)
        ok = 0
        for i, e in enumerate(batch):
            dst = (data or {}).get(str(i + 1))
            err = validate(e['src'], dst) if dst is not None else '無回應'
            if err:
                fails.append((e, err))
            else:
                trans[key(e)] = dst
                ok += 1
        save_fn()
        log(f'{phase} 批 {bi + 1}/{len(batches)}: 通過 {ok}/{len(batch)}')
    return fails


def name_glossary(batch_entries, trans):
    """已譯名稱做動態詞彙表，讓長文引用名稱時一致。"""
    text = ' '.join(e['src'] for e in batch_entries)
    pairs = []
    for k, v in trans.items():
        s = k.split('\x01')[0]
        if 3 < len(s) <= 48 and '\n' not in s and s in text:
            pairs.append(f'{s}={v}')
    return pairs[:50]


def key(e):
    return e['src'] + '\x01' + e['tag']


def retry_loop(fails, trans, bdir, log, save_fn):
    for rnd in (1, 2):
        if not fails:
            break
        log(f'重試第 {rnd} 輪：{len(fails)} 條')
        retry_entries = [e for e, _ in fails]
        errmap = {e['src']: err for e, err in fails}
        old_prompt_extra = ('6. 上一輪這些條目因下列原因報廢，請務必修正：\n' +
                            '\n'.join(f'編號{i + 1}: {errmap[e["src"]]}'
                                      for i, e in enumerate(retry_entries[:60])))
        fails2 = []
        batches = [retry_entries[i:i + 10] for i in range(0, len(retry_entries), 10)]
        for bi, batch in enumerate(batches):
            inp = os.path.abspath(f'{bdir}/retry{rnd}_{bi:03d}_in.json')
            out = os.path.abspath(f'{bdir}/retry{rnd}_{bi:03d}_out.json')
            json.dump({str(i + 1): e['src'] for i, e in enumerate(batch)},
                      open(inp, 'w', encoding='utf-8'), ensure_ascii=False, indent=0)
            data = agy_call(inp, out, old_prompt_extra, log)
            for i, e in enumerate(batch):
                dst = (data or {}).get(str(i + 1))
                err = validate(e['src'], dst) if dst is not None else '無回應'
                if err:
                    fails2.append((e, err))
                else:
                    trans[key(e)] = dst
            save_fn()
        fails = fails2
    return fails


def main():
    wd = sys.argv[1].rstrip('/')
    todo = json.load(open(f'{wd}/todo.json', encoding='utf-8'))
    bdir = f'{wd}/batches'
    os.makedirs(bdir, exist_ok=True)
    tpath = f'{wd}/translations.json'
    trans = json.load(open(tpath, encoding='utf-8')) if os.path.exists(tpath) else {}
    logf = open(f'{wd}/log.txt', 'a', encoding='utf-8')

    def log(msg):
        line = f'[{time.strftime("%H:%M:%S")}] {msg}'
        print(line, flush=True)
        logf.write(line + '\n'); logf.flush()

    def save():
        json.dump(trans, open(tpath, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)

    pend = [e for e in todo if key(e) not in trans]
    names = [e for e in pend if e['tag'] in NAME_TAGS or
             (len(e['src']) <= 48 and '\n' not in e['src'])]
    prose = [e for e in pend if e not in names]
    log(f'待翻 {len(pend)}（名稱類 {len(names)}、長文 {len(prose)}），已有 {len(trans)}')

    fails = run_phase(names, 40, 'names', trans, bdir, log, save)
    fails += run_phase(prose, 15, 'prose', trans, bdir, log, save)
    fails = retry_loop(fails, trans, bdir, log, save)

    json.dump([{'src': e['src'], 'tag': e['tag'], 'err': err} for e, err in fails],
              open(f'{wd}/failed.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    log(f'完成：成功 {len(trans)}，最終失敗 {len(fails)} → failed.json')


if __name__ == '__main__':
    main()
