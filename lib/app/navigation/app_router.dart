import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_page.dart';
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
  return GoRouter(
    initialLocation: AppRoute.home.path,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoute.home.path,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoute.login.path,
            builder: (context, state) => const AuthPage(),
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
        path: AppRoute.premium.path,
        builder: (context, state) => const PremiumPage(),
      ),
    ],
  );
});
