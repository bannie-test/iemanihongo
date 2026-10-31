import 'package:flutter/material.dart';

/// "Botanical" design tokens: cream paper, forest-green ink, sage panels,
/// clay accents, EB Garamond display type. Every colour has a light and a
/// dark value (the dark palette is a night-garden reading of the same
/// tokens).
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
    required this.clay,
    required this.warmField,
    required this.forest,
    required this.onForest,
    required this.fieldLine,
    required this.ornament,
  });

  /// Forest green: primary actions, progress fills, selected states.
  final Color accent;

  /// Sage panel.
  final Color accentSoft;
  final Color onAccent;

  /// Quiet track/fill behind progress and chips.
  final Color surface2;
  final Color muted;

  /// Rule: hairline borders and dividers.
  final Color border;
  final Color good;
  final Color bad;

  /// Botanical uses flat fields; kept as a gradient type for widgets that
  /// paint a fill.
  final Gradient gradient;

  /// Calendar heat levels 0 (none) … 3 (goal smashed).
  final List<Color> heat;

  /// Darker terracotta for small emphasis (italic words, highlights).
  final Color clay;

  /// Pale clay field.
  final Color warmField;

  /// Forest field behind cream text (numbered steps, closing areas).
  final Color forest;
  final Color onForest;

  /// Divider on forest fields.
  final Color fieldLine;

  /// Fine botanical line art and arch outlines.
  final Color ornament;

  static const _forest = Color(0xFF1E382C);
  static const _cream = Color(0xFFF5EFDF);

  static const light = AppColors(
    accent: _forest,
    accentSoft: Color(0xFFE0E5D3),
    onAccent: _cream,
    surface2: Color(0xFFEAE5D4),
    muted: Color(0xFF56655A),
    border: Color(0xFFD4D0BD),
    good: Color(0xFF3B7350),
    bad: Color(0xFFA4472F),
    gradient: LinearGradient(colors: [_forest, _forest]),
    heat: [Color(0xFFE6E0CD), Color(0xFFC8D2B5), Color(0xFF8EA486), _forest],
    clay: Color(0xFF895440),
    warmField: Color(0xFFE6CBB8),
    forest: _forest,
    onForest: _cream,
    fieldLine: Color(0xFF697961),
    ornament: Color(0xFFB5BAA4),
  );

  static const dark = AppColors(
    accent: Color(0xFFD3DEC2),
    accentSoft: Color(0xFF263F31),
    onAccent: Color(0xFF13211A),
    surface2: Color(0xFF21362A),
    muted: Color(0xFFA9B6A3),
    border: Color(0xFF2F4638),
    good: Color(0xFF93C9A0),
    bad: Color(0xFFE3957C),
    gradient: LinearGradient(colors: [Color(0xFFD3DEC2), Color(0xFFD3DEC2)]),
    heat: [Color(0xFF1F3227), Color(0xFF3A5644), Color(0xFF718F74), Color(0xFFD3DEC2)],
    clay: Color(0xFFDDA588),
    warmField: Color(0xFF3F2D25),
    forest: Color(0xFF223E30),
    onForest: _cream,
    fieldLine: Color(0xFF5E7462),
    ornament: Color(0xFF4F6453),
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
  /// EB Garamond for statements and headings ("Botanical Garamond").
  static const display = 'BotanicalGaramond';

  /// Reading text and controls ("Botanical Instrument"): Be Vietnam Pro,
  /// an Instrument-style grotesque with full Vietnamese support.
  static const font = 'BotanicalReading';
  static const fallback = ['JapaneseGothic'];
  static const displayFallback = ['JapaneseMincho'];

  /// Broad panel corners (--dp-radius-panel / -narrow).
  static const radius = 27.0;
  static const radiusWide = 34.0;
  static const controlRadius = 18.0;

  /// --dp-motion-interaction.
  static const motion = Duration(milliseconds: 350);

  /// Large Japanese text set in Mincho, matching the serif display face.
  static TextStyle jp(double size, {Color? color, double height = 1.25}) => TextStyle(
    fontFamily: 'JapaneseMincho',
    fontSize: size,
    fontWeight: FontWeight.w500,
    height: height,
    color: color,
  );

  /// Tracked uppercase sans label (--dp-typography-label).
  static TextStyle eyebrow(BuildContext context, {Color? color}) => TextStyle(
    fontFamily: font,
    fontFamilyFallback: fallback,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.44,
    color: color ?? context.colors.muted,
  );

  static ThemeData light() => _build(
    brightness: Brightness.light,
    c: AppColors.light,
    bg: const Color(0xFFF5EFDF),
    surface: const Color(0xFFFBF8EF),
    text: const Color(0xFF1E382C),
  );

  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    c: AppColors.dark,
    bg: const Color(0xFF13211A),
    surface: const Color(0xFF1A2B21),
    text: const Color(0xFFF0E9D8),
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
      secondary: c.clay,
      onSecondary: c.onForest,
      tertiary: c.accentSoft,
      error: c.bad,
      onError: c.onForest,
      surface: surface,
      onSurface: text,
      surfaceContainerHighest: c.surface2,
      surfaceContainerHigh: c.surface2,
      surfaceContainer: surface,
      surfaceContainerLow: surface,
      outline: c.border,
      outlineVariant: c.border,
      primaryContainer: c.accentSoft,
      onPrimaryContainer: text,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      fontFamily: font,
      fontFamilyFallback: fallback,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      splashFactory: InkSparkle.splashFactory,
      extensions: [c],
    );

    TextStyle serif(double size, {double ls = -0.3, double h = 1.12, FontWeight w = FontWeight.w400}) => TextStyle(
      fontFamily: display,
      fontFamilyFallback: displayFallback,
      fontSize: size,
      fontWeight: w,
      letterSpacing: ls,
      height: h,
      color: text,
    );
    TextStyle sans(double size, {FontWeight w = FontWeight.w400, double h = 1.5, Color? color}) => TextStyle(
      fontFamily: font,
      fontFamilyFallback: fallback,
      fontSize: size,
      fontWeight: w,
      height: h,
      color: color ?? text,
    );

    final tt = TextTheme(
      displayLarge: serif(64, ls: -1.8, h: 1.0),
      displayMedium: serif(52, ls: -1.4, h: 1.02),
      displaySmall: serif(44, ls: -1.1, h: 1.04),
      headlineLarge: serif(40, ls: -1.0, h: 1.05),
      headlineMedium: serif(34, ls: -0.8, h: 1.06),
      headlineSmall: serif(28, ls: -0.5, h: 1.1),
      titleLarge: serif(24, ls: -0.3, h: 1.15),
      titleMedium: serif(20, ls: -0.2, h: 1.2, w: FontWeight.w500),
      titleSmall: sans(14, w: FontWeight.w600, h: 1.35),
      bodyLarge: sans(16, h: 1.55),
      bodyMedium: sans(15, h: 1.5),
      bodySmall: sans(13, h: 1.45, color: c.muted),
      labelLarge: sans(15, w: FontWeight.w600, h: 1.2),
      labelMedium: sans(13, w: FontWeight.w500, h: 1.2),
      labelSmall: sans(12, w: FontWeight.w600, h: 1.2).copyWith(letterSpacing: 1.44),
    );

    final control = RoundedRectangleBorder(borderRadius: BorderRadius.circular(controlRadius));
    final hairline = BorderSide(color: c.border, width: 1);

    return base.copyWith(
      textTheme: tt,
      primaryTextTheme: tt,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: serif(26, ls: -0.5),
        foregroundColor: text,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius), side: hairline),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.accentSoft,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        height: 70,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: s.contains(WidgetState.selected) ? text : c.muted, size: 23),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => sans(
            12,
            w: s.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
            h: 1.2,
            color: s.contains(WidgetState.selected) ? text : c.muted,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: c.onAccent,
          minimumSize: const Size.fromHeight(52),
          shape: control,
          textStyle: sans(15, w: FontWeight.w600, h: 1.2),
          animationDuration: motion,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: c.accentSoft,
          foregroundColor: text,
          minimumSize: const Size.fromHeight(48),
          shape: control,
          side: BorderSide.none,
          textStyle: sans(15, w: FontWeight.w600, h: 1.2),
          animationDuration: motion,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: text,
          textStyle: sans(14, w: FontWeight.w600, h: 1.2).copyWith(decoration: TextDecoration.underline),
          shape: control,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(foregroundColor: text)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(controlRadius), borderSide: hairline),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(controlRadius), borderSide: hairline),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: c.accent, width: 1.6),
        ),
        labelStyle: sans(15, color: c.muted),
        hintStyle: sans(15, color: c.muted),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: hairline,
        backgroundColor: surface,
        selectedColor: c.accent,
        labelStyle: sans(14, w: FontWeight.w500, h: 1.2),
        secondaryLabelStyle: sans(14, w: FontWeight.w600, h: 1.2, color: c.onAccent),
        checkmarkColor: c.onAccent,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? c.accent : surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.onAccent : text),
          side: WidgetStatePropertyAll(hairline),
          textStyle: WidgetStatePropertyAll(sans(13, w: FontWeight.w600, h: 1.2)),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.border, space: 1, thickness: 1),
      listTileTheme: ListTileThemeData(
        iconColor: text,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        titleTextStyle: sans(15, w: FontWeight.w500, h: 1.35),
        subtitleTextStyle: sans(13, h: 1.4, color: c.muted),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        titleTextStyle: serif(26, ls: -0.4),
        contentTextStyle: sans(15),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: c.ornament,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(radiusWide))),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.forest,
        contentTextStyle: sans(14, color: c.onForest),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.accent, linearTrackColor: c.surface2),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.onAccent : c.muted),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.accent : c.surface2),
        trackOutlineColor: WidgetStatePropertyAll(c.border),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: text,
        unselectedLabelColor: c.muted,
        indicatorColor: c.clay,
        dividerColor: c.border,
        labelStyle: sans(14, w: FontWeight.w600, h: 1.2),
        unselectedLabelStyle: sans(14, w: FontWeight.w500, h: 1.2),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: c.forest, borderRadius: BorderRadius.circular(10)),
        textStyle: sans(12, color: c.onForest),
      ),
      expansionTileTheme: ExpansionTileThemeData(iconColor: text, collapsedIconColor: c.muted),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
