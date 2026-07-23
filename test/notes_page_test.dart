import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_master/features/auth/domain/app_user.dart';
import 'package:jlpt_master/features/auth/presentation/providers/auth_providers.dart';
import 'package:jlpt_master/features/notes/presentation/pages/notes_page.dart';

const _limitMessage =
    '無料プランではメモは50文字までです。Proにアップグレードすると無制限で入力できます。';

void main() {
  Widget buildEditor({required String plan}) {
    return ProviderScope(
      overrides: [
        currentUserProvider.overrideWith(
          (ref) => Stream.value(
            AppUser(
              uid: 'user-id',
              displayName: 'User',
              email: 'user@example.com',
              plan: plan,
            ),
          ),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(body: MemoEditor(initialMemo: '')),
      ),
    );
  }

  testWidgets('free plan limits memo input to 50 characters', (tester) async {
    await tester.pumpWidget(buildEditor(plan: 'free'));
    await tester.pump();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.maxLength, 50);
    expect(find.text(_limitMessage), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'a' * 51);
    await tester.pump();

    expect(find.text('a' * 50), findsOneWidget);
    expect(find.text('50/50'), findsOneWidget);
  });

  testWidgets('pro plan does not set a memo character limit', (tester) async {
    await tester.pumpWidget(buildEditor(plan: 'pro'));
    await tester.pump();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.maxLength, isNull);
    expect(find.text(_limitMessage), findsNothing);

    await tester.enterText(find.byType(TextField), 'a' * 51);
    await tester.pump();

    expect(find.text('a' * 51), findsOneWidget);
    expect(find.text('51/50'), findsNothing);
  });
}
