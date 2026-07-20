import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_page.dart';
import '../../features/favorite/presentation/pages/favorite_page.dart';
import '../../features/grammar/presentation/pages/grammar_detail_page.dart';
import '../../features/grammar/presentation/pages/grammar_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/learning/presentation/pages/learning_goal_page.dart';
import '../../features/premium/presentation/pages/premium_page.dart';
import '../../features/remote_config/remote_config_repository.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/notes/presentation/pages/notes_page.dart';
import '../../features/shell/presentation/main_shell.dart';
import '../../features/vocabulary/presentation/pages/vocabulary_detail_page.dart';
import '../../features/vocabulary/presentation/pages/vocabulary_page.dart';
import 'app_route.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final premiumEnabled = ref.watch(premiumEnabledProvider);
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
            path: AppRoute.grammarDetail.path,
            builder: (context, state) => GrammarDetailPage(
              grammarId: state.pathParameters['grammarId'] ?? '',
            ),
          ),
          GoRoute(
            path: AppRoute.notes.path,
            builder: (context, state) => const NotesPage(),
          ),
          GoRoute(
            path: AppRoute.settings.path,
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: AppRoute.favorite.path,
            builder: (context, state) => const FavoritePage(),
          ),
          GoRoute(
            path: AppRoute.learningGoal.path,
            builder: (context, state) => const LearningGoalPage(),
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
        redirect: (context, state) =>
            premiumEnabled ? null : AppRoute.home.path,
        builder: (context, state) => const PremiumPage(),
      ),
    ],
  );
});
