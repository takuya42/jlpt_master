import 'package:flutter/material.dart';

/// Semantic colors for elevated, glass-like learning cards.
///
/// Despite the historical name, this extension is intentionally feature
/// agnostic so the same visual language can be reused by grammar, kanji and
/// mock-test cards.
@immutable
class VocabularyCardTheme extends ThemeExtension<VocabularyCardTheme> {
  const VocabularyCardTheme({
    required this.cardGradient,
    required this.backCardGradient,
    required this.decorationColor,
    required this.borderColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.inputFillColor,
    required this.inputBorderColor,
    required this.buttonGradient,
    required this.disabledButtonGradient,
    required this.buttonForegroundColor,
    required this.shadowColor,
    required this.highlightColor,
    required this.textShadow,
  });

  final List<Color> cardGradient;
  final List<Color> backCardGradient;
  final Color decorationColor;
  final Color borderColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color inputFillColor;
  final Color inputBorderColor;
  final List<Color> buttonGradient;
  final List<Color> disabledButtonGradient;
  final Color buttonForegroundColor;
  final Color shadowColor;
  final Color highlightColor;
  final List<Shadow> textShadow;

  static const light = VocabularyCardTheme(
    cardGradient: [Color(0xFFF8FAFC), Color(0xFFF1F5F9), Color(0xFFE8EEF7)],
    backCardGradient: [Color(0xFFF1F5F9), Color(0xFFE7ECF5)],
    decorationColor: Color(0x247C8CFF),
    borderColor: Color(0x99FFFFFF),
    primaryTextColor: Color(0xFF0F172A),
    secondaryTextColor: Color(0xFF334155),
    inputFillColor: Color(0xFFFDFEFF),
    inputBorderColor: Color(0xFF94A3B8),
    buttonGradient: [Color(0xFF334155), Color(0xFF4F46E5), Color(0xFF7C3AED)],
    disabledButtonGradient: [Color(0xFF64748B), Color(0xFF6B7280)],
    buttonForegroundColor: Color(0xFFFFFFFF),
    shadowColor: Color(0x40334155),
    highlightColor: Color(0x38FFFFFF),
    textShadow: [Shadow(color: Color(0x33FFFFFF), blurRadius: 3, offset: Offset(0, 1))],
  );

  static const dark = VocabularyCardTheme(
    cardGradient: [Color(0xEE182337), Color(0xEE151D2E), Color(0xEE211A38)],
    backCardGradient: [Color(0xCC1E293B), Color(0xCC29213E)],
    decorationColor: Color(0x247C8CFF),
    borderColor: Color(0x337C8CFF),
    primaryTextColor: Color(0xFFF8FAFC),
    secondaryTextColor: Color(0xFFD7DEEA),
    inputFillColor: Color(0xCC0F172A),
    inputBorderColor: Color(0xFF64748B),
    buttonGradient: [Color(0xFF4F46E5), Color(0xFF6D4AFF), Color(0xFF9333EA)],
    disabledButtonGradient: [Color(0xFF334155), Color(0xFF4C4268)],
    buttonForegroundColor: Color(0xFFFFFFFF),
    shadowColor: Color(0xB3000000),
    highlightColor: Color(0x14FFFFFF),
    textShadow: [Shadow(color: Color(0x99000000), blurRadius: 4, offset: Offset(0, 1))],
  );

  static VocabularyCardTheme forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  @override
  VocabularyCardTheme copyWith({
    List<Color>? cardGradient,
    List<Color>? backCardGradient,
    Color? decorationColor,
    Color? borderColor,
    Color? primaryTextColor,
    Color? secondaryTextColor,
    Color? inputFillColor,
    Color? inputBorderColor,
    List<Color>? buttonGradient,
    List<Color>? disabledButtonGradient,
    Color? buttonForegroundColor,
    Color? shadowColor,
    Color? highlightColor,
    List<Shadow>? textShadow,
  }) => VocabularyCardTheme(
    cardGradient: cardGradient ?? this.cardGradient,
    backCardGradient: backCardGradient ?? this.backCardGradient,
    decorationColor: decorationColor ?? this.decorationColor,
    borderColor: borderColor ?? this.borderColor,
    primaryTextColor: primaryTextColor ?? this.primaryTextColor,
    secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
    inputFillColor: inputFillColor ?? this.inputFillColor,
    inputBorderColor: inputBorderColor ?? this.inputBorderColor,
    buttonGradient: buttonGradient ?? this.buttonGradient,
    disabledButtonGradient: disabledButtonGradient ?? this.disabledButtonGradient,
    buttonForegroundColor: buttonForegroundColor ?? this.buttonForegroundColor,
    shadowColor: shadowColor ?? this.shadowColor,
    highlightColor: highlightColor ?? this.highlightColor,
    textShadow: textShadow ?? this.textShadow,
  );

  @override
  VocabularyCardTheme lerp(covariant VocabularyCardTheme? other, double t) {
    if (other == null) return this;
    List<Color> colors(List<Color> a, List<Color> b) => List.generate(
      a.length,
      (index) => Color.lerp(
        a[index],
        b[index >= b.length ? b.length - 1 : index],
        t,
      )!,
    );
    return VocabularyCardTheme(
      cardGradient: colors(cardGradient, other.cardGradient),
      backCardGradient: colors(backCardGradient, other.backCardGradient),
      decorationColor: Color.lerp(decorationColor, other.decorationColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      primaryTextColor: Color.lerp(primaryTextColor, other.primaryTextColor, t)!,
      secondaryTextColor: Color.lerp(secondaryTextColor, other.secondaryTextColor, t)!,
      inputFillColor: Color.lerp(inputFillColor, other.inputFillColor, t)!,
      inputBorderColor: Color.lerp(inputBorderColor, other.inputBorderColor, t)!,
      buttonGradient: colors(buttonGradient, other.buttonGradient),
      disabledButtonGradient: colors(disabledButtonGradient, other.disabledButtonGradient),
      buttonForegroundColor: Color.lerp(buttonForegroundColor, other.buttonForegroundColor, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      highlightColor: Color.lerp(highlightColor, other.highlightColor, t)!,
      textShadow: t < .5 ? textShadow : other.textShadow,
    );
  }
}
