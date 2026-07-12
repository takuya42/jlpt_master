import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../grammar/data/google_sheet_grammar_repository.dart';
import '../../../vocabulary/data/google_sheet_vocabulary_repository.dart';
import '../../data/user_learning_repository.dart';

const _jlptLevels = ['N5', 'N4', 'N3', 'N2', 'N1'];

final userLearningRepositoryProvider = Provider<UserLearningRepository>((ref) => UserLearningRepository());
final favoritesProvider = StreamProvider.family<Set<String>, String>((ref, type) {
  ref.watch(authStateProvider);
  return ref.watch(userLearningRepositoryProvider).watchFavoriteIds(type);
});
final learningQuestionTotalsProvider = FutureProvider<Map<String, int>>((ref) async {
  final totals = {for (final level in _jlptLevels) level: 0};

  final words = await GoogleSheetVocabularyRepository().fetchWords();
  for (final word in words) {
    totals[word.jlptLevel] = (totals[word.jlptLevel] ?? 0) + 1;
  }

  final patterns = await GoogleSheetGrammarRepository().fetchPatterns();
  for (final pattern in patterns) {
    totals[pattern.jlpt] = (totals[pattern.jlpt] ?? 0) + 1;
  }

  return totals;
});

final statisticsProvider = StreamProvider<LearningStatistics>((ref) {
  ref.watch(authStateProvider);
  final totals = ref.watch(learningQuestionTotalsProvider).asData?.value;
  if (totals == null) {
    return const Stream<LearningStatistics>.empty();
  }
  return ref.watch(userLearningRepositoryProvider).watchStatistics(totalQuestionsByLevel: totals);
});
final studyProgressProvider = statisticsProvider;

final favoriteEntriesProvider = StreamProvider<List<FavoriteEntry>>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(userLearningRepositoryProvider).watchFavorites();
});

final learningGoalProvider = StreamProvider<LearningGoal>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(userLearningRepositoryProvider).watchLearningGoal();
});
