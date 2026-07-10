import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/user_learning_repository.dart';

final userLearningRepositoryProvider = Provider<UserLearningRepository>((ref) => UserLearningRepository());
final favoritesProvider = StreamProvider.family<Set<String>, String>((ref, type) {
  ref.watch(authStateProvider);
  return ref.watch(userLearningRepositoryProvider).watchFavoriteIds(type);
});
final statisticsProvider = StreamProvider<LearningStatistics>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(userLearningRepositoryProvider).watchStatistics();
});
final studyProgressProvider = statisticsProvider;
