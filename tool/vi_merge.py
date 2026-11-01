"""Applies the Vietnamese text in tool/vi/ to assets/data/kanji.json and vocab.json.

  kanji_vi_*.txt   char|HÁN VIỆT|nghĩa, nghĩa
  vocab_vi_*.txt   word id|nghĩa tiếng Việt

Run after build_content.py (which calls it), or on its own. Safe to repeat.
"""
import glob, json, os

here = os.path.dirname(os.path.abspath(__file__))
data = os.path.join(here, '..', 'assets', 'data')


def read(pattern, cols):
    out = {}
    for f in sorted(glob.glob(os.path.join(here, 'vi', pattern))):
        for n, line in enumerate(open(f, encoding='utf-8'), 1):
            line = line.rstrip('\n')
            if not line or line.startswith('#'):
                continue
            parts = line.split('|')
            assert len(parts) == cols, (f, n, line)
            assert parts[0] not in out, (f, n, parts[0])
            out[parts[0]] = parts[1:]
    return out


def merge():
    kanji_path = os.path.join(data, 'kanji.json')
    kanji = json.load(open(kanji_path, encoding='utf-8'))
    kv = read('kanji_vi_*.txt', 3)
    for c, k in kanji.items():
        if c in kv:
            hv, m = kv[c]
            k['hv'] = hv
            k['m'] = [x.strip() for x in m.split(',') if x.strip()]
    json.dump(kanji, open(kanji_path, 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))

    vocab_path = os.path.join(data, 'vocab.json')
    words = json.load(open(vocab_path, encoding='utf-8'))
    vv = read('vocab_vi_*.txt', 2)
    done = 0
    for w in words:
        if w['id'] in vv:
            w['m'] = vv[w['id']][0]
            done += 1
    json.dump(words, open(vocab_path, 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
    print(f'kanji: {sum(1 for c in kanji if c in kv)}/{len(kanji)} · words: {done}/{len(words)} in Vietnamese')


if __name__ == '__main__':
    merge()
