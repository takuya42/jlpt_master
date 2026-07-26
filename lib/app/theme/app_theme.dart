import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_chrome_theme.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text_theme.dart';
import 'vocabulary_card_theme.dart';

abstract final class AppTheme {
  static const accent = AppColors.primary;

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: AppColors.primary,
      surface: dark ? const Color(0xFF111827) : AppColors.white,
    );
    final chrome = dark ? AppChromeTheme.dark : AppChromeTheme.light;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? const Color(0xFF0B1220) : AppColors.surface,
      fontFamily: 'Noto Sans JP',
      textTheme: dark ? Typography.material2021().white : AppTextTheme.light,
      extensions: [VocabularyCardTheme.forBrightness(brightness), chrome],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1.5,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        backgroundColor: chrome.appBarColor,
        foregroundColor: dark ? Colors.white : AppColors.textPrimary,
        systemOverlayStyle: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        color: dark ? const Color(0xFF182235) : AppColors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: .08),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.extraLarge),
          side: BorderSide(color: dark ? Colors.white10 : AppColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        minimumSize: const Size(48, 54),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      )),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: Colors.transparent,
        indicatorColor: AppColors.primary.withValues(alpha: .12),
        labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: Color(0xFFE9EEFF),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border),
    );
  }
}
