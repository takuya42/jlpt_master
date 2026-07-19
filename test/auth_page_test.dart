import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jlpt_master/app/navigation/app_route.dart';
import 'package:jlpt_master/app/theme/app_theme.dart';
import 'package:jlpt_master/features/auth/presentation/auth_page.dart';

void main() {
  testWidgets('email login back button pops when navigation history exists', (
    tester,
  ) async {
    final router = _router(initialLocation: AppRoute.home.path);
    addTearDown(router.dispose);

    await tester.pumpWidget(_TestApp(router: router));
    router.push(AppRoute.emailLogin.path);
    await tester.pumpAndSettle();

    final backIcon = find.byIcon(Icons.arrow_back_ios_new_rounded);
    final backButton = find.widgetWithIcon(
      IconButton,
      Icons.arrow_back_ios_new_rounded,
    );
    expect(backIcon, findsOneWidget);
    expect(tester.getSize(backButton).width, greaterThanOrEqualTo(44));
    expect(tester.getSize(backButton).height, greaterThanOrEqualTo(44));

    await tester.tap(backIcon);
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, AppRoute.home.path);
  });

  testWidgets('email login back button goes home without navigation history', (
    tester,
  ) async {
    final router = _router(initialLocation: AppRoute.emailLogin.path);
    addTearDown(router.dispose);

    await tester.pumpWidget(_TestApp(router: router, brightness: Brightness.dark));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, AppRoute.home.path);
  });
}

GoRouter _router({required String initialLocation}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(
      path: AppRoute.home.path,
      builder: (context, state) => const Scaffold(body: Text('Home')),
    ),
    GoRoute(
      path: AppRoute.emailLogin.path,
      builder: (context, state) => const EmailLoginPage(),
    ),
  ],
);

class _TestApp extends StatelessWidget {
  const _TestApp({required this.router, this.brightness = Brightness.light});

  final GoRouter router;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) => ProviderScope(
    child: MaterialApp.router(
      theme: brightness == Brightness.light ? AppTheme.light : AppTheme.dark,
      routerConfig: router,
    ),
  );
}
