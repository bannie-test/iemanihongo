import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/srs.dart';
import '../models/content.dart';
import '../models/user_data.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Word details: audio, SRS status, decks and kanji breakdown.
Future<void> showWordSheet(BuildContext context, Word w) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (context, controller) => _WordSheet(word: w, controller: controller),
      ),
    );

Future<void> showKanjiSheet(BuildContext context, KanjiInfo k) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [KanjiPanel(info: k, showWords: true)],
        ),
      ),
    );

class _WordSheet extends StatelessWidget {
  const _WordSheet({required this.word, required this.controller});

  final Word word;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final c = context.colors;
    final card = state.cards[word.id];
    final kanji = state.content.kanjiIn(word);

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (word.showReading) Text(word.reading, style: TextStyle(color: c.muted, fontSize: 16, letterSpacing: 1.5)),
              Text(word.word, style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w700, height: 1.2)),
            ]),
          ),
          SpeakButton(word.speakText, size: 48),
        ]),
        const SizedBox(height: 8),
        Text(word.meaning, style: context.text.titleMedium),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          Tag('JLPT N${word.level}', accent: true),
          Tag(_status(card, state.nowMs)),
          if (card != null && card.lapses > 0) Tag('Missed ${card.lapses}×'),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => state.toggleStar(word.id),
              icon: Icon(state.isStarred(word.id) ? Icons.star_rounded : Icons.star_outline_rounded, color: c.accent),
              label: Text(state.isStarred(word.id) ? 'Starred' : 'Star'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _pickDecks(context, state),
              icon: const Icon(Icons.playlist_add_rounded),
              label: const Text('Add to deck'),
            ),
          ),
        ]),
        if (kanji.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Kanji breakdown', style: context.text.titleMedium),
          const SizedBox(height: 10),
          for (final k in kanji) ...[KanjiPanel(info: k), const SizedBox(height: 10)],
        ],
      ],
    );
  }

  static String _status(CardState? c, int now) {
    if (c == null) return 'Not studied yet';
    if (c.phase == CardPhase.learning || c.phase == CardPhase.relearning) return 'Learning';
    if (c.due <= now) return 'Due now';
    return 'Next review in ${Srs.formatInterval(c.due - now)}';
  }

  Future<void> _pickDecks(BuildContext context, AppState state) => showModalBottomSheet(
        context: context,
        builder: (context) => Consumer<AppState>(
          builder: (context, state, _) => ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              for (final d in state.visibleDecks.where((d) => !d.isStarred))
                CheckboxListTile(
                  value: state.inDeck(d.id, word.id),
                  title: Text(d.name),
                  onChanged: (v) => state.setInDeck(d.id, word.id, v ?? false),
                ),
              ListTile(
                leading: const Icon(Icons.add_rounded),
                title: const Text('New deck…'),
                onTap: () async {
                  final name = await promptDeckName(context);
                  if (name != null) {
                    final d = state.createDeck(name);
                    state.setInDeck(d.id, word.id, true);
                  }
                },
              ),
            ],
          ),
        ),
      );
}

Future<String?> promptDeckName(BuildContext context, {Deck? existing}) {
  final controller = TextEditingController(text: existing?.name);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(existing == null ? 'New deck' : 'Rename deck'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'e.g. Travel words'),
        onSubmitted: (v) => Navigator.pop(context, v.trim().isEmpty ? null : v.trim()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text.trim().isEmpty ? null : controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

class KanjiPanel extends StatelessWidget {
  const KanjiPanel({super.key, required this.info, this.showWords = false});

  final KanjiInfo info;
  final bool showWords;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = context.read<AppState>();
    final related = showWords ? state.content.wordsWithKanji(info.char) : const <Word>[];
    String clean(List<String> r) => r.map((s) => s.replaceAll('.', '')).join('、');

    return SoftCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: c.accentSoft, borderRadius: BorderRadius.circular(18)),
            child: Center(child: Text(info.char, style: TextStyle(fontSize: 38, color: c.accent, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(info.meanings.take(4).join(', '), style: context.text.titleMedium),
              const SizedBox(height: 4),
              Wrap(spacing: 6, runSpacing: 4, children: [
                if (info.strokes != null) Tag('${info.strokes} strokes'),
                if (info.level != null) Tag('Kanji N${info.level}'),
              ]),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        if (info.onReadings.isNotEmpty) _reading(context, '音 On', clean(info.onReadings)),
        if (info.kunReadings.isNotEmpty) _reading(context, '訓 Kun', clean(info.kunReadings)),
        if (related.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Words with ${info.char}', style: context.text.titleMedium),
          const SizedBox(height: 6),
          for (final w in related)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(w.word, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              subtitle: Text('${w.showReading ? '${w.reading} · ' : ''}${w.shortMeaning}'),
              trailing: Tag('N${w.level}'),
              onTap: () => showWordSheet(context, w),
            ),
        ],
      ]),
    );
  }

  Widget _reading(BuildContext context, String label, String value) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 64, child: Text(label, style: context.text.bodySmall)),
          Expanded(child: Text(value)),
        ]),
      );
}
