import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_master/app/app.dart';

void main() {
  testWidgets('shows bilingual home screen without mock exam', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: JlptMasterApp()));
    await tester.pumpAndSettle();

    expect(find.text('Today\'s Goal\n今日の目標'), findsOneWidget);
    expect(find.text('Learning Progress'), findsOneWidget);
    expect(find.text('学習進捗'), findsOneWidget);
    expect(find.text('学習時間'), findsOneWidget);
    expect(find.text('学習日数'), findsOneWidget);
    expect(find.text('進捗'), findsOneWidget);
    expect(find.text('0m'), findsOneWidget);
    expect(find.text('0 days'), findsOneWidget);
    expect(find.text('0%'), findsNWidgets(6));
    expect(find.text('No learning history yet.\n学習履歴はまだありません。'), findsOneWidget);
    expect(find.text('Continue Learning'), findsNothing);
    expect(find.text('Recently Studied'), findsOneWidget);
    expect(find.textContaining('Mock Exam'), findsNothing);
    expect(find.textContaining('模擬試験'), findsNothing);
  });
}
