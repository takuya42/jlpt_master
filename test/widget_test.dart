import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_master/app/app.dart';

void main() {
  testWidgets('shows bilingual home screen without mock exam', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: JlptMasterApp()));
    await tester.pumpAndSettle();

    expect(find.text('Today\'s Goal\n今日の目標'), findsOneWidget);
    expect(find.text('Learning Progress'), findsOneWidget);
    expect(find.text('Continue Learning'), findsOneWidget);
    expect(find.text('Recently Studied'), findsOneWidget);
    expect(find.textContaining('Mock Exam'), findsNothing);
    expect(find.textContaining('模擬試験'), findsNothing);
  });
}
