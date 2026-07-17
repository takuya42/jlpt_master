import 'package:flutter/material.dart';

import 'vocabulary_card_theme.dart';

class AppTheme {
  const AppTheme._();

  static const accent = Color(0xFF7C8CFF);
  static const background = Color(0xFF0B1220);
  static const surface = Color(0xFF121826);
  static const subText = Color(0xFFAEB8CC);
  static const glass = Color(0x0DFFFFFF);
  static const glassBorder = Color(0x14FFFFFF);

  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
      surface: isDark ? background : const Color(0xFFF4F7FC),
    );
    final cardColors = VocabularyCardTheme.forBrightness(brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      extensions: [cardColors],
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: 'Roboto',
      textTheme: (isDark ? Typography.material2021().white : Typography.material2021().black).apply(
            bodyColor: colorScheme.onSurface,
            displayColor: colorScheme.onSurface,
          ).copyWith(
            bodyMedium: TextStyle(color: colorScheme.onSurfaceVariant),
            bodySmall: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.zero,
        color: isDark ? glass : colorScheme.surfaceContainerHighest,
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
        backgroundColor: WidgetStatePropertyAll(colorScheme.surfaceContainerHighest),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        textStyle: WidgetStatePropertyAll(TextStyle(color: colorScheme.onSurface)),
        hintStyle: WidgetStatePropertyAll(TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.45))),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: glassBorder))),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          backgroundColor: accent,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: isDark ? surface : colorScheme.surfaceContainer,
        indicatorColor: accent.withValues(alpha: 0.16),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(size: 23, color: states.contains(WidgetState.selected) ? colorScheme.primary : colorScheme.onSurfaceVariant)),
        labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant),
          backgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest),
          side: const WidgetStatePropertyAll(BorderSide(color: glassBorder)),
        ),
      ),
    );
  }
}
