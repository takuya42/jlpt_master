import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_master/app/app.dart';

void main() {
  testWidgets('shows initial home screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: JlptMasterApp()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to JLPT Master'), findsOneWidget);
    expect(find.text('JLPT Levels'), findsOneWidget);
    expect(find.text('Learning Menu'), findsOneWidget);
    expect(find.text('Vocabulary'), findsWidgets);
    expect(find.text('Today\'s Study Status'), findsOneWidget);
    expect(find.text('Recent History'), findsOneWidget);
  });
}
