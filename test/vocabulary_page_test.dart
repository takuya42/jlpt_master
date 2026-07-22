import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_master/features/vocabulary/data/mock_vocabulary_repository.dart';
import 'package:jlpt_master/features/vocabulary/presentation/pages/vocabulary_page.dart';
import 'package:jlpt_master/features/vocabulary/presentation/providers/vocabulary_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Vocabulary Quest header does not overflow on iPhone widths', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final size in <Size>[
      const Size(320, 568),
      const Size(375, 667),
      const Size(430, 932),
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vocabularyRepositoryProvider.overrideWithValue(
              MockVocabularyRepository(),
            ),
          ],
          child: const MaterialApp(home: VocabularyPage()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Vocabulary Quest'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'viewport: $size');
    }
  });

  testWidgets('shows onboarding once and persists its dismissal', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    Widget buildPage() => ProviderScope(
      overrides: [
        vocabularyRepositoryProvider.overrideWithValue(
          MockVocabularyRepository(),
        ),
      ],
      child: const MaterialApp(home: VocabularyPage()),
    );

    await tester.pumpWidget(buildPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('How to Study'), findsOneWidget);
    expect(find.text('Start Learning'), findsOneWidget);
    expect(
      find.text('Swipe right to move to the next card.'),
      findsOneWidget,
    );
    expect(find.text('右にスワイプして次のカードへ進みます。'), findsOneWidget);
    expect(find.byIcon(Icons.school), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    expect(find.textContaining('☝'), findsNothing);

    await tester.tap(find.text('Start Learning'));
    await tester.pumpAndSettle();
    expect(find.text('How to Study'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();
    expect(find.text('How to Study'), findsNothing);
  });
}
