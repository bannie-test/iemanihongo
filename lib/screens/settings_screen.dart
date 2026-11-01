import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/vi_format.dart';

import '../models/settings.dart';
import '../services/sync_service.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'auth_screen.dart';
import 'database_setup_screen.dart';
import 'sources_screen.dart';
import '../widgets/app_icons.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.settings;
    final c = context.colors;

    Widget section(String title, List<Widget> children) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
            child: Text(
              title.toUpperCase(),
              style: context.text.bodySmall?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w600),
            ),
          ),
          SoftCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(children: children),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          section('Tài khoản & đồng bộ', [_AccountTile(state: state)]),
          section('Học tập', [
            ListTile(
              title: const Text('Mục tiêu mỗi ngày'),
              subtitle: const Text('Số thẻ + câu trả lời mỗi ngày'),
              trailing: DropdownButton<int>(
                value: s.dailyGoal,
                underline: const SizedBox(),
                items: [for (final g in AppSettings.goalOptions) DropdownMenuItem(value: g, child: Text('$g'))],
                onChanged: (v) => state.updateSettings((x) => x.copyWith(dailyGoal: v)),
              ),
            ),
            ListTile(
              title: const Text('Từ mới mỗi ngày'),
              trailing: DropdownButton<int>(
                value: s.newPerDay,
                underline: const SizedBox(),
                items: [for (final g in AppSettings.newPerDayOptions) DropdownMenuItem(value: g, child: Text('$g'))],
                onChanged: (v) => state.updateSettings((x) => x.copyWith(newPerDay: v)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lấy từ mới ở cấp độ'),
                  const SizedBox(height: 8),
                  LevelPicker(
                    value: s.level,
                    onChanged: (l) => state.updateSettings((x) => x.copyWith(level: l)),
                  ),
                ],
              ),
            ),
          ]),
          section('Nhắc nhở', [
            SwitchListTile(
              value: s.remindersOn,
              title: const Text('Nhắc học hằng ngày'),
              subtitle: const Text('Bỏ qua khi đã đạt mục tiêu hôm nay'),
              onChanged: (v) async {
                if (v) await state.notifications.requestPermission();
                state.updateSettings((x) => x.copyWith(remindersOn: v));
              },
            ),
            ListTile(
              enabled: s.remindersOn,
              leading: const Icon(AppIcons.schedule),
              title: const Text('Giờ nhắc'),
              trailing: Text(
                TimeOfDay(hour: s.reminderHour, minute: s.reminderMinute).format(context),
                style: TextStyle(color: c.accent, fontWeight: FontWeight.w600),
              ),
              onTap: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: s.reminderHour, minute: s.reminderMinute),
                );
                if (t != null) state.updateSettings((x) => x.copyWith(reminderHour: t.hour, reminderMinute: t.minute));
              },
            ),
            SwitchListTile(
              value: s.streakNudge,
              title: const Text('Nhắc khi sắp mất chuỗi'),
              subtitle: const Text('Lúc 21 giờ nếu chưa đạt mục tiêu'),
              onChanged: s.remindersOn ? (v) => state.updateSettings((x) => x.copyWith(streakNudge: v)) : null,
            ),
          ]),
          section('Âm thanh', [
            SwitchListTile(
              value: s.autoplayAudio,
              title: const Text('Tự phát âm'),
              subtitle: const Text('Khi lật thẻ hoặc trả lời câu hỏi'),
              onChanged: (v) => state.updateSettings((x) => x.copyWith(autoplayAudio: v)),
            ),
            ListTile(
              title: const Text('Tốc độ đọc'),
              subtitle: Slider(
                value: s.speechRate,
                min: 0.2,
                max: 0.7,
                divisions: 10,
                label: s.speechRate < 0.35
                    ? 'Chậm'
                    : s.speechRate > 0.55
                    ? 'Nhanh'
                    : 'Bình thường',
                onChanged: (v) => state.updateSettings((x) => x.copyWith(speechRate: v)),
              ),
              trailing: const SpeakButton('こんにちは、日本語を勉強しましょう。'),
            ),
            ValueListenableBuilder(
              valueListenable: state.tts.japaneseAvailable,
              builder: (context, ok, _) => ok == false
                  ? const ListTile(
                      leading: Icon(AppIcons.warning),
                      title: Text('Chưa cài giọng đọc tiếng Nhật'),
                      subtitle: Text(
                        'Android: Cài đặt → Hỗ trợ tiếp cận → Chuyển văn bản thành giọng nói → cài dữ liệu giọng tiếng Nhật.',
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ]),
          section('Giao diện', [
            Padding(
              padding: const EdgeInsets.all(12),
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('Hệ thống'), icon: Icon(AppIcons.system)),
                  ButtonSegment(value: ThemeMode.light, label: Text('Sáng'), icon: Icon(AppIcons.light)),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Tối'), icon: Icon(AppIcons.dark)),
                ],
                selected: {s.themeMode},
                onSelectionChanged: (v) => state.updateSettings((x) => x.copyWith(themeMode: v.first)),
              ),
            ),
          ]),
          section('Thông tin', [
            ListTile(
              title: const Text('Nguồn nội dung & tài liệu tham khảo'),
              subtitle: const Text('Từ vựng, kanji, thứ tự nét, sách ngữ pháp, tài liệu JLPT'),
              trailing: const Icon(AppIcons.next),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SourcesScreen())),
            ),
          ]),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final user = state.user;
    if (user == null) {
      return Column(
        children: [
          const ListTile(
            leading: Icon(AppIcons.guest),
            title: Text('Khách'),
            subtitle: Text('Tiến độ chỉ được lưu trên máy này.'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: GradientButton(
              label: 'Đăng nhập để đồng bộ',
              height: 46,
              icon: AppIcons.cloudUpload,
              onPressed: state.supabase == null
                  ? null
                  : () =>
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthScreen(linking: true))),
            ),
          ),
        ],
      );
    }
    final sync = state.sync!;
    return Column(
      children: [
        ListTile(
          leading: const Icon(AppIcons.account),
          title: Text(user.email ?? 'Đã đăng nhập'),
          subtitle: ValueListenableBuilder(
            valueListenable: sync.lastSynced,
            builder: (context, t, _) =>
                Text(t == null ? 'Chưa đồng bộ' : 'Đồng bộ lần cuối: ${formatViDateTime(t)}'),
          ),
          trailing: ValueListenableBuilder(
            valueListenable: sync.status,
            builder: (context, st, _) => st == SyncStatus.syncing
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
                : IconButton(tooltip: 'Đồng bộ ngay', icon: const Icon(AppIcons.sync), onPressed: sync.sync),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: sync.lastError,
          builder: (context, err, _) => err == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(err, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
        ),
        ValueListenableBuilder(
          valueListenable: sync.needsDatabaseSetup,
          builder: (context, missing, _) => !missing
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: FilledButton.icon(
                    onPressed: () =>
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DatabaseSetupScreen())),
                    icon: const Icon(AppIcons.settings),
                    label: const Text('Thiết lập cơ sở dữ liệu'),
                  ),
                ),
        ),
        ListTile(
          leading: const Icon(AppIcons.signOut),
          title: const Text('Đăng xuất'),
          subtitle: const Text('Xóa dữ liệu của tài khoản này khỏi máy'),
          onTap: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Đăng xuất?'),
                content: const Text('Tiến độ đã được sao lưu vào tài khoản. Những thay đổi chưa đồng bộ sẽ bị mất.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Đăng xuất')),
                ],
              ),
            );
            if (ok == true && context.mounted) {
              Navigator.of(context).popUntil((r) => r.isFirst);
              await state.signOut();
            }
          },
        ),
      ],
    );
  }
}
