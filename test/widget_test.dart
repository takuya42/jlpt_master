import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_master/app/app.dart';

void main() {
  testWidgets('shows the redesigned study dashboard', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: JlptMasterApp()));
    await tester.pumpAndSettle();

    expect(find.text('はりきゅうラボ'), findsWidgets);
    expect(find.text('今日も国家試験合格に向けて学習しましょう'), findsOneWidget);
    expect(find.text('今日の学習'), findsOneWidget);
    expect(find.text('学習メニュー'), findsOneWidget);
    expect(find.text('過去問'), findsOneWidget);
    expect(find.text('一問一答'), findsOneWidget);
    expect(find.text('カテゴリ別'), findsOneWidget);
    expect(find.text('模擬試験'), findsOneWidget);
    expect(find.text('お気に入り'), findsOneWidget);
    expect(find.text('間違えた問題'), findsOneWidget);
    expect(find.text('学習履歴'), findsOneWidget);
  });
}
