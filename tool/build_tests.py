"""Builds assets/data/jlpt_tests.json from the N3/N2/N1 question tables."""
import json, os, sys
from collections import Counter

sys.path.insert(0, os.path.dirname(__file__))
import jlpt_n1, jlpt_n2, jlpt_n3

MINUTES = {3: 30, 2: 28, 1: 26}  # time limit per 30-question test
SECTIONS = ['kanji', 'hyoki', 'bunmyaku', 'iikae', 'bunpou', 'narabe']

tests = []
for level, mod in ((3, jlpt_n3), (2, jlpt_n2), (1, jlpt_n1)):
    for no, items in ((1, mod.TEST1), (2, mod.TEST2)):
        qs = []
        for i, (sec, tag, sentence, opts, vi, ex) in enumerate(items, 1):
            qid = f'n{level}-t{no}-q{i:02d}'
            assert sec in SECTIONS, qid
            assert len(opts) == 4 and len(set(opts)) == 4, qid
            if sec in ('kanji', 'hyoki', 'iikae'):
                assert sentence.count('[') == 1 and sentence.count(']') == 1, qid
            elif sec == 'narabe':
                assert sentence.count('★') == 1 and sentence.count('＿＿') == 3, qid
            else:
                assert '（　）' in sentence, qid
            assert vi.strip() and ex.strip(), qid
            qs.append({'id': qid, 'sec': sec, 'tag': tag, 's': sentence, 'o': opts, 'a': 0, 'vi': vi, 'ex': ex})
        counts = Counter(q['sec'] for q in qs)
        assert len(qs) == 30, (level, no, len(qs))
        tests.append({'id': f'n{level}-t{no}', 'level': level, 'no': no,
                      'minutes': MINUTES[level], 'questions': qs})
        print(f'N{level} test {no}: {len(qs)} questions', dict(counts))

# Neither bundled font has the fullwidth tilde (U+FF5E); use the wave dash.
tests = json.loads(json.dumps(tests, ensure_ascii=False).replace('～', '〜'))

out = os.path.join(os.path.dirname(__file__), '..', 'assets', 'data', 'jlpt_tests.json')
json.dump(tests, open(out, 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
print('wrote', out, os.path.getsize(out), 'bytes')
