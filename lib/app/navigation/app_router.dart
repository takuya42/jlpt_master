import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_page.dart';
import '../../features/favorite/presentation/pages/favorite_page.dart';
import '../../features/grammar/presentation/pages/grammar_detail_page.dart';
import '../../features/grammar/presentation/pages/grammar_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/learning/presentation/pages/learning_goal_page.dart';
import '../../features/notes/presentation/pages/notes_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/pro_plan_page.dart';
import '../../features/shell/presentation/main_shell.dart';
import '../../features/vocabulary/domain/vocabulary_word.dart';
import '../../features/vocabulary/presentation/pages/vocabulary_detail_page.dart';
import '../../features/vocabulary/presentation/pages/vocabulary_page.dart';
import '../../shared/presentation/widgets/hero_app_bar_icon.dart';
import 'app_route.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  CustomTransitionPage<void> page(GoRouterState state, Widget child) =>
      CustomTransitionPage<void>(
        key: state.pageKey,
        child: child,
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(begin: const Offset(.025, .02), end: Offset.zero)
                    .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                child: child,
              ),
            ),
      );
  return GoRouter(
    initialLocation: AppRoute.home.path,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoute.home.path,
            pageBuilder: (context, state) => page(state, const HomePage()),
          ),
          GoRoute(
            path: AppRoute.vocabulary.path,
            pageBuilder: (context, state) => page(
              state,
              VocabularyPage(hero: _heroFrom(state)),
            ),
          ),
          GoRoute(
            path: AppRoute.vocabularyDetail.path,
            builder: (context, state) => VocabularyDetailPage(
              wordId: state.pathParameters['wordId'] ?? '',
              word: state.extra is VocabularyWord
                  ? state.extra as VocabularyWord
                  : null,
            ),
          ),
          GoRoute(
            path: AppRoute.grammar.path,
            pageBuilder: (context, state) => page(
              state,
              GrammarPage(hero: _heroFrom(state)),
            ),
          ),
          GoRoute(
            path: AppRoute.grammarDetail.path,
            builder: (context, state) => GrammarDetailPage(
              grammarId: state.pathParameters['grammarId'] ?? '',
            ),
          ),
          GoRoute(
            path: AppRoute.notes.path,
            pageBuilder: (context, state) => page(state, const NotesPage()),
          ),
          GoRoute(
            path: AppRoute.settings.path,
            pageBuilder: (context, state) => page(state, const SettingsPage()),
          ),
          GoRoute(
            path: AppRoute.proPlan.path,
            builder: (context, state) => const ProPlanPage(),
          ),
          GoRoute(
            path: AppRoute.favorite.path,
            pageBuilder: (context, state) => page(
              state,
              FavoritePage(hero: _heroFrom(state)),
            ),
          ),
          GoRoute(
            path: AppRoute.learningGoal.path,
            pageBuilder: (context, state) => page(
              state,
              LearningGoalPage(hero: _heroFrom(state)),
            ),
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
    ],
  );
});

HeroIconData? _heroFrom(GoRouterState state) =>
    state.extra is HeroIconData ? state.extra as HeroIconData : null;
