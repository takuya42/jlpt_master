import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_master/features/home/presentation/widgets/progress_card.dart';

void main() {
  testWidgets('shows remaining questions before reaching the daily goal', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ProgressCard(solvedCount: 6, dailyGoal: 10)),
      ),
    );

    expect(find.text('今日の目標'), findsOneWidget);
    expect(find.text('あと4問'), findsOneWidget);
    expect(find.text('6 / 10 問'), findsOneWidget);
  });

  testWidgets('celebrates reaching the daily goal', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ProgressCard(solvedCount: 10, dailyGoal: 10)),
      ),
    );

    expect(find.text('今日の目標達成！'), findsOneWidget);
    expect(find.textContaining('あと'), findsNothing);
  });
}
