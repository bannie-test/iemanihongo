"""Builds assets/data/strokes.json from KanjiVG (CC BY-SA 3.0).

Usage: python3 tool/build_strokes.py path/to/kanjivg
Includes hiragana, katakana and every kanji in assets/data/kanji.json.
Output: {char: {"p": [svg path d per stroke], "n": [[x, y] label positions]}}
in KanjiVG's 109x109 coordinate space.
"""
import json, os, re, sys

root = sys.argv[1]
here = os.path.dirname(__file__)
kanji = json.load(open(os.path.join(here, '..', 'assets', 'data', 'kanji.json'), encoding='utf-8'))

chars = [chr(c) for c in range(0x3041, 0x3094)]           # hiragana あ … ゔ
chars += [chr(c) for c in range(0x30A1, 0x30F5)]          # katakana ア … ヴ
chars += sorted(kanji.keys())

path_re = re.compile(r'<path[^>]*\bid="kvg:[0-9a-f]+-s(\d+)"[^>]*\bd="([^"]+)"')
num_re = re.compile(r'<text transform="matrix\(1 0 0 1 ([\d.]+) ([\d.]+)\)">(\d+)</text>')

out, missing = {}, []
for ch in chars:
    f = os.path.join(root, 'kanji', f'{ord(ch):05x}.svg')
    if not os.path.exists(f):
        missing.append(ch)
        continue
    svg = open(f, encoding='utf-8').read()
    strokes = sorted(((int(n), d) for n, d in path_re.findall(svg)), key=lambda t: t[0])
    if not strokes:
        missing.append(ch)
        continue
    nums = sorted(((int(n), float(x), float(y)) for x, y, n in num_re.findall(svg)))
    out[ch] = {'p': [re.sub(r'\s+', ' ', d.strip()) for _, d in strokes],
               'n': [[round(x, 1), round(y, 1)] for _, x, y in nums]}

dest = os.path.join(here, '..', 'assets', 'data', 'strokes.json')
json.dump(out, open(dest, 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
print(len(out), 'characters;', 'missing:', ''.join(missing) or 'none', ';', os.path.getsize(dest), 'bytes')
