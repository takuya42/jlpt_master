import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/study_stats/presentation/providers/study_stats_provider.dart';
import '../../data/home_repository.dart';
import '../../domain/home_content.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) => const MockHomeRepository());

final homeContentProvider = FutureProvider<HomeContent>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  final stats = ref.watch(studyStatsProvider).asData?.value;
  final content = await repository.fetchHomeContent();
  if (stats == null) return content;
  return HomeContent(
    levels: [
      for (final level in content.levels)
        JlptLevelCardData(
          level: level.level,
          title: level.title,
          description: level.description,
          progress: stats.progress,
        ),
    ],
    learningMenuItems: content.learningMenuItems,
    studyStatus: StudyStatusData(
      studyTimeLabel: stats.formattedStudyTime,
      studyDays: stats.learningDays,
      progressPercent: stats.progressPercent,
      goalProgress: stats.progress,
    ),
    recentHistory: content.recentHistory,
  );
});
