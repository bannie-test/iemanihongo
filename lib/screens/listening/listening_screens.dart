import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/jlpt.dart';
import '../../models/listening.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/botanical.dart';
import '../../widgets/common.dart';
import '../../widgets/jlpt_widgets.dart';

/// Listening practice (聴解): JLPT-style dialogues and sentence listening,
/// all read aloud on the device so it works offline.
class ListeningHubScreen extends StatefulWidget {
  const ListeningHubScreen({super.key});

  @override
  State<ListeningHubScreen> createState() => _ListeningHubScreenState();
}

class _ListeningHubScreenState extends State<ListeningHubScreen> {
  int? _level;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final c = context.colors;
    final level = _level ?? state.settings.level;
    final items = state.content.listening.where((i) => i.level == level).toList();
    final results = state.listeningResults;
    final done = items.where((i) => results.containsKey(i.id)).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Nghe hiểu · 聴解')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          Text(
            'Hội thoại và câu được đọc bằng hai giọng. Hãy nghe trước rồi trả lời – lời thoại được ẩn cho đến khi bạn muốn xem.',
            style: context.text.bodyMedium?.copyWith(color: c.muted),
          ),
          const SizedBox(height: 14),
          LevelPicker(value: level, onChanged: (l) => setState(() => _level = l)),
          const SizedBox(height: 18),
          SoftCard(
            tone: PanelTone.sage,
            radius: AppTheme.radiusWide,
            onTap: () =>
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => SentenceListeningScreen(level: level))),
            child: Row(
              children: [
                const OrnamentCircle(size: 58, child: Icon(AppIcons.voice)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nghe câu', style: context.text.titleMedium),
                      Text(
                        'Nghe một câu N$level và chọn nghĩa tiếng Việt đúng · 10 câu',
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(AppIcons.next),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: Text('Hội thoại kiểu JLPT', style: context.text.titleLarge)),
              Text('$done/${items.length} đã nghe', style: context.text.bodySmall),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const EmptyState(icon: AppIcons.voice, title: 'Chưa có bài nghe', body: 'Hãy chọn cấp độ khác.')
          else
            SoftCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ListeningPlayerScreen(items: items, initialIndex: i),
                        ),
                      ),
                      leading: Icon(
                        results[items[i].id] == null
                            ? AppIcons.circle
                            : results[items[i].id]!
                            ? AppIcons.checkCircle
                            : AppIcons.retry,
                        color: results[items[i].id] == null
                            ? c.ornament
                            : results[items[i].id]!
                            ? c.good
                            : c.clay,
                      ),
                      title: Text(items[i].title),
                      subtitle: Text('${items[i].kind.jp} · ${items[i].kind.vi}'),
                      trailing: const Icon(AppIcons.next),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class ListeningPlayerScreen extends StatefulWidget {
  const ListeningPlayerScreen({super.key, required this.items, required this.initialIndex});

  final List<ListeningItem> items;
  final int initialIndex;

  @override
  State<ListeningPlayerScreen> createState() => _ListeningPlayerScreenState();
}

class _ListeningPlayerScreenState extends State<ListeningPlayerScreen> {
  late int _index = widget.initialIndex;
  late final AppState _state;
  bool _playing = false;
  bool _heard = false;
  bool _transcript = false;
  int? _chosen;

  ListeningItem get _item => widget.items[_index];

  @override
  void initState() {
    super.initState();
    _state = context.read<AppState>();
  }

  @override
  void dispose() {
    _state.tts.stop();
    super.dispose();
  }

  Future<void> _play() async {
    setState(() => _playing = true);
    await _state.tts.speakLines([for (final l in _item.lines) (l.text, l.pitch)]);
    if (mounted) {
      setState(() {
        _playing = false;
        _heard = true;
      });
    }
  }

  Future<void> _stop() async {
    await _state.tts.stop();
    if (mounted) setState(() => _playing = false);
  }

  void _choose(int i) {
    if (_chosen != null) return;
    setState(() {
      _chosen = i;
      _transcript = true;
    });
    _state.recordListening(
      itemId: _item.id,
      level: _item.level,
      tag: 'Nghe: ${_item.kind.vi}',
      chosen: i,
      correct: i == _item.answer,
    );
  }

  void _go(int i) {
    _state.tts.stop();
    setState(() {
      _index = i;
      _playing = false;
      _heard = false;
      _transcript = false;
      _chosen = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final item = _item;
    final answered = _chosen != null;
    final showOptions = _heard || answered;

    OptionState stateFor(int i) {
      if (!answered) return OptionState.idle;
      if (i == item.answer) return OptionState.correct;
      if (i == _chosen) return OptionState.wrong;
      return OptionState.dimmed;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('N${item.level} · ${_index + 1}/${widget.items.length}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                Text('Lời thoại', style: context.text.bodySmall),
                Switch(value: _transcript, onChanged: (v) => setState(() => _transcript = v)),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Eyebrow('${item.kind.jp} · ${item.kind.vi}'),
            const SizedBox(height: 4),
            Text(item.title, style: context.text.headlineSmall),
            const SizedBox(height: 16),
            Center(
              child: Semantics(
                button: true,
                label: _playing ? 'Dừng âm thanh' : 'Phát âm thanh',
                child: GestureDetector(
                  onTap: _playing ? _stop : _play,
                  child: ArchPanel(
                    width: 150,
                    height: 170,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_playing ? AppIcons.close : AppIcons.speaker, size: 40),
                            const SizedBox(height: 6),
                            Text(_playing ? 'Dừng' : (_heard ? 'Nghe lại' : 'Nghe'), style: context.text.titleMedium),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_transcript)
              SoftCard(
                tone: PanelTone.clay,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final l in item.lines)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 26,
                              child: Text(
                                l.label,
                                style: TextStyle(color: c.clay, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(child: Text(l.text, style: const TextStyle(fontSize: 16, height: 1.6))),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            Text(item.question, style: AppTheme.jp(18, height: 1.5)),
            const SizedBox(height: 12),
            if (!showOptions)
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _heard = true),
                  child: const Text('Hiện lựa chọn (chưa nghe)'),
                ),
              )
            else
              for (var i = 0; i < item.options.length; i++)
                JlptOption(
                  index: i,
                  text: item.options[i],
                  state: stateFor(i),
                  onTap: answered ? null : () => _choose(i),
                ),
            if (answered) ...[const SizedBox(height: 6), _ListeningExplanation(item: item)],
            const SizedBox(height: 18),
            Row(
              children: [
                IconButton.outlined(
                  tooltip: 'Bài trước',
                  onPressed: _index == 0 ? null : () => _go(_index - 1),
                  icon: const Icon(AppIcons.back),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GradientButton(
                    label: _index == widget.items.length - 1 ? 'Xong' : 'Bài tiếp',
                    height: 50,
                    onPressed: _index == widget.items.length - 1 ? () => Navigator.pop(context) : () => _go(_index + 1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ListeningExplanation extends StatelessWidget {
  const _ListeningExplanation({required this.item});
  final ListeningItem item;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SoftCard(
      tone: PanelTone.sage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.translate, size: 16, color: c.clay),
              const SizedBox(width: 6),
              Text(
                'Câu hỏi',
                style: TextStyle(fontWeight: FontWeight.w600, color: c.clay, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(item.translation),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(AppIcons.bulb, size: 16, color: c.clay),
              const SizedBox(width: 6),
              Text(
                'Giải thích',
                style: TextStyle(fontWeight: FontWeight.w600, color: c.clay, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(item.explanation, style: const TextStyle(height: 1.5)),
          if (item.tip != null) ...[const SizedBox(height: 10), TipBox(item.tip!)],
        ],
      ),
    );
  }
}

/// Hear one sentence, pick its Vietnamese meaning. Sentences come from the
/// JLPT questions of the chosen level (with the answer filled in).
class SentenceListeningScreen extends StatefulWidget {
  const SentenceListeningScreen({super.key, required this.level});
  final int level;

  @override
  State<SentenceListeningScreen> createState() => _SentenceListeningScreenState();
}

class SentenceQ {
  SentenceQ(this.id, this.jp, this.options, this.answer);
  final String id;
  final String jp;
  final List<String> options;
  final int answer;
}

class _SentenceListeningScreenState extends State<SentenceListeningScreen> {
  late final AppState _state;
  late final List<SentenceQ> _qs;
  int _index = 0;
  int? _chosen;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _state = context.read<AppState>();
    _qs = buildSentenceQuestions(_state.content.questionsFor(widget.level), Random());
    WidgetsBinding.instance.addPostFrameCallback((_) => _play());
  }

  @override
  void dispose() {
    _state.tts.stop();
    super.dispose();
  }

  void _play() {
    if (_index < _qs.length) _state.tts.speak(_qs[_index].jp);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final done = _index >= _qs.length;
    return Scaffold(
      appBar: AppBar(title: Text('Nghe câu · N${widget.level}')),
      body: SafeArea(
        child: _qs.isEmpty
            ? const EmptyState(icon: AppIcons.voice, title: 'Chưa có câu', body: 'Cấp độ này chưa có câu nghe.')
            : done
            ? EmptyState(
                icon: AppIcons.trophy,
                title: '$_score / ${_qs.length} câu đúng',
                body: 'Nghe lại nhiều lần giúp bạn quen tốc độ và ngữ điệu.',
                action: GradientButton(label: 'Xong', onPressed: () => Navigator.pop(context)),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  Bar(_index / _qs.length),
                  const SizedBox(height: 18),
                  Center(
                    child: Semantics(
                      button: true,
                      label: 'Phát câu',
                      child: GestureDetector(
                        onTap: _play,
                        child: const OrnamentCircle(size: 112, child: Icon(AppIcons.speaker, size: 40)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(child: Text('Chạm để nghe lại', style: context.text.bodySmall)),
                  const SizedBox(height: 18),
                  Text('Câu bạn nghe có nghĩa là gì?', style: context.text.titleMedium),
                  const SizedBox(height: 10),
                  for (var i = 0; i < _qs[_index].options.length; i++)
                    JlptOption(
                      index: i,
                      text: _qs[_index].options[i],
                      state: _chosen == null
                          ? OptionState.idle
                          : i == _qs[_index].answer
                          ? OptionState.correct
                          : i == _chosen
                          ? OptionState.wrong
                          : OptionState.dimmed,
                      onTap: _chosen != null
                          ? null
                          : () {
                              final ok = i == _qs[_index].answer;
                              setState(() {
                                _chosen = i;
                                if (ok) _score++;
                              });
                              _state.recordListening(
                                itemId: 'sentence:${_qs[_index].id}',
                                level: widget.level,
                                tag: 'Nghe: câu',
                                chosen: i,
                                correct: ok,
                              );
                            },
                    ),
                  if (_chosen != null) ...[
                    SoftCard(
                      tone: PanelTone.clay,
                      child: Text(_qs[_index].jp, style: AppTheme.jp(18, height: 1.6, color: c.forest)),
                    ),
                    const SizedBox(height: 14),
                    GradientButton(
                      label: _index == _qs.length - 1 ? 'Xem kết quả' : 'Câu tiếp',
                      onPressed: () {
                        setState(() {
                          _index++;
                          _chosen = null;
                        });
                        _play();
                      },
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Turns JLPT questions into full sentences (blank filled, underline
/// removed) paired with their Vietnamese translations.
List<SentenceQ> buildSentenceQuestions(List<JlptQuestion> source, Random rng, {int count = 10}) {
  final usable = source.where((q) => q.section != JlptSection.narabe).toList()..shuffle(rng);
  final pool = [for (final q in usable) (q.id, completeSentence(q), q.translation)];
  final out = <SentenceQ>[];
  for (final (id, jp, vi) in pool.take(count)) {
    final others = pool.where((p) => p.$1 != id).map((p) => p.$3).toSet().toList()..shuffle(rng);
    final options = [vi, ...others.take(3)]..shuffle(rng);
    out.add(SentenceQ(id, jp, options, options.indexOf(vi)));
  }
  return out;
}

String completeSentence(JlptQuestion q) {
  var s = q.sentence.replaceAllMapped(RegExp(r'\[([^\]]+)\]'), (m) => m.group(1)!);
  if (s.contains('（　）')) s = s.replaceFirst('（　）', q.options[q.answer]);
  return s.replaceAll(' ', '');
}
