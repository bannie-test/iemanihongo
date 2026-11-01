import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/srs.dart';
import '../models/content.dart';
import '../models/user_data.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'flashcard_screen.dart';
import 'quiz_screen.dart';
import 'word_sheet.dart';
import '../widgets/app_icons.dart';

/// Browse every JLPT word, search, and manage starred words and decks.
class WordsScreen extends StatefulWidget {
  const WordsScreen({super.key});

  @override
  State<WordsScreen> createState() => _WordsScreenState();
}

class _WordsScreenState extends State<WordsScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Từ vựng'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(120),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Column(
                children: [
                  TextField(
                    controller: _search,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Tìm 日本語, かな hoặc tiếng Việt',
                      prefixIcon: const Icon(AppIcons.search),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(AppIcons.close),
                              tooltip: 'Xóa',
                              onPressed: () => setState(() {
                                _search.clear();
                                _query = '';
                              }),
                            ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const TabBar(
                    tabs: [
                      Tab(text: 'Cấp độ JLPT'),
                      Tab(text: 'Bộ từ của tôi'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: _query.trim().isNotEmpty
            ? WordList(words: state.content.search(_query))
            : const TabBarView(children: [_LevelsTab(), _DecksTab()]),
      ),
    );
  }
}

class _LevelsTab extends StatelessWidget {
  const _LevelsTab();

  static const _names = {5: 'Sơ cấp', 4: 'Sơ trung cấp', 3: 'Trung cấp', 2: 'Trung cao cấp', 1: 'Cao cấp'};

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final l in [5, 4, 3, 2, 1]) ...[
          SoftCard(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LevelWordsScreen(level: l))),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: context.colors.accentSoft, borderRadius: BorderRadius.circular(16)),
                  child: Center(
                    child: Text(
                      'N$l',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: context.colors.accent),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_names[l]!, style: context.text.titleMedium),
                      const SizedBox(height: 6),
                      Bar(state.learnedCount(l) / state.content.byLevel[l]!.length),
                      const SizedBox(height: 4),
                      Text(
                        '${state.learnedCount(l)} đã thuộc · ${state.seenCount(l) - state.learnedCount(l)} đang học · '
                        '${state.content.byLevel[l]!.length} từ',
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(AppIcons.next),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _DecksTab extends StatelessWidget {
  const _DecksTab();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final d in state.visibleDecks) ...[
          SoftCard(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DeckScreen(deckId: d.id))),
            child: Row(
              children: [
                Icon(d.isStarred ? AppIcons.starOn : AppIcons.folder, color: context.colors.accent, size: 30),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.name, style: context.text.titleMedium),
                      Text('${state.wordsIn(d.id).length} từ', style: context.text.bodySmall),
                    ],
                  ),
                ),
                const Icon(AppIcons.next),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        OutlinedButton.icon(
          onPressed: () async {
            final name = await promptDeckName(context);
            if (name != null) state.createDeck(name);
          },
          icon: const Icon(AppIcons.add),
          label: const Text('Bộ từ mới'),
        ),
        const SizedBox(height: 8),
        Text(
          'Mẹo: đánh dấu sao từ trên thẻ từ, hoặc thêm vào bộ từ từ trang chi tiết của từ.',
          textAlign: TextAlign.center,
          style: context.text.bodySmall,
        ),
      ],
    );
  }
}

enum _Filter { all, fresh, learning, learned }

class LevelWordsScreen extends StatefulWidget {
  const LevelWordsScreen({super.key, required this.level});
  final int level;

  @override
  State<LevelWordsScreen> createState() => _LevelWordsScreenState();
}

class _LevelWordsScreenState extends State<LevelWordsScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final all = state.content.byLevel[widget.level]!;
    final words = all.where((w) {
      final c = state.cards[w.id];
      return switch (_filter) {
        _Filter.all => true,
        _Filter.fresh => c == null,
        _Filter.learning => c != null && !c.isLearned,
        _Filter.learned => c?.isLearned ?? false,
      };
    }).toList();
    final next = state.nextNewWords(10, level: widget.level);

    return Scaffold(
      appBar: AppBar(title: Text('JLPT N${widget.level}')),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final f in _Filter.values) ...[
                  ChoiceChip(
                    label: Text(switch (f) {
                      _Filter.all => 'Tất cả ${all.length}',
                      _Filter.fresh => 'Mới',
                      _Filter.learning => 'Đang học',
                      _Filter.learned => 'Đã thuộc',
                    }),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          Expanded(child: WordList(words: words)),
          if (next.isNotEmpty)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: GradientButton(
                  label: 'Học ${next.length} từ mới N${widget.level}',
                  icon: AppIcons.add,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FlashcardScreen(words: next, title: 'Từ mới N${widget.level}'),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DeckScreen extends StatelessWidget {
  const DeckScreen({super.key, required this.deckId});
  final String deckId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final Deck deck = deckId == Deck.starredId ? state.starredDeck : state.decks[deckId]!;
    final words = state.wordsIn(deckId);

    return Scaffold(
      appBar: AppBar(
        title: Text(deck.name),
        actions: [
          if (!deck.isStarred)
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'rename') {
                  final name = await promptDeckName(context, existing: deck);
                  if (name != null) state.renameDeck(deck, name);
                } else if (v == 'delete') {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Xóa "${deck.name}"?'),
                      content: const Text('Các từ vẫn còn trong ứng dụng và giữ nguyên tiến độ.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
                      ],
                    ),
                  );
                  if (ok == true && context.mounted) {
                    state.deleteDeck(deck);
                    Navigator.pop(context);
                  }
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'rename', child: Text('Đổi tên')),
                PopupMenuItem(value: 'delete', child: Text('Xóa bộ từ')),
              ],
            ),
        ],
      ),
      body: words.isEmpty
          ? EmptyState(
              icon: deck.isStarred ? AppIcons.star : AppIcons.folderOpen,
              title: 'Chưa có từ nào',
              body: deck.isStarred
                  ? 'Chạm vào ngôi sao trên thẻ từ hoặc trang chi tiết để lưu từ khó vào đây.'
                  : 'Mở một từ bất kỳ và chọn "Thêm vào bộ từ".',
            )
          : Column(
              children: [
                Expanded(child: WordList(words: words)),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: words.length < 4
                                ? null
                                : () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => QuizSetupScreen(pool: words, sourceLabel: deck.name),
                                    ),
                                  ),
                            icon: const Icon(AppIcons.quiz),
                            label: const Text('Trắc nghiệm'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GradientButton(
                            label: 'Học',
                            height: 48,
                            icon: AppIcons.wordsOn,
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => FlashcardScreen(words: words..shuffle(), title: deck.name),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class WordList extends StatelessWidget {
  const WordList({super.key, required this.words});
  final List<Word> words;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final c = context.colors;
    if (words.isEmpty) {
      return const EmptyState(icon: AppIcons.notFound, title: 'Không có gì ở đây', body: 'Hãy thử bộ lọc hoặc từ khóa khác.');
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: words.length,
      separatorBuilder: (_, _) => const Divider(indent: 16, endIndent: 16),
      itemBuilder: (context, i) {
        final w = words[i];
        final card = state.cards[w.id];
        final dot = card == null
            ? c.surface2
            : card.isLearned
            ? c.good
            : card.phase == CardPhase.fresh
            ? c.surface2
            : c.clay;
        return ListTile(
          onTap: () => showWordSheet(context, w),
          leading: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          minLeadingWidth: 10,
          title: Text(w.word, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          subtitle: Text(
            '${w.showReading ? '${w.reading} · ' : ''}${w.shortMeaning}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.isStarred(w.id)) Icon(AppIcons.starOn, color: c.accent, size: 18),
              const SizedBox(width: 4),
              SpeakButton(w.speakText, size: 34),
            ],
          ),
        );
      },
    );
  }
}
