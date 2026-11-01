"""Builds assets/data/grammar.json from the lesson tables in this folder."""
import json, os, sys

sys.path.insert(0, os.path.dirname(__file__))
from grammar_n5_n4 import N5, N4
from grammar_n3_n1 import N3, N2, N1
import grammar_more_n5_n4 as more_lo
import grammar_more_n3_n1 as more_hi
from grammar_refs import REFS
import glob, re, runpy

# Vietnamese text (meaning, formation, explanation, examples, quiz, tip) per lesson.
VI = {}
for f in sorted(glob.glob(os.path.join(os.path.dirname(__file__), 'vi', 'grammar_vi_*.py'))):
    VI.update(runpy.run_path(f)['G'])
TITLES = {
    'n5-de-place': '〜で (nơi chốn / phương tiện)', 'n5-ni-time': '〜に (thời gian)',
    'n5-adj-i': 'Tính từ đuôi い', 'n5-adj-na': 'Tính từ đuôi な', 'n5-kara-reason': '〜から (lý do)',
    'n5-te-link': '〜て (và, rồi)', 'n4-potential': 'Thể khả năng', 'n4-volitional': 'Thể ý chí 〜よう / 〜おう',
    'n4-ba': '〜ば (điều kiện)', 'n4-to-cond': '〜と (kết quả tất yếu)', 'n4-sou-looks': '〜そうです (trông có vẻ)',
    'n4-sou-hearsay': '〜そうです (nghe nói)', 'n4-passive': 'Thể bị động 〜られる', 'n4-causative': 'Thể sai khiến 〜させる',
}

def vi_ref(ref):
    ref = re.sub(r'\bLessons? ', 'Bài ', ref)
    return ref.replace(' & ', ' và ').replace(' Grammar (', ' Ngữ pháp (')

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
        vm, vf, ve, vx, vq, vtip = VI[gid]
        assert len(vx) == len(examples), gid
        out.append({'id': gid, 'l': level, 't': TITLES.get(gid, title), 'm': vm, 'f': vf, 'e': ve,
                    'x': [{'jp': jp, 'vi': vi} for (jp, _), vi in zip(examples, vx)],
                    'q': {'s': q, 'o': opts, 'a': ans, 'vi': vq},
                    'ref': vi_ref(ref), 'tip': vtip})
missing = set(REFS) - ids
assert not missing, missing

path = os.path.join(os.path.dirname(__file__), '..', 'assets', 'data', 'grammar.json')
# Neither bundled font has the fullwidth tilde (U+FF5E); use the wave dash.
out = json.loads(json.dumps(out, ensure_ascii=False).replace('～', '〜'))
json.dump(out, open(path, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
print(len(out), 'lessons', {f'N{l}': sum(1 for g in out if g['l'] == l) for l in (5, 4, 3, 2, 1)})
