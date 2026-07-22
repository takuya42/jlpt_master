import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_master/shared/presentation/widgets/memo_button.dart';

void main() {
  testWidgets('shows centered Memo text without an icon', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MemoButton(onPressed: () => pressed = true),
        ),
      ),
    );

    final button = find.byType(MemoButton);
    expect(find.descendant(of: button, matching: find.text('Memo')), findsOneWidget);
    expect(find.descendant(of: button, matching: find.byType(Icon)), findsNothing);
    expect(
      find.descendant(of: button, matching: find.byType(Center)),
      findsOneWidget,
    );

    await tester.tap(button);
    expect(pressed, isTrue);
  });
}
