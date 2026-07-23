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
      find.text('Swipe right to go to the next card.'),
      findsOneWidget,
    );
    expect(find.text('右にスワイプすると次のカードへ進みます。'), findsOneWidget);
    expect(find.textContaining('Check Answer'), findsNothing);
    expect(
      find.byKey(const ValueKey('tutorial-vocabulary-card')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.arrow_forward_rounded), findsNothing);
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

  testWidgets('study guide copy stays on one line across iPhone widths', (
    tester,
  ) async {
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
        const MaterialApp(home: Scaffold(body: VocabularyStudyDialog())),
      );
      await tester.pump();

      for (final key in const <String>[
        'study-guide-english',
        'study-guide-japanese',
      ]) {
        final paragraph = tester.renderObject<RenderParagraph>(
          find.byKey(ValueKey(key)),
        );
        expect(
          paragraph.textPainter.computeLineMetrics(),
          hasLength(1),
          reason: '$key should fit on one line at $size',
        );
      }
      expect(tester.takeException(), isNull, reason: 'viewport: $size');
    }
  });

  testWidgets('tutorial card demonstrates the swipe timing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: VocabularyStudyDialog())),
    );
    await tester.pump();

    final card = find.byKey(const ValueKey('tutorial-vocabulary-card'));
    final restingCenter = tester.getCenter(card);

    await tester.pump(const Duration(milliseconds: 400));
    final draggedCenter = tester.getCenter(card);
    expect(draggedCenter.dx - restingCenter.dx, closeTo(52, 0.1));

    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.getCenter(card).dx, closeTo(draggedCenter.dx, 0.1));

    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.getCenter(card).dx, closeTo(restingCenter.dx, 0.1));

    await tester.pump(const Duration(milliseconds: 900));
    expect(tester.getCenter(card).dx, closeTo(restingCenter.dx, 0.1));
  });

  testWidgets('tutorial card is excluded from semantics while animating', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: VocabularyStudyDialog())),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('勉強'), findsNothing);
    expect(find.bySemanticsLabel('study'), findsNothing);

    for (var frame = 0; frame < 10; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('study dialog closes from the Start Learning action', (
    tester,
  ) async {
    late BuildContext pageContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            pageContext = context;
            return const Scaffold();
          },
        ),
      ),
    );

    final result = showVocabularyStudyDialog(pageContext);
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey('vocabulary-study-dialog')),
      findsOneWidget,
    );

    await tester.tap(find.text('Start Learning'));
    await tester.pumpAndSettle();

    expect(await result, isTrue);
    expect(
      find.byKey(const ValueKey('vocabulary-study-dialog')),
      findsNothing,
    );
  });

  testWidgets('help action reopens the shared study dialog', (tester) async {
    SharedPreferences.setMockInitialValues({
      'hasSeenVocabularyOnboarding': true,
    });
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
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
    expect(find.text('How to Study'), findsNothing);
    await tester.tap(find.byTooltip('使い方'));
    await tester.pumpAndSettle();

    expect(find.text('How to Study'), findsOneWidget);
    expect(find.text('Start Learning'), findsOneWidget);

    await tester.tap(find.text('Start Learning'));
    await tester.pumpAndSettle();
    expect(find.text('How to Study'), findsNothing);

    await tester.tap(find.byTooltip('使い方'));
    await tester.pumpAndSettle();
    expect(find.text('How to Study'), findsOneWidget);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('hasSeenVocabularyOnboarding'), isTrue);
  });

  testWidgets('help action uses the root navigator from a nested navigator', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'hasSeenVocabularyOnboarding': true,
    });
    final nestedNavigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vocabularyRepositoryProvider.overrideWithValue(
            MockVocabularyRepository(),
          ),
        ],
        child: MaterialApp(
          home: Navigator(
            key: nestedNavigatorKey,
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (_) => const VocabularyPage(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('使い方'));
    await tester.pumpAndSettle();
    expect(find.text('How to Study'), findsOneWidget);

    await tester.tap(find.text('Start Learning'));
    await tester.pumpAndSettle();
    expect(find.text('How to Study'), findsNothing);
    expect(nestedNavigatorKey.currentState!.canPop(), isFalse);
  });

  testWidgets('barrier dismissal does not mark onboarding as seen', (
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

    await tester.tapAt(const Offset(5, 5));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(buildPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('How to Study'), findsOneWidget);
  });

  testWidgets('shows onboarding after navigating from Home to Study', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vocabularyRepositoryProvider.overrideWithValue(
            MockVocabularyRepository(),
          ),
        ],
        child: MaterialApp(
          routes: {
            '/study': (_) => const VocabularyPage(),
          },
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/study'),
                child: const Text('Study'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('How to Study'), findsNothing);
    await tester.tap(find.text('Study'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('How to Study'), findsOneWidget);
  });
}
