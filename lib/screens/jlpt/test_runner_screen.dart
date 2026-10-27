import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/jlpt.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/common.dart';
import '../../widgets/jlpt_widgets.dart';
import 'test_result_screen.dart';

/// Runs a mock test (timed, answers graded at the end) or a practice set
/// (untimed, answers can be revealed right away). Progress is saved after
/// every answer so the sitting can be resumed later or on another device.
class TestRunnerScreen extends StatefulWidget {
  const TestRunnerScreen({super.key, required this.attemptId});

  final String attemptId;

  @override
  State<TestRunnerScreen> createState() => _TestRunnerScreenState();
}

class _TestRunnerScreenState extends State<TestRunnerScreen> with WidgetsBindingObserver {
  late final AppState _state;
  late final TestAttempt _a;
  Timer? _ticker;
  bool _showAnswers = true;
  final Set<String> _revealed = {};
  int _sinceSave = 0;

  bool get _exam => _a.mode == AttemptMode.exam;
  JlptQuestion get _q => _state.content.questionById[_a.questionIds[_a.currentIndex]]!;

  @override
  void initState() {
    super.initState();
    _state = context.read<AppState>();
    _a = _state.attempts[widget.attemptId]!;
    _showAnswers = _state.prefs.getBool('jlpt_show_answers') ?? true;
    // A practice set re-opened later shows what was already answered.
    if (!_exam && _showAnswers) _revealed.addAll(_a.answers.keys);
    WidgetsBinding.instance.addObserver(this);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    if (_a.inProgress) _state.saveAttempt(_a, pushNow: true);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.paused && _a.inProgress) _state.saveAttempt(_a, pushNow: true);
  }

  void _tick() {
    if (!mounted || !_a.inProgress) return;
    final active = ModalRoute.of(context)?.isCurrent ?? true;
    if (!active) return; // paused while a dialog or sheet is open
    setState(() => _a.elapsedSec++);
    if (++_sinceSave >= 15) {
      _sinceSave = 0;
      _state.saveAttempt(_a);
    }
    if (_a.timed && _a.remainingSec <= 0) _submit(timeUp: true);
  }

  void _choose(int i) {
    // Practice answers are recorded once (they feed weak-area tracking).
    if (!_exam && _a.answers.containsKey(_q.id)) return;
    setState(() {
      if (_exam) {
        _a.answers[_q.id] = i;
        _state.saveAttempt(_a);
      } else {
        _state.recordPracticeAnswer(_a, _q, i);
        if (_showAnswers) _revealed.add(_q.id);
      }
    });
  }

  void _go(int index) {
    if (index < 0 || index >= _a.total) return;
    setState(() => _a.currentIndex = index);
    _state.saveAttempt(_a);
  }

  Future<void> _submit({bool timeUp = false}) async {
    if (!timeUp) {
      final unanswered = _a.total - _a.answers.length;
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(_exam ? 'Nộp bài?' : 'Kết thúc luyện tập?'),
          content: Text(
            unanswered > 0
                ? 'Bạn còn $unanswered câu chưa làm. Câu chưa làm sẽ tính là sai.'
                : 'Bạn đã làm hết ${_a.total} câu.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Làm tiếp')),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
              onPressed: () => Navigator.pop(context, true),
              child: Text(_exam ? 'Nộp bài' : 'Kết thúc'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    _ticker?.cancel();
    _state.finishAttempt(_a);
    if (!mounted) return;
    if (timeUp) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hết giờ! Bài đã được nộp tự động.')));
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => TestResultScreen(attemptId: _a.id)));
  }

  Future<void> _exit() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạm dừng'),
        content: Text(
          _exam
              ? 'Tiến độ và thời gian còn lại (${formatClock(_a.remainingSec)}) được lưu vào tài khoản. Bạn có thể làm tiếp bất cứ lúc nào.'
              : 'Tiến độ được lưu. Bạn có thể làm tiếp sau.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, 'submit'), child: Text(_exam ? 'Nộp bài' : 'Kết thúc')),
          TextButton(onPressed: () => Navigator.pop(context, 'exit'), child: const Text('Lưu & thoát')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
            onPressed: () => Navigator.pop(context, 'stay'),
            child: const Text('Làm tiếp'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (choice == 'exit') {
      _state.saveAttempt(_a, pushNow: true);
      Navigator.pop(context);
    } else if (choice == 'submit') {
      _submit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lowTime = _a.timed && _a.remainingSec < 300;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exit();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(AppIcons.close), tooltip: 'Tạm dừng', onPressed: _exit),
          titleSpacing: 0,
          title: Text(_a.title, style: const TextStyle(fontSize: 16)),
          actions: [
            if (_a.timed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: lowTime ? c.bad : c.accentSoft,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  children: [
                    Icon(AppIcons.timer, size: 16, color: lowTime ? Colors.white : c.accent),
                    const SizedBox(width: 4),
                    Text(
                      formatClock(_a.remainingSec),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: lowTime ? Colors.white : c.accent,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                children: [
                  Text('Hiện đáp án', style: context.text.bodySmall),
                  Switch(
                    value: _showAnswers,
                    onChanged: (v) {
                      setState(() => _showAnswers = v);
                      _state.prefs.setBool('jlpt_show_answers', v);
                    },
                  ),
                ],
              ),
            const SizedBox(width: 12),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(10),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Bar(_a.answers.length / _a.total, height: 5),
            ),
          ),
        ),
        body: SafeArea(child: _body(context)),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final c = context.colors;
    final q = _q;
    final chosen = _a.answers[q.id];
    final revealed = !_exam && _revealed.contains(q.id);
    final flagged = _a.flagged.contains(q.id);

    OptionState stateFor(int i) {
      if (revealed) {
        if (i == q.answer) return OptionState.correct;
        if (i == chosen) return OptionState.wrong;
        return OptionState.dimmed;
      }
      return i == chosen ? OptionState.selected : OptionState.idle;
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              Row(
                children: [
                  Tag('Câu ${_a.currentIndex + 1}/${_a.total}', accent: true),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(q.section.jp, style: context.text.bodySmall, overflow: TextOverflow.ellipsis),
                  ),
                  IconButton(
                    tooltip: flagged ? 'Bỏ đánh dấu' : 'Đánh dấu xem lại',
                    icon: Icon(flagged ? AppIcons.flagOn : AppIcons.flag, color: flagged ? Colors.orange : c.muted),
                    onPressed: () => setState(() {
                      flagged ? _a.flagged.remove(q.id) : _a.flagged.add(q.id);
                      _state.saveAttempt(_a);
                    }),
                  ),
                ],
              ),
              Text(q.section.instruction, style: context.text.bodySmall),
              const SizedBox(height: 12),
              SoftCard(padding: const EdgeInsets.all(18), child: JlptSentence(q)),
              const SizedBox(height: 16),
              for (var i = 0; i < q.options.length; i++)
                JlptOption(index: i, text: q.options[i], state: stateFor(i), onTap: revealed ? null : () => _choose(i)),
              if (!_exam && chosen != null && !revealed)
                TextButton.icon(
                  onPressed: () => setState(() => _revealed.add(q.id)),
                  icon: const Icon(AppIcons.eye),
                  label: const Text('Xem đáp án & giải thích'),
                ),
              if (revealed) ...[
                const SizedBox(height: 4),
                Text(
                  chosen == q.answer ? 'Chính xác! 🎉' : 'Chưa đúng – xem giải thích bên dưới',
                  style: TextStyle(fontWeight: FontWeight.w700, color: chosen == q.answer ? c.good : c.bad),
                ),
                const SizedBox(height: 8),
                ExplanationBox(q),
              ],
            ],
          ),
        ),
        _bottomBar(context),
      ],
    );
  }

  Widget _bottomBar(BuildContext context) {
    final last = _a.currentIndex == _a.total - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Row(
        children: [
          IconButton.outlined(
            tooltip: 'Câu trước',
            onPressed: _a.currentIndex == 0 ? null : () => _go(_a.currentIndex - 1),
            icon: const Icon(AppIcons.back),
          ),
          const SizedBox(width: 8),
          IconButton.outlined(tooltip: 'Danh sách câu', onPressed: _palette, icon: const Icon(AppIcons.grid)),
          const SizedBox(width: 8),
          Expanded(
            child: last
                ? GradientButton(label: _exam ? 'Nộp bài' : 'Kết thúc', height: 48, onPressed: _submit)
                : GradientButton(
                    label: 'Câu tiếp',
                    height: 48,
                    icon: AppIcons.next,
                    onPressed: () => _go(_a.currentIndex + 1),
                  ),
          ),
        ],
      ),
    );
  }

  void _palette() {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Đã làm ${_a.answers.length}/${_a.total} câu', style: context.text.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < _a.total; i++)
                    Builder(
                      builder: (context) {
                        final id = _a.questionIds[i];
                        final answered = _a.answers.containsKey(id);
                        final q = _state.content.questionById[id]!;
                        final show = !_exam && _revealed.contains(id);
                        final color = show
                            ? (_a.answers[id] == q.answer ? c.good : c.bad)
                            : answered
                            ? c.accent
                            : c.surface2;
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.pop(context);
                            _go(i);
                          },
                          child: Container(
                            width: 46,
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(12),
                              border: i == _a.currentIndex
                                  ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2)
                                  : null,
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: answered || show ? Colors.white : c.muted,
                                  ),
                                ),
                                if (_a.flagged.contains(id))
                                  const Positioned(
                                    right: -14,
                                    top: -14,
                                    child: Icon(AppIcons.flagOn, size: 14, color: Colors.orange),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
