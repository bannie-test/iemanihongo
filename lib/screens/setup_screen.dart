import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/settings.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/app_icons.dart';

/// First-run setup: level, daily goal and reminder time.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _level = 5;
  int _goal = 20;
  bool _remind = true;
  TimeOfDay _time = const TimeOfDay(hour: 19, minute: 0);

  static const _levelHints = {
    5: 'Sơ cấp · từ cơ bản và kana',
    4: 'Sơ trung cấp · hội thoại hằng ngày',
    3: 'Trung cấp · làm quen tài liệu thực tế',
    2: 'Trung cao cấp · tin tức và công việc',
    1: 'Cao cấp · tiếng Nhật trừu tượng và trang trọng',
  };

  Future<void> _done() async {
    final state = context.read<AppState>();
    if (_remind) await state.notifications.requestPermission();
    state.updateSettings(
      (s) => s.copyWith(
        level: _level,
        dailyGoal: _goal,
        remindersOn: _remind,
        reminderHour: _time.hour,
        reminderMinute: _time.minute,
      ),
    );
    await state.finishOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            Text('はじめまして！', style: context.text.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Hãy thiết lập kế hoạch học. Bạn có thể đổi bất cứ lúc nào.',
              style: context.text.bodyMedium?.copyWith(color: c.muted),
            ),
            const SizedBox(height: 28),
            Text('Bạn đang học cấp độ nào?', style: context.text.titleMedium),
            const SizedBox(height: 10),
            LevelPicker(value: _level, onChanged: (l) => setState(() => _level = l)),
            const SizedBox(height: 8),
            Text(_levelHints[_level]!, style: context.text.bodySmall),
            const SizedBox(height: 28),
            Text('Mục tiêu mỗi ngày', style: context.text.titleMedium),
            const SizedBox(height: 4),
            Text('Số thẻ và câu hỏi mỗi ngày. Đạt mục tiêu để giữ chuỗi ngày học.', style: context.text.bodySmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                for (final g in AppSettings.goalOptions)
                  ChoiceChip(
                    label: Text('$g · ${_goalName(g)}'),
                    selected: g == _goal,
                    onSelected: (_) => setState(() => _goal = g),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Column(
                children: [
                  SwitchListTile(
                    value: _remind,
                    onChanged: (v) => setState(() => _remind = v),
                    title: const Text('Nhắc học hằng ngày', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Tự bỏ qua khi bạn đã đạt mục tiêu'),
                  ),
                  if (_remind)
                    ListTile(
                      leading: const Icon(AppIcons.schedule),
                      title: const Text('Nhắc lúc'),
                      trailing: Text(_time.format(context), style: context.text.titleMedium?.copyWith(color: c.accent)),
                      onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: _time);
                        if (t != null) setState(() => _time = t);
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            GradientButton(label: 'Bắt đầu học', icon: AppIcons.next, onPressed: _done),
          ],
        ),
      ),
    );
  }

  static String _goalName(int g) => switch (g) {
    10 => 'nhẹ nhàng',
    20 => 'đều đặn',
    30 => 'nghiêm túc',
    _ => 'cường độ cao',
  };
}
