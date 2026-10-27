import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/settings.dart';
import '../services/sync_service.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'auth_screen.dart';
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
              style: context.text.bodySmall?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w700),
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
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          section('Account & sync', [_AccountTile(state: state)]),
          section('Study', [
            ListTile(
              title: const Text('Daily goal'),
              subtitle: const Text('Cards + quiz answers per day'),
              trailing: DropdownButton<int>(
                value: s.dailyGoal,
                underline: const SizedBox(),
                items: [for (final g in AppSettings.goalOptions) DropdownMenuItem(value: g, child: Text('$g'))],
                onChanged: (v) => state.updateSettings((x) => x.copyWith(dailyGoal: v)),
              ),
            ),
            ListTile(
              title: const Text('New words per day'),
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
                  const Text('New words come from'),
                  const SizedBox(height: 8),
                  LevelPicker(
                    value: s.level,
                    onChanged: (l) => state.updateSettings((x) => x.copyWith(level: l)),
                  ),
                ],
              ),
            ),
          ]),
          section('Reminders', [
            SwitchListTile(
              value: s.remindersOn,
              title: const Text('Daily reminder'),
              subtitle: const Text('Skipped once today\'s goal is done'),
              onChanged: (v) async {
                if (v) await state.notifications.requestPermission();
                state.updateSettings((x) => x.copyWith(remindersOn: v));
              },
            ),
            ListTile(
              enabled: s.remindersOn,
              leading: const Icon(AppIcons.schedule),
              title: const Text('Reminder time'),
              trailing: Text(
                TimeOfDay(hour: s.reminderHour, minute: s.reminderMinute).format(context),
                style: TextStyle(color: c.accent, fontWeight: FontWeight.w700),
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
              title: const Text('Streak-at-risk nudge'),
              subtitle: const Text('9 PM if you haven\'t hit your goal'),
              onChanged: s.remindersOn ? (v) => state.updateSettings((x) => x.copyWith(streakNudge: v)) : null,
            ),
          ]),
          section('Audio', [
            SwitchListTile(
              value: s.autoplayAudio,
              title: const Text('Auto-play pronunciation'),
              subtitle: const Text('When a card is revealed or a quiz is answered'),
              onChanged: (v) => state.updateSettings((x) => x.copyWith(autoplayAudio: v)),
            ),
            ListTile(
              title: const Text('Speech speed'),
              subtitle: Slider(
                value: s.speechRate,
                min: 0.2,
                max: 0.7,
                divisions: 10,
                label: s.speechRate < 0.35
                    ? 'Slow'
                    : s.speechRate > 0.55
                    ? 'Fast'
                    : 'Normal',
                onChanged: (v) => state.updateSettings((x) => x.copyWith(speechRate: v)),
              ),
              trailing: const SpeakButton('こんにちは、日本語を勉強しましょう。'),
            ),
            ValueListenableBuilder(
              valueListenable: state.tts.japaneseAvailable,
              builder: (context, ok, _) => ok == false
                  ? const ListTile(
                      leading: Icon(AppIcons.warning),
                      title: Text('Japanese voice not installed'),
                      subtitle: Text(
                        'Android: Settings → Accessibility → Text-to-speech → install Japanese voice data.',
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ]),
          section('Appearance', [
            Padding(
              padding: const EdgeInsets.all(12),
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(AppIcons.system)),
                  ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(AppIcons.light)),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(AppIcons.dark)),
                ],
                selected: {s.themeMode},
                onSelectionChanged: (v) => state.updateSettings((x) => x.copyWith(themeMode: v.first)),
              ),
            ),
          ]),
          section('About', [
            const ListTile(
              title: Text('Content sources'),
              subtitle: Text(
                'Vocabulary: JLPT lists by Jonathan Waller (tanos.co.uk, CC BY) via open-anki-jlpt-decks (MIT). '
                'Kanji: KANJIDIC2 by EDRDG (CC BY-SA 4.0). Stroke order: KanjiVG by Ulrich Apel (CC BY-SA 3.0). '
                'Fonts: Nunito, Zen Maru Gothic (SIL OFL). Icons: Lucide (ISC).',
              ),
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
            title: Text('Guest'),
            subtitle: Text('Progress is saved on this device only.'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: GradientButton(
              label: 'Sign in to sync',
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
          title: Text(user.email ?? 'Signed in'),
          subtitle: ValueListenableBuilder(
            valueListenable: sync.lastSynced,
            builder: (context, t, _) =>
                Text(t == null ? 'Not synced yet' : 'Last synced ${DateFormat.MMMd().add_jm().format(t)}'),
          ),
          trailing: ValueListenableBuilder(
            valueListenable: sync.status,
            builder: (context, st, _) => st == SyncStatus.syncing
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
                : IconButton(tooltip: 'Sync now', icon: const Icon(AppIcons.sync), onPressed: sync.sync),
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
        ListTile(
          leading: const Icon(AppIcons.signOut),
          title: const Text('Sign out'),
          subtitle: const Text('Removes this account\'s data from this device'),
          onTap: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Sign out?'),
                content: const Text('Your progress is backed up to your account. Changes not yet synced will be lost.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign out')),
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
