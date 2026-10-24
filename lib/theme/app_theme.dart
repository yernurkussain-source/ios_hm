import 'package:flutter/material.dart';

const ink = Color(0xFF141416);
const canvas = Color(0xFFF4F3EF);
const surface = Colors.white;
const line = Color(0xFFE6E4DE);
const muted = Color(0xFF8D8B93);
const neutralSoft = Color(0xFFECEAE4);
const accent = Color(0xFFFF5A2C);
const accentSoft = Color(0xFFFFECE5);
const accentDeep = Color(0xFFC23A12);

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: accent,
    primary: ink,
    onPrimary: Colors.white,
    secondary: accent,
    secondaryContainer: neutralSoft,
    onSecondaryContainer: ink,
    surface: canvas,
    onSurface: ink,
    error: accent,
  );
  const pill = StadiumBorder();

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: canvas,
    splashFactory: InkSparkle.splashFactory,
    dividerTheme: const DividerThemeData(color: line, thickness: 1),
    appBarTheme: const AppBarTheme(
      backgroundColor: canvas,
      foregroundColor: ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 64,
      titleSpacing: 20,
      titleTextStyle: TextStyle(
        color: ink,
        fontSize: 30,
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: surface,
      selectedColor: ink,
      side: BorderSide(color: line),
      shape: StadiumBorder(),
      labelStyle: TextStyle(color: ink, fontWeight: FontWeight.w600),
      secondaryLabelStyle: TextStyle(color: Colors.white),
      showCheckmark: false,
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      hintStyle: const TextStyle(color: muted),
      prefixIconColor: ink,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: ink, width: 1.4),
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
        foregroundColor: ink,
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: line, width: 1.4),
        shape: pill,
      ),
    ),
    badgeTheme: const BadgeThemeData(backgroundColor: accent),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? surface : muted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? ink : neutralSoft,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: ink,
      unselectedItemColor: muted,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ink,
      actionTextColor: accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
