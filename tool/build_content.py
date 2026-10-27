"""Builds assets/data/vocab.json and assets/data/kanji.json.

Sources (download into a folder and pass it as the first argument):
  n1.csv .. n5.csv  https://github.com/jamsinclair/open-anki-jlpt-decks (MIT,
                    originally from tanos.co.uk JLPT lists, CC BY)
  kanji.json        https://github.com/davidluzgouveia/kanji-data (KANJIDIC2,
                    CC BY-SA 4.0, EDRDG). Only KANJIDIC fields are kept.
"""
import csv, hashlib, json, os, re, sys

src = sys.argv[1]
out = os.path.join(os.path.dirname(__file__), '..', 'assets', 'data')
kanji_db = json.load(open(os.path.join(src, 'kanji.json'), encoding='utf-8'))
is_kanji = lambda ch: '一' <= ch <= '鿿' or ch == '々'

def speakable(reading):
    """First reading variant without notes or ～ placeholders, used for TTS."""
    first = re.split(r'[;；、]', reading)[0]
    first = re.sub(r'[(（][^)）]*[)）]', '', first)
    first = re.sub(r'[～〜~\s]', '', first)
    return first or re.sub(r'[～〜~\s()（）]', '', reading)


words, seen = [], {}
for level in (5, 4, 3, 2, 1):
    with open(os.path.join(src, f'n{level}.csv'), encoding='utf-8') as f:
        for row in csv.DictReader(f):
            w = row['expression'].strip().replace('～', '〜')
            r = row['reading'].strip().replace('～', '〜')
            m = re.sub(r'\s+', ' ', row['meaning']).strip().replace('～', '〜')
            if not w or not m:
                continue
            if not r:  # a few kana-only rows have no reading column
                r = w
            key = (w, r)
            if key in seen:  # keep the easiest level a word appears in
                continue
            seen[key] = True
            ks = [c for c in w if is_kanji(c)]
            freqs = [kanji_db.get(c, {}).get('freq') or 2600 for c in ks]
            # Approximate frequency order: textbook (Genki) words first, then
            # by the rarest kanji in the word; kana-only words sit early.
            score = (0 if 'Genki' in row['tags'] else 1000) + (max(freqs) if freqs else 400)
            word = {'id': f"n{level}-" + hashlib.sha1(f'{w}|{r}'.encode()).hexdigest()[:10],
                    'w': w, 'r': r, 'm': m, 'l': level, 'o': score}
            spoken = speakable(r)
            if spoken != r:
                word['s'] = spoken
            words.append(word)

for level in (5, 4, 3, 2, 1):
    lw = sorted([x for x in words if x['l'] == level], key=lambda x: (x['o'], x['r']))
    for i, x in enumerate(lw):
        x['o'] = i
words.sort(key=lambda x: (-x['l'], x['o']))

used = sorted({c for x in words for c in x['w'] if is_kanji(c) and c in kanji_db})
kanji = {}
for c in used:
    k = kanji_db[c]
    meanings = [m for m in k.get('meanings') or [] if 'Radical (no' not in m]
    kanji[c] = {'s': k.get('strokes'), 'm': meanings,
                'on': k.get('readings_on') or [], 'kun': k.get('readings_kun') or [],
                'l': k.get('jlpt_new')}

json.dump(words, open(os.path.join(out, 'vocab.json'), 'w', encoding='utf-8'),
          ensure_ascii=False, separators=(',', ':'))
json.dump(kanji, open(os.path.join(out, 'kanji.json'), 'w', encoding='utf-8'),
          ensure_ascii=False, separators=(',', ':'))
print(len(words), 'words;', len(kanji), 'kanji')
for lv in (5, 4, 3, 2, 1):
    print(f'N{lv}', sum(1 for x in words if x['l'] == lv))
