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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied – open it in a browser')));
    }
  }
}

/// Where the app's content comes from, and recommended books.
class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});

  static const _data = [
    (
      'Vocabulary (8,144 words)',
      'JLPT N5–N1 lists by Jonathan Waller (tanos.co.uk, CC BY), via open-anki-jlpt-decks (MIT); '
          'spellings cross-checked with yomitan-jlpt-vocab, which matches each word to JMdict (EDRDG).',
      'http://www.tanos.co.uk/jlpt/',
    ),
    (
      'Kanji',
      'KANJIDIC2 © Electronic Dictionary Research and Development Group (CC BY-SA 4.0).',
      'https://www.edrdg.org/wiki/index.php/KANJIDIC_Project',
    ),
    ('Stroke order', 'KanjiVG © Ulrich Apel (CC BY-SA 3.0).', 'https://kanjivg.tagaini.net/'),
    (
      'Grammar lessons',
      'Written for this app. Each lesson names where the point is taught: Genki I/II (The Japan Times), '
          'Minna no Nihongo Shokyū I/II (3A Network), Shin Kanzen Master N3–N1 Grammar (3A Network), '
          'Nihongo Sō Matome N3–N1 Grammar (Ask).',
      null,
    ),
    (
      'JLPT practice tests & listening',
      'Original questions written in the official JLPT format (文字・語彙・文法, 聴解) with Vietnamese explanations. '
          'Official sample questions and the 公式問題集 (Japan Foundation / JEES) are the best way to check yourself against the real exam.',
      jlptSamplesUrl,
    ),
    (
      'Fonts & icons',
      'EB Garamond, Be Vietnam Pro, Zen Old Mincho, Zen Kaku Gothic New (SIL Open Font License); Lucide icons (ISC).',
      null,
    ),
  ];

  static const _books = [
    ('N5–N4', 'Genki I & II · Minna no Nihongo Shokyū I & II · Try! 日本語能力試験 N5/N4'),
    ('N3', 'Shin Kanzen Master N3 (Grammar, Vocabulary, Reading, Listening) · Nihongo Sō Matome N3'),
    ('N2', 'Shin Kanzen Master N2 series · Nihongo Sō Matome N2 · 日本語能力試験 公式問題集 N2'),
    ('N1', 'Shin Kanzen Master N1 series · Nihongo Sō Matome N1 · 日本語能力試験 公式問題集 N1'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sources')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: Text('Where the content comes from', style: context.text.headlineSmall)),
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
                const Eyebrow('Recommended books'),
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
