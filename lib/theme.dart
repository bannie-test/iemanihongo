import 'package:flutter/material.dart';

/// "Sakura" design tokens: rounded Japanese type, pink → peach accents,
/// pill buttons. Every colour has a light and a dark value.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.accent,
    required this.accentSoft,
    required this.onAccent,
    required this.surface2,
    required this.muted,
    required this.border,
    required this.good,
    required this.bad,
    required this.gradient,
    required this.heat,
  });

  final Color accent;
  final Color accentSoft;
  final Color onAccent;
  final Color surface2;
  final Color muted;
  final Color border;
  final Color good;
  final Color bad;
  final Gradient gradient;

  /// Calendar heat levels 0 (none) … 3 (goal smashed).
  final List<Color> heat;

  static const light = AppColors(
    accent: Color(0xFFE5527C),
    accentSoft: Color(0xFFFFE1E9),
    onAccent: Colors.white,
    surface2: Color(0xFFFFEDF0),
    muted: Color(0xFF8E7A80),
    border: Color(0xFFF6DDE3),
    good: Color(0xFF2FB37A),
    bad: Color(0xFFE5527C),
    gradient: LinearGradient(colors: [Color(0xFFF0628B), Color(0xFFFF9F5A)]),
    heat: [Color(0xFFFBE7EC), Color(0xFFF9B9CB), Color(0xFFF084A3), Color(0xFFE5527C)],
  );

  static const dark = AppColors(
    accent: Color(0xFFFF7FA3),
    accentSoft: Color(0xFF43242F),
    onAccent: Color(0xFF170F13),
    surface2: Color(0xFF30202A),
    muted: Color(0xFFB29AA4),
    border: Color(0xFF3A2630),
    good: Color(0xFF4CD49A),
    bad: Color(0xFFFF7FA3),
    gradient: LinearGradient(colors: [Color(0xFFFF7FA3), Color(0xFFFFB36B)]),
    heat: [Color(0xFF2E1F26), Color(0xFF5E2B3D), Color(0xFFA3456A), Color(0xFFFF7FA3)],
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(AppColors? other, double t) => t < 0.5 ? this : (other ?? this);
}

extension AppThemeX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
}

class AppTheme {
  static const font = 'ZenMaruGothic';
  static const radius = 24.0;

  static ThemeData light() => _build(
        brightness: Brightness.light,
        c: AppColors.light,
        bg: const Color(0xFFFFF6F7),
        surface: Colors.white,
        text: const Color(0xFF2B1F24),
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        c: AppColors.dark,
        bg: const Color(0xFF170F13),
        surface: const Color(0xFF24171D),
        text: const Color(0xFFF6E9EE),
      );

  static ThemeData _build({
    required Brightness brightness,
    required AppColors c,
    required Color bg,
    required Color surface,
    required Color text,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: c.onAccent,
      secondary: const Color(0xFFFF9F5A),
      onSecondary: Colors.white,
      error: brightness == Brightness.light ? const Color(0xFFD03050) : const Color(0xFFFF8A9A),
      onError: Colors.white,
      surface: surface,
      onSurface: text,
      surfaceContainerHighest: c.surface2,
      outline: c.border,
      outlineVariant: c.border,
      primaryContainer: c.accentSoft,
      onPrimaryContainer: c.accent,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      fontFamily: font,
      scaffoldBackgroundColor: bg,
      extensions: [c],
    );
    final tt = base.textTheme.apply(bodyColor: text, displayColor: text, fontFamily: font);
    return base.copyWith(
      textTheme: tt.copyWith(
        headlineMedium: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 26),
        headlineSmall: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 22),
        titleLarge: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 19),
        titleMedium: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
        bodyMedium: tt.bodyMedium?.copyWith(fontSize: 14.5, height: 1.5),
        bodySmall: tt.bodySmall?.copyWith(color: c.muted, fontSize: 12.5),
        labelLarge: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontFamily: font, fontSize: 20, fontWeight: FontWeight.w700, color: text),
        foregroundColor: text,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: c.border, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.accentSoft,
        height: 68,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: s.contains(WidgetState.selected) ? c.accent : c.muted),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontFamily: font,
            fontSize: 11.5,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: s.contains(WidgetState.selected) ? c.accent : c.muted,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontFamily: font, fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: const StadiumBorder(),
          side: BorderSide(color: c.border, width: 2),
          textStyle: const TextStyle(fontFamily: font, fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: c.border, width: 2)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: c.border, width: 2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: c.accent, width: 2)),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        backgroundColor: c.surface2,
        selectedColor: c.accent,
        labelStyle: TextStyle(fontFamily: font, fontWeight: FontWeight.w700, color: text),
        secondaryLabelStyle: TextStyle(fontFamily: font, fontWeight: FontWeight.w700, color: c.onAccent),
        checkmarkColor: c.onAccent,
      ),
      dividerTheme: DividerThemeData(color: c.border, space: 1, thickness: 1),
      listTileTheme: ListTileThemeData(iconColor: c.accent, contentPadding: const EdgeInsets.symmetric(horizontal: 16)),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.onAccent : null),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.accent : null),
      ),
    );
  }
}
