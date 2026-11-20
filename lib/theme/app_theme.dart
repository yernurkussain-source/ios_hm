import 'package:flutter/material.dart';

const accent = Color(0xFFFF5A2C);

/// Stays dark in both themes (text on gold badges, dots over photos).
const inkFixed = Color(0xFF141416);

/// LAB 11: light and dark colour sets. Widgets read the active one with
/// `context.palette`, so the whole app switches when the theme changes.
class AppPalette extends ThemeExtension<AppPalette> {
  final Color ink;
  final Color canvas;
  final Color surface;
  final Color line;
  final Color muted;
  final Color neutralSoft;
  final Color accentSoft;
  final Color accentDeep;

  /// Background of the "hero" dark cards that carry white text.
  final Color inverse;

  const AppPalette({
    required this.ink,
    required this.canvas,
    required this.surface,
    required this.line,
    required this.muted,
    required this.neutralSoft,
    required this.accentSoft,
    required this.accentDeep,
    required this.inverse,
  });

  static const light = AppPalette(
    ink: Color(0xFF141416),
    canvas: Color(0xFFF4F3EF),
    surface: Colors.white,
    line: Color(0xFFE6E4DE),
    muted: Color(0xFF8D8B93),
    neutralSoft: Color(0xFFECEAE4),
    accentSoft: Color(0xFFFFECE5),
    accentDeep: Color(0xFFC23A12),
    inverse: Color(0xFF141416),
  );

  static const dark = AppPalette(
    ink: Color(0xFFF2F1ED),
    canvas: Color(0xFF0F0F11),
    surface: Color(0xFF1B1B1F),
    line: Color(0xFF2E2E33),
    muted: Color(0xFF9B99A2),
    neutralSoft: Color(0xFF28282D),
    accentSoft: Color(0xFF3B2119),
    accentDeep: Color(0xFFFF9472),
    inverse: Color(0xFF26262B),
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      ink: mix(ink, other.ink),
      canvas: mix(canvas, other.canvas),
      surface: mix(surface, other.surface),
      line: mix(line, other.line),
      muted: mix(muted, other.muted),
      neutralSoft: mix(neutralSoft, other.neutralSoft),
      accentSoft: mix(accentSoft, other.accentSoft),
      accentDeep: mix(accentDeep, other.accentDeep),
      inverse: mix(inverse, other.inverse),
    );
  }
}

extension AppPaletteX on BuildContext {
  /// Falls back to light so widgets also work under a plain MaterialApp.
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}

ThemeData buildAppTheme({bool dark = false}) {
  final p = dark ? AppPalette.dark : AppPalette.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: dark ? Brightness.dark : Brightness.light,
    primary: p.ink,
    onPrimary: p.canvas,
    secondary: accent,
    secondaryContainer: p.neutralSoft,
    onSecondaryContainer: p.ink,
    surface: p.canvas,
    onSurface: p.ink,
    error: accent,
  );
  const pill = StadiumBorder();

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    extensions: [p],
    scaffoldBackgroundColor: p.canvas,
    splashFactory: InkSparkle.splashFactory,
    dividerTheme: DividerThemeData(color: p.line, thickness: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: p.canvas,
      foregroundColor: p.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 64,
      titleSpacing: 20,
      titleTextStyle: TextStyle(
        color: p.ink,
        fontSize: 30,
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
      ),
    ),
    cardTheme: CardThemeData(
      color: p.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: p.surface,
      selectedColor: p.ink,
      side: BorderSide(color: p.line),
      shape: const StadiumBorder(),
      labelStyle: TextStyle(color: p.ink, fontWeight: FontWeight.w600),
      secondaryLabelStyle: TextStyle(color: p.canvas),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surface,
      hintStyle: TextStyle(color: p.muted),
      prefixIconColor: p.ink,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: p.ink, width: 1.4),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: pill,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.ink,
        minimumSize: const Size.fromHeight(48),
        side: BorderSide(color: p.line, width: 1.4),
        shape: pill,
      ),
    ),
    badgeTheme: const BadgeThemeData(backgroundColor: accent),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? p.canvas : p.muted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? p.ink : p.neutralSoft,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: p.surface,
      selectedItemColor: p.ink,
      unselectedItemColor: p.muted,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.inverse,
      contentTextStyle: const TextStyle(color: Colors.white),
      actionTextColor: accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
