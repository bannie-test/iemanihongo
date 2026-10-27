import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'data/content_repository.dart';
import 'data/local_db.dart';
import 'screens/auth_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/shell.dart';
import 'services/notification_service.dart';
import 'services/tts_service.dart';
import 'state/app_state.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SupabaseClient? supabase;
  try {
    // Restores a saved session from disk, so this works offline too.
    await Supabase.initialize(url: AppConfig.supabaseUrl, publishableKey: AppConfig.supabaseAnonKey);
    supabase = Supabase.instance.client;
  } catch (e) {
    debugPrint('Supabase unavailable, running local-only: $e');
  }

  final results = await Future.wait([ContentRepository.load(), LocalDb.open(), SharedPreferences.getInstance()]);
  final notifications = NotificationService();
  await notifications.init();

  final state = AppState(
    content: results[0] as ContentRepository,
    db: results[1] as LocalDb,
    prefs: results[2] as SharedPreferences,
    tts: TtsService(),
    notifications: notifications,
    supabase: supabase,
  );
  await state.init();

  runApp(ChangeNotifierProvider.value(value: state, child: const IemanihongoApp()));
}

class IemanihongoApp extends StatelessWidget {
  const IemanihongoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final Widget home = switch (state.authPhase) {
      AuthPhase.signedOut => const AuthScreen(),
      _ when !state.onboarded => const SetupScreen(),
      _ => const Shell(),
    };
    return MaterialApp(
      title: 'Iemanihongo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: state.settings.themeMode,
      home: home,
    );
  }
}
