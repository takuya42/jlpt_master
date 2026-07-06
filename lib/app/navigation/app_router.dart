import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_page.dart';
import '../../features/grammar/presentation/pages/grammar_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/mock_exam/presentation/pages/mock_exam_page.dart';
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
            pageBuilder: (context, state) => _fadePage(state, const HomePage()),
          ),
          GoRoute(
            path: AppRoute.login.path,
            pageBuilder: (context, state) => _fadePage(state, const AuthPage()),
          ),
          GoRoute(
            path: AppRoute.vocabulary.path,
            pageBuilder: (context, state) => _fadePage(state, const VocabularyPage()),
          ),
          GoRoute(
            path: AppRoute.vocabularyDetail.path,
            pageBuilder: (context, state) => _fadePage(
              state,
              VocabularyDetailPage(wordId: state.pathParameters['wordId'] ?? ''),
            ),
          ),
          GoRoute(
            path: AppRoute.grammar.path,
            pageBuilder: (context, state) => _fadePage(state, const GrammarPage()),
          ),
          GoRoute(
            path: AppRoute.mockExam.path,
            pageBuilder: (context, state) => _fadePage(state, const MockExamPage()),
          ),
          GoRoute(
            path: AppRoute.statistics.path,
            pageBuilder: (context, state) => _fadePage(state, const StatisticsPage()),
          ),
          GoRoute(
            path: AppRoute.settings.path,
            pageBuilder: (context, state) => _fadePage(state, const SettingsPage()),
          ),
        ],
      ),
    ],
  );
});


CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}
