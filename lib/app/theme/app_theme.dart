import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const accent = Color(0xFF7C8CFF);
  static const background = Color(0xFF0B1220);
  static const surface = Color(0xFF121826);
  static const subText = Color(0xFFAEB8CC);
  static const glass = Color(0x0DFFFFFF);
  static const glassBorder = Color(0x14FFFFFF);

  static ThemeData get light => _buildTheme();
  static ThemeData get dark => _buildTheme();

  static ThemeData _buildTheme() {
    const colorScheme = ColorScheme.dark(
      primary: accent,
      secondary: Color(0xFF9BE7FF),
      surface: background,
      onSurface: Colors.white,
      outline: glassBorder,
      outlineVariant: Color(0x228E99B3),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: 'Roboto',
      textTheme: Typography.material2021().white.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ).copyWith(
            bodyMedium: Typography.material2021().white.bodyMedium?.copyWith(color: subText),
            bodySmall: Typography.material2021().white.bodySmall?.copyWith(color: subText),
          ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.zero,
        color: glass,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: glassBorder),
        ),
      ),
      chipTheme: ChipThemeData(
        labelStyle: const TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 12),
        backgroundColor: accent.withValues(alpha: 0.14),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999), side: const BorderSide(color: glassBorder)),
      ),
      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(Colors.white.withValues(alpha: 0.05)),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        textStyle: const WidgetStatePropertyAll(TextStyle(color: Colors.white)),
        hintStyle: const WidgetStatePropertyAll(TextStyle(color: subText)),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: glassBorder))),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: surface,
        indicatorColor: accent.withValues(alpha: 0.16),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(size: 23, color: states.contains(WidgetState.selected) ? accent : const Color(0xFF8E99B3))),
        labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
      ),
      dividerTheme: const DividerThemeData(color: Color(0x228E99B3)),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.white : subText),
          backgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? accent.withValues(alpha: .22) : Colors.white.withValues(alpha: .04)),
          side: const WidgetStatePropertyAll(BorderSide(color: glassBorder)),
        ),
      ),
    );
  }
}
