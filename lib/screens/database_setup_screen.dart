import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../services/sync_service.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';

/// One-time Supabase setup: the project needs this app's tables before
/// anything can sync. The anon key cannot create tables, so the owner runs
/// the bundled SQL in the dashboard.
class DatabaseSetupScreen extends StatelessWidget {
  const DatabaseSetupScreen({super.key});

  static String get _projectRef => Uri.parse(AppConfig.supabaseUrl).host.split('.').first;
  static String get sqlEditorUrl => 'https://supabase.com/dashboard/project/$_projectRef/sql/new';

  Future<void> _copySql(BuildContext context) async {
    final sql = await rootBundle.loadString('supabase/schema.sql');
    await Clipboard.setData(ClipboardData(text: sql));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Setup SQL copied to the clipboard')));
    }
  }

  Future<void> _openEditor(BuildContext context) async {
    final ok = await launchUrl(Uri.parse(sqlEditorUrl), mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      await Clipboard.setData(ClipboardData(text: sqlEditorUrl));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied – open it in a browser')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final sync = state.sync;
    final c = context.colors;

    Widget step(int n, String title, String body, Widget? action) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SoftCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: c.accentSoft, shape: BoxShape.circle),
              child: Text('$n', style: context.text.titleMedium?.copyWith(color: c.accent)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.text.titleMedium),
                  const SizedBox(height: 4),
                  Text(body, style: context.text.bodyMedium),
                  if (action != null) ...[const SizedBox(height: 10), action],
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Set up database')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Text(
            'Your Supabase project needs this app\'s tables before your progress can sync. '
            'This is a one-time step for the project owner and takes about a minute. '
            'Until then everything keeps working and is saved on this phone.',
            style: context.text.bodyMedium,
          ),
          const SizedBox(height: 18),
          step(
            1,
            'Open the SQL editor',
            'Sign in to supabase.com and open a new query for your project. A computer is easiest.',
            OutlinedButton.icon(
              onPressed: () => _openEditor(context),
              icon: const Icon(AppIcons.next),
              label: const Text('Open SQL editor'),
            ),
          ),
          step(
            2,
            'Copy the setup SQL',
            'It creates the tables, the security rules (each account sees only its own data) and realtime sync. '
                'It is safe to run again later.',
            OutlinedButton.icon(
              onPressed: () => _copySql(context),
              icon: const Icon(AppIcons.addToList),
              label: const Text('Copy setup SQL'),
            ),
          ),
          step(
            3,
            'Paste and run',
            'Paste it into the editor and press Run. You should see "Success. No rows returned".',
            null,
          ),
          step(
            4,
            'Check again',
            'Come back here and tap the button. Your progress from this phone is uploaded right away.',
            sync == null
                ? null
                : ValueListenableBuilder(
                    valueListenable: sync.status,
                    builder: (context, s, _) => s == SyncStatus.syncing
                        ? const Center(child: CircularProgressIndicator())
                        : FilledButton.icon(
                            onPressed: sync.sync,
                            icon: const Icon(AppIcons.sync),
                            label: const Text('Check & sync now'),
                          ),
                  ),
          ),
          if (sync != null)
            ValueListenableBuilder(
              valueListenable: sync.needsDatabaseSetup,
              builder: (context, missing, _) => ValueListenableBuilder(
                valueListenable: sync.lastError,
                builder: (context, err, _) {
                  final ok = !missing && err == null && sync.lastSynced.value != null;
                  return Row(
                    children: [
                      Icon(ok ? AppIcons.checkCircle : AppIcons.warning, color: ok ? c.good : c.bad),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ok ? 'Database is ready and your progress is synced.' : (err ?? 'Not checked yet.'),
                          style: context.text.bodyMedium,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
