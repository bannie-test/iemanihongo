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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã sao chép SQL thiết lập')));
    }
  }

  Future<void> _openEditor(BuildContext context) async {
    final ok = await launchUrl(Uri.parse(sqlEditorUrl), mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      await Clipboard.setData(ClipboardData(text: sqlEditorUrl));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã sao chép đường dẫn – hãy mở bằng trình duyệt')));
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
      appBar: AppBar(title: const Text('Thiết lập cơ sở dữ liệu')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Text(
            'Dự án Supabase của bạn cần có các bảng dữ liệu của app thì tiến độ mới đồng bộ được. '
            'Chủ dự án chỉ cần làm một lần, mất khoảng một phút. '
            'Trong lúc chờ, app vẫn hoạt động bình thường và lưu tiến độ trên điện thoại này.',
            style: context.text.bodyMedium,
          ),
          const SizedBox(height: 18),
          step(
            1,
            'Mở trình soạn SQL',
            'Đăng nhập supabase.com và mở một truy vấn mới cho dự án. Dùng máy tính sẽ dễ nhất.',
            OutlinedButton.icon(
              onPressed: () => _openEditor(context),
              icon: const Icon(AppIcons.next),
              label: const Text('Mở SQL Editor'),
            ),
          ),
          step(
            2,
            'Sao chép SQL thiết lập',
            'SQL này tạo các bảng, quy tắc bảo mật (mỗi tài khoản chỉ thấy dữ liệu của mình) và đồng bộ thời gian thực. '
                'Chạy lại sau này cũng an toàn.',
            OutlinedButton.icon(
              onPressed: () => _copySql(context),
              icon: const Icon(AppIcons.addToList),
              label: const Text('Sao chép SQL'),
            ),
          ),
          step(
            3,
            'Dán và chạy',
            'Dán vào trình soạn và nhấn Run. Bạn sẽ thấy "Success. No rows returned".',
            null,
          ),
          step(
            4,
            'Kiểm tra lại',
            'Quay lại đây và chạm nút bên dưới. Tiến độ trên điện thoại sẽ được tải lên ngay.',
            sync == null
                ? null
                : ValueListenableBuilder(
                    valueListenable: sync.status,
                    builder: (context, s, _) => s == SyncStatus.syncing
                        ? const Center(child: CircularProgressIndicator())
                        : FilledButton.icon(
                            onPressed: sync.sync,
                            icon: const Icon(AppIcons.sync),
                            label: const Text('Kiểm tra & đồng bộ'),
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
                          ok ? 'Cơ sở dữ liệu đã sẵn sàng và tiến độ đã được đồng bộ.' : (err ?? 'Chưa kiểm tra.'),
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
