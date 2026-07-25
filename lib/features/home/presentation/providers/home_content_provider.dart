import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../features/learning/data/user_learning_repository.dart';
import '../../../../features/learning/presentation/providers/learning_providers.dart';
import '../../data/home_repository.dart';
import '../../domain/home_content.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) => const MockHomeRepository());

final _homeContentForUserProvider = FutureProvider.family<HomeContent, String?>((ref, uid) async {
  final repository = ref.watch(homeRepositoryProvider);
  final stats = uid == null ? null : ref.watch(learningStatisticsProvider).asData?.value;
  final content = await repository.fetchHomeContent();
  if (uid == null) return content;
  if (stats == null) return content;
  return HomeContent(
    levels: [
      for (final level in content.levels)
        JlptLevelCardData(
          level: level.level,
          title: level.title,
          description: level.description,
          progress: stats.progressByLevel[level.level] ?? 0,
        ),
    ],
    learningMenuItems: content.learningMenuItems,
    studyStatus: StudyStatusData(
      studyTimeLabel: _formatMinutes(stats.studyTimeMinutes),
      studyDays: stats.learningStreakDays,
      progressPercent: _overallProgress(stats),
      goalProgress: _overallProgress(stats) / 100,
    ),
    recentHistory: stats.recentActivities.map(_historyItem).toList(growable: false),
  );
});

final homeContentProvider = Provider<AsyncValue<HomeContent>>((ref) {
  final uid = ref.watch(activeUserIdProvider);
  return ref.watch(_homeContentForUserProvider(uid));
});

String _formatMinutes(int totalMinutes) {
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
  if (hours > 0) return '${hours}h';
  return '${minutes}m';
}

int _overallProgress(LearningStatistics stats) {
  final total = stats.totalQuestionsByLevel.values.fold<int>(0, (sum, value) => sum + value);
  final learned = stats.learnedQuestionsByLevel.values.fold<int>(0, (sum, value) => sum + value);
  return total == 0
      ? 0
      : ((learned / total) * 100).round().clamp(0, 100).toInt();
}

StudyHistoryItemData _historyItem(RecentActivityEntry entry) => StudyHistoryItemData(
      title: LocalizedText(en: entry.title, ja: entry.title),
      subtitle: LocalizedText(en: entry.type, ja: entry.type),
      completedAtLabel: _formatDate(entry.occurredAt),
      accuracyPercent: 0,
      icon: entry.type == 'vocabulary' ? Icons.menu_book_outlined : Icons.subject_outlined,
    );

String _formatDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
