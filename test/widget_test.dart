import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_master/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('shows initial home screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: JlptMasterApp()));

    expect(find.text('JLPT Master'), findsOneWidget);
    expect(find.text('Start learning Japanese'), findsOneWidget);
    expect(find.text('Vocabulary'), findsWidgets);
  });
}
