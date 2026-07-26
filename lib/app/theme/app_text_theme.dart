import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextTheme {
  static TextTheme get light => Typography.material2021().black.copyWith(
        displaySmall: const TextStyle(fontSize: 36, height: 1.25, fontWeight: FontWeight.w900),
        headlineMedium: const TextStyle(fontSize: 28, height: 1.3, fontWeight: FontWeight.w700),
        headlineSmall: const TextStyle(fontSize: 22, height: 1.35, fontWeight: FontWeight.w700),
        titleLarge: const TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w700),
        titleMedium: const TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w700),
        bodyLarge: const TextStyle(fontSize: 16, height: 1.7, fontWeight: FontWeight.w400),
        bodyMedium: const TextStyle(fontSize: 14, height: 1.65, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
        labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      );
}
