import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_master/app/theme/app_theme.dart';
import 'package:jlpt_master/app/theme/vocabulary_card_theme.dart';

void main() {
  test('registers distinct vocabulary card themes for both brightnesses', () {
    final light = AppTheme.light;
    final dark = AppTheme.dark;

    expect(light.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);
    expect(light.extension<VocabularyCardTheme>(), VocabularyCardTheme.light);
    expect(dark.extension<VocabularyCardTheme>(), VocabularyCardTheme.dark);
  });

  test('card text colors have readable contrast against their surfaces', () {
    for (final cardTheme in [
      VocabularyCardTheme.light,
      VocabularyCardTheme.dark,
    ]) {
      final surface = cardTheme.cardGradient[1];
      expect(_contrast(cardTheme.primaryTextColor, surface), greaterThan(7));
      expect(_contrast(cardTheme.secondaryTextColor, surface), greaterThan(4.5));
      expect(
        _contrast(cardTheme.primaryTextColor, cardTheme.inputFillColor),
        greaterThan(7),
      );
    }
  });
}

double _contrast(Color foreground, Color background) {
  final lighter = [
    foreground.computeLuminance(),
    background.computeLuminance(),
  ]..sort();
  return (lighter.last + .05) / (lighter.first + .05);
}
