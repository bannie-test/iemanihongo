import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme.dart';
import '../widgets/botanical.dart';
import '../widgets/common.dart';

const jlptSamplesUrl = 'https://www.jlpt.jp/e/samples/forlearners.html';

Future<void> openLink(BuildContext context, String url) async {
  final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    await Clipboard.setData(ClipboardData(text: url));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã sao chép đường dẫn – hãy mở trong trình duyệt')));
    }
  }
}

/// Where the app's content comes from, and recommended books.
class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});

  static const _data = [
    (
      'Từ vựng (8.144 từ)',
      'Danh sách JLPT N5–N1 của Jonathan Waller (tanos.co.uk, CC BY), qua open-anki-jlpt-decks (MIT); '
          'cách viết được đối chiếu với yomitan-jlpt-vocab (khớp từng từ với JMdict, EDRDG). Nghĩa tiếng Việt được biên soạn cho ứng dụng này.',
      'http://www.tanos.co.uk/jlpt/',
    ),
    (
      'Kanji',
      'KANJIDIC2 © Electronic Dictionary Research and Development Group (CC BY-SA 4.0). Âm Hán Việt và nghĩa tiếng Việt được biên soạn cho ứng dụng này.',
      'https://www.edrdg.org/wiki/index.php/KANJIDIC_Project',
    ),
    ('Thứ tự nét', 'KanjiVG © Ulrich Apel (CC BY-SA 3.0).', 'https://kanjivg.tagaini.net/'),
    (
      'Bài ngữ pháp',
      'Biên soạn cho ứng dụng này. Mỗi bài ghi rõ giáo trình dạy điểm ngữ pháp đó: Genki I/II (The Japan Times), '
          'Minna no Nihongo Shokyū I/II (3A Network), Shin Kanzen Master N3–N1 Ngữ pháp (3A Network), '
          'Nihongo Sō Matome N3–N1 Ngữ pháp (Ask).',
      null,
    ),
    (
      'Đề luyện thi JLPT & nghe hiểu',
      'Câu hỏi tự biên soạn theo đúng dạng đề JLPT chính thức (文字・語彙・文法, 聴解), có giải thích tiếng Việt. '
          'Đề mẫu chính thức và bộ 公式問題集 (Japan Foundation / JEES) là cách tốt nhất để tự đánh giá so với đề thi thật.',
      jlptSamplesUrl,
    ),
    (
      'Phông chữ & biểu tượng',
      'EB Garamond, Be Vietnam Pro, Zen Old Mincho, Zen Kaku Gothic New (giấy phép SIL Open Font); biểu tượng Lucide (ISC).',
      null,
    ),
  ];

  static const _books = [
    ('N5–N4', 'Genki I & II · Minna no Nihongo Shokyū I & II · Try! 日本語能力試験 N5/N4'),
    ('N3', 'Shin Kanzen Master N3 (Ngữ pháp, Từ vựng, Đọc hiểu, Nghe hiểu) · Nihongo Sō Matome N3'),
    ('N2', 'Trọn bộ Shin Kanzen Master N2 · Nihongo Sō Matome N2 · 日本語能力試験 公式問題集 N2'),
    ('N1', 'Trọn bộ Shin Kanzen Master N1 · Nihongo Sō Matome N1 · 日本語能力試験 公式問題集 N1'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nguồn tham khảo')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: Text('Nội dung lấy từ đâu', style: context.text.headlineSmall)),
              const Sprig(size: 54, leaves: 4),
            ],
          ),
          const SizedBox(height: 16),
          for (final (title, body, url) in _data) ...[
            SoftCard(
              onTap: url == null ? null : () => openLink(context, url),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.text.titleMedium),
                  const SizedBox(height: 4),
                  Text(body, style: context.text.bodyMedium),
                  if (url != null) ...[
                    const SizedBox(height: 6),
                    Text(url, style: context.text.bodySmall?.copyWith(decoration: TextDecoration.underline)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 14),
          SoftCard(
            tone: PanelTone.sage,
            radius: AppTheme.radiusWide,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Sách nên dùng'),
                const SizedBox(height: 8),
                for (final (level, books) in _books)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 56, child: Text(level, style: context.text.titleMedium)),
                        Expanded(child: Text(books, style: context.text.bodyMedium)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
