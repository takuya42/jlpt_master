import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_page.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/grammar/presentation/pages/grammar_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/premium/presentation/pages/premium_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/statistics/presentation/statistics_page.dart';
import '../../features/shell/presentation/main_shell.dart';
import '../../features/vocabulary/presentation/pages/vocabulary_detail_page.dart';
import '../../features/vocabulary/presentation/pages/vocabulary_page.dart';
import 'app_route.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  return GoRouter(
    initialLocation: AppRoute.home.path,
    redirect: (context, state) {
      final user = authState.asData?.value;
      final isAuthRoute = state.matchedLocation == AppRoute.login.path ||
          state.matchedLocation == AppRoute.emailLogin.path ||
          state.matchedLocation == AppRoute.register.path;
      if (authState.isLoading) return null;
      if (user == null && !isAuthRoute) return AppRoute.login.path;
      if (user != null && isAuthRoute) return AppRoute.home.path;
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoute.home.path,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoute.vocabulary.path,
            builder: (context, state) => const VocabularyPage(),
          ),
          GoRoute(
            path: AppRoute.vocabularyDetail.path,
            builder: (context, state) => VocabularyDetailPage(
              wordId: state.pathParameters['wordId'] ?? '',
            ),
          ),
          GoRoute(
            path: AppRoute.grammar.path,
            builder: (context, state) => const GrammarPage(),
          ),
          GoRoute(
            path: AppRoute.statistics.path,
            builder: (context, state) => const StatisticsPage(),
          ),
          GoRoute(
            path: AppRoute.settings.path,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoute.login.path,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoute.emailLogin.path,
        builder: (context, state) => const EmailLoginPage(),
      ),
      GoRoute(
        path: AppRoute.register.path,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoute.premium.path,
        builder: (context, state) => const PremiumPage(),
      ),
    ],
  );
});
