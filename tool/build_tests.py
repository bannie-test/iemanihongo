"""Builds assets/data/jlpt_tests.json from the N3/N2/N1 question tables."""
import json, os, sys
from collections import Counter

sys.path.insert(0, os.path.dirname(__file__))
import jlpt_n1, jlpt_n2, jlpt_n3, jlpt_n4, jlpt_n5

MINUTES = {5: 25, 4: 28, 3: 30, 2: 28, 1: 26}  # time limit per 30-question test
SECTIONS = ['kanji', 'hyoki', 'bunmyaku', 'iikae', 'bunpou', 'narabe']

tests = []
# Strategy tips per section (Vietnamese), shown in practice and review.
SECTION_TIPS = {
    'kanji': 'Đọc to trong đầu và soát 4 bẫy kinh điển: trường âm (こう/こ), âm đục (か/が), âm ngắt (っ), âm ghép nhỏ (ゃゅょ). Nếu chưa chắc, loại trước các cách đọc theo âm Kun cho từ ghép Hán.',
    'hyoki': 'Đề hay đưa chữ cùng âm hoặc chỉ khác một bộ. Xác định nghĩa của từ trong câu, rồi kiểm tra bộ thủ (氵 nước, 扌 tay, 言 lời nói, 糸 sợi…) có khớp nghĩa không.',
    'bunmyaku': 'Đọc cả câu trước khi nhìn đáp án. Chú ý từ đi kèm (collocation) và trợ từ ngay trước chỗ trống: 道に迷う, 道を間違える.',
    'iikae': 'Thử thay từng đáp án vào câu: đáp án đúng giữ nguyên nghĩa cả câu. Cẩn thận bẫy trái nghĩa và bẫy đồng âm (やさしい = 易しい hay 優しい?).',
    'bunpou': 'Xác định trước khi chọn: thể của từ đứng trước (Vる / Vた / Vない / N の), và sắc thái vế sau (tích cực/tiêu cực, có ý chí hay không).',
    'narabe': 'Ghép trước những cặp chắc chắn (N＋trợ từ, mệnh đề bổ nghĩa ＋ N), rồi điền 4 ô. Đọc lại cả câu và chỉ tô vị trí ★ – thường là ô thứ 3.',
}

for level, mod in ((5, jlpt_n5), (4, jlpt_n4), (3, jlpt_n3), (2, jlpt_n2), (1, jlpt_n1)):
    sets = [(n, getattr(mod, f'TEST{n}')) for n in (1, 2, 3) if hasattr(mod, f'TEST{n}')]
    for no, items in sets:
        qs = []
        for i, item in enumerate(items, 1):
            sec, tag, sentence, opts, vi, ex = item[:6]
            tip = item[6] if len(item) > 6 else None
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
            q = {'id': qid, 'sec': sec, 'tag': tag, 's': sentence, 'o': opts, 'a': 0, 'vi': vi, 'ex': ex}
            if tip:
                q['tip'] = tip
            qs.append(q)
        counts = Counter(q['sec'] for q in qs)
        assert len(qs) == 30, (level, no, len(qs))
        tests.append({'id': f'n{level}-t{no}', 'level': level, 'no': no,
                      'minutes': MINUTES[level], 'questions': qs})
        print(f'N{level} test {no}: {len(qs)} questions', dict(counts))

# Neither bundled font has the fullwidth tilde (U+FF5E); use the wave dash.
tests = json.loads(json.dumps(tests, ensure_ascii=False).replace('～', '〜'))

out = os.path.join(os.path.dirname(__file__), '..', 'assets', 'data', 'jlpt_tests.json')
tests = {'sectionTips': SECTION_TIPS, 'tests': tests}
json.dump(tests, open(out, 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
print('wrote', out, os.path.getsize(out), 'bytes')
