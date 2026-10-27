"""Builds assets/data/grammar.json from the lesson tables in this folder."""
import json, os, sys

sys.path.insert(0, os.path.dirname(__file__))
from grammar_n5_n4 import N5, N4
from grammar_n3_n1 import N3, N2, N1

out, ids = [], set()
for level, items in ((5, N5), (4, N4), (3, N3), (2, N2), (1, N1)):
    for gid, title, meaning, formation, expl, examples, quiz in items:
        assert gid not in ids, gid
        ids.add(gid)
        q, opts, ans, qen = quiz
        assert '＿＿' in q and 0 <= ans < len(opts), gid
        out.append({'id': gid, 'l': level, 't': title, 'm': meaning, 'f': formation, 'e': expl,
                    'x': [{'jp': jp, 'en': en} for jp, en in examples],
                    'q': {'s': q, 'o': opts, 'a': ans, 'en': qen}})

path = os.path.join(os.path.dirname(__file__), '..', 'assets', 'data', 'grammar.json')
json.dump(out, open(path, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
print(len(out), 'lessons', {f'N{l}': sum(1 for g in out if g['l'] == l) for l in (5, 4, 3, 2, 1)})
