"""Builds assets/data/grammar.json from the lesson tables in this folder."""
import json, os, sys

sys.path.insert(0, os.path.dirname(__file__))
from grammar_n5_n4 import N5, N4
from grammar_n3_n1 import N3, N2, N1
import grammar_more_n5_n4 as more_lo
import grammar_more_n3_n1 as more_hi
from grammar_refs import REFS

tables = {
    5: [(t, None, None) for t in N5] + [(t[:7], t[7], t[8]) for t in more_lo.N5],
    4: [(t, None, None) for t in N4] + [(t[:7], t[7], t[8]) for t in more_lo.N4],
    3: [(t, None, None) for t in N3] + [(t[:7], t[7], t[8]) for t in more_hi.N3],
    2: [(t, None, None) for t in N2] + [(t[:7], t[7], t[8]) for t in more_hi.N2],
    1: [(t, None, None) for t in N1] + [(t[:7], t[7], t[8]) for t in more_hi.N1],
}

out, ids = [], set()
for level, items in tables.items():
    for (gid, title, meaning, formation, expl, examples, quiz), ref, tip in items:
        assert gid not in ids, gid
        ids.add(gid)
        if ref is None:
            ref, tip = REFS[gid]
        q, opts, ans, qen = quiz
        assert '＿＿' in q and 0 <= ans < len(opts) and len(set(opts)) == len(opts), gid
        out.append({'id': gid, 'l': level, 't': title, 'm': meaning, 'f': formation, 'e': expl,
                    'x': [{'jp': jp, 'en': en} for jp, en in examples],
                    'q': {'s': q, 'o': opts, 'a': ans, 'en': qen},
                    'ref': ref, 'tip': tip})
missing = set(REFS) - ids
assert not missing, missing

path = os.path.join(os.path.dirname(__file__), '..', 'assets', 'data', 'grammar.json')
# Neither bundled font has the fullwidth tilde (U+FF5E); use the wave dash.
out = json.loads(json.dumps(out, ensure_ascii=False).replace('～', '〜'))
json.dump(out, open(path, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
print(len(out), 'lessons', {f'N{l}': sum(1 for g in out if g['l'] == l) for l in (5, 4, 3, 2, 1)})
