import 'package:flutter/material.dart';

@immutable
class AppChromeTheme extends ThemeExtension<AppChromeTheme> {
  const AppChromeTheme({
    required this.appBarColor,
    required this.navigationBarColor,
    required this.backgroundGradient,
    required this.decorationColor,
  });

  static const light = AppChromeTheme(
    appBarColor: Color(0xFFE9EAF8),
    navigationBarColor: Color(0xFFE9EAF8),
    backgroundGradient: [Color(0xFFF7F6FC), Color(0xFFEEEFF8), Color(0xFFE7EAF4)],
    decorationColor: Color(0xFF59658A),
  );

  static const dark = AppChromeTheme(
    appBarColor: Color(0xFF121826),
    navigationBarColor: Color(0xFF121826),
    backgroundGradient: [Color(0xFF08111F), Color(0xFF10213A), Color(0xFF050A14)],
    decorationColor: Color(0xFFFFFFFF),
  );

  @override
  AppChromeTheme copyWith({
    Color? appBarColor,
    Color? navigationBarColor,
    List<Color>? backgroundGradient,
    Color? decorationColor,
  }) =>
      AppChromeTheme(
        appBarColor: appBarColor ?? this.appBarColor,
        navigationBarColor: navigationBarColor ?? this.navigationBarColor,
        backgroundGradient: backgroundGradient ?? this.backgroundGradient,
        decorationColor: decorationColor ?? this.decorationColor,
      );

  @override
  AppChromeTheme lerp(covariant AppChromeTheme? other, double t) {
    if (other == null) return this;
    return AppChromeTheme(
      appBarColor: Color.lerp(appBarColor, other.appBarColor, t)!,
      navigationBarColor: Color.lerp(navigationBarColor, other.navigationBarColor, t)!,
      backgroundGradient: List.generate(
        backgroundGradient.length,
        (index) => Color.lerp(backgroundGradient[index], other.backgroundGradient[index], t)!,
      ),
      decorationColor: Color.lerp(decorationColor, other.decorationColor, t)!,
    );
  }
}
