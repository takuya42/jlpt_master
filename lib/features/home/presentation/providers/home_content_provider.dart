import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/learning/presentation/providers/learning_providers.dart';
import '../../data/home_repository.dart';
import '../../domain/home_content.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) => const MockHomeRepository());

final homeContentProvider = FutureProvider<HomeContent>((ref) async {
  final content = await ref.watch(homeRepositoryProvider).fetchHomeContent();
  final stats = ref.watch(studyProgressProvider).valueOrNull;
  if (stats == null) return content;
  return HomeContent(
    levels: content.levels,
    learningMenuItems: content.learningMenuItems,
    studyStatus: StudyStatusData(
      studyTimeMinutes: stats.studyTimeMinutes,
      studyDays: stats.learningStreakDays,
      accuracyPercent: stats.accuracyPercent,
      goalProgress: (stats.totalStudyCount / 20).clamp(0, 1).toDouble(),
    ),
    recentHistory: content.recentHistory,
  );
});
