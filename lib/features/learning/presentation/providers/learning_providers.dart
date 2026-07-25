import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../grammar/data/google_sheet_grammar_repository.dart';
import '../../../vocabulary/data/google_sheet_vocabulary_repository.dart';
import '../../data/user_learning_repository.dart';

const _jlptLevels = ['N5', 'N4', 'N3', 'N2', 'N1'];

final userLearningRepositoryProvider = Provider<UserLearningRepository>((ref) => UserLearningRepository());
final _favoritesForUserProvider = StreamProvider.family<Set<String>, ({String uid, String type})>((ref, key) {
  return ref.watch(userLearningRepositoryProvider).watchFavoriteIds(key.uid, key.type);
});
final favoritesProvider = Provider.family<AsyncValue<Set<String>>, String>((ref, type) {
  final uid = ref.watch(activeUserIdProvider);
  if (uid == null) return const AsyncData(<String>{});
  return ref.watch(_favoritesForUserProvider((uid: uid, type: type)));
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

final _learningStatisticsForUserProvider = StreamProvider.family<LearningStatistics, String>((ref, uid) {
  final totals = ref.watch(learningQuestionTotalsProvider).asData?.value;
  if (totals == null) {
    return const Stream<LearningStatistics>.empty();
  }
  return ref.watch(userLearningRepositoryProvider).watchStatistics(uid, totalQuestionsByLevel: totals);
});
final learningStatisticsProvider = Provider<AsyncValue<LearningStatistics>>((ref) {
  final uid = ref.watch(activeUserIdProvider);
  if (uid == null) return AsyncData(LearningStatistics.empty());
  return ref.watch(_learningStatisticsForUserProvider(uid));
});
final studyProgressProvider = learningStatisticsProvider;

final _favoriteEntriesForUserProvider = StreamProvider.family<List<FavoriteEntry>, String>((ref, uid) =>
    ref.watch(userLearningRepositoryProvider).watchFavorites(uid));
final favoriteEntriesProvider = Provider<AsyncValue<List<FavoriteEntry>>>((ref) {
  final uid = ref.watch(activeUserIdProvider);
  if (uid == null) return const AsyncData(<FavoriteEntry>[]);
  return ref.watch(_favoriteEntriesForUserProvider(uid));
});

final _learningGoalForUserProvider = StreamProvider.family<LearningGoal, String>((ref, uid) =>
    ref.watch(userLearningRepositoryProvider).watchLearningGoal(uid));
final learningGoalProvider = Provider<AsyncValue<LearningGoal>>((ref) {
  final uid = ref.watch(activeUserIdProvider);
  if (uid == null) return AsyncData(LearningGoal.defaultGoal());
  return ref.watch(_learningGoalForUserProvider(uid));
});
