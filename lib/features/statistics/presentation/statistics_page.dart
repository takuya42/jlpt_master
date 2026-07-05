import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/widgets/app_state_views.dart';

final statisticsProvider = StreamProvider<StudyStatistics>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(const StudyStatistics.empty());

  return FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots().map(
        (snapshot) => StudyStatistics.fromFirestore(snapshot.data()),
      );
});

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statistics = ref.watch(statisticsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: statistics.when(
              data: (data) => ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                children: [
                  Text(
                    'Statistics',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Firestoreの学習履歴から進捗を可視化します。', style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 20),
                  if (data.isEmpty)
                    const AppEmptyView(
                      icon: Icons.insights_outlined,
                      title: 'No statistics yet / 統計はまだありません',
                      message: '語彙学習や模擬試験を完了すると、ここに進捗が表示されます。',
                    )
                  else ...[
                    _StatisticsGrid(statistics: data),
                    const SizedBox(height: 16),
                    _WeeklyGoalCard(statistics: data),
                  ],
                ],
              ),
              error: (error, _) => AppErrorView(
                title: 'Could not load statistics',
                message: error.toString(),
                onRetry: () => ref.invalidate(statisticsProvider),
              ),
              loading: () => const AppLoadingView(message: 'Loading statistics / 統計を読み込み中'),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatisticsGrid extends StatelessWidget {
  const _StatisticsGrid({required this.statistics});

  final StudyStatistics statistics;

  @override
  Widget build(BuildContext context) {
    final items = [
      _Stat('Total study time', '学習時間合計', '${statistics.studyMinutes} min', Icons.schedule_outlined),
      _Stat('Completed lessons', '完了レッスン', '${statistics.completedLessons}', Icons.task_alt_outlined),
      _Stat('Favorite words', 'お気に入り単語', '${statistics.favoriteCount}', Icons.favorite_outline),
      _Stat('Mock exam accuracy', '模擬試験正答率', '${statistics.accuracyPercent}%', Icons.insights_outlined),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 2 : 1;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: columns == 1 ? 2.5 : 2.0,
          children: [for (final item in items) _StatCard(stat: item)],
        );
      },
    );
  }
}

class _WeeklyGoalCard extends StatelessWidget {
  const _WeeklyGoalCard({required this.statistics});

  final StudyStatistics statistics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly goal', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: statistics.goalProgress,
              minHeight: 12,
              borderRadius: BorderRadius.circular(99),
            ),
            const SizedBox(height: 8),
            Text('${(statistics.goalProgress * 100).round()}% complete / 週間目標 達成率'),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(radius: 28, child: Icon(stat.icon)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(stat.value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                  Text('${stat.en} / ${stat.ja}', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudyStatistics {
  const StudyStatistics({
    required this.studyMinutes,
    required this.completedLessons,
    required this.favoriteCount,
    required this.correctAnswers,
    required this.totalAnswers,
    required this.goalProgress,
  });

  const StudyStatistics.empty()
      : studyMinutes = 0,
        completedLessons = 0,
        favoriteCount = 0,
        correctAnswers = 0,
        totalAnswers = 0,
        goalProgress = 0;

  factory StudyStatistics.fromFirestore(Map<String, dynamic>? data) {
    final statistics = data?['statistics'] as Map<String, dynamic>? ?? const {};
    final correctAnswers = statistics['correctAnswers'] as int? ?? 0;
    final totalAnswers = statistics['totalAnswers'] as int? ?? 0;
    final weeklyGoalMinutes = statistics['weeklyGoalMinutes'] as int? ?? 150;
    final weeklyStudyMinutes = statistics['weeklyStudyMinutes'] as int? ?? 0;

    return StudyStatistics(
      studyMinutes: statistics['studyMinutes'] as int? ?? 0,
      completedLessons: statistics['completedLessons'] as int? ?? 0,
      favoriteCount: statistics['favoriteCount'] as int? ?? 0,
      correctAnswers: correctAnswers,
      totalAnswers: totalAnswers,
      goalProgress: weeklyGoalMinutes == 0 ? 0 : (weeklyStudyMinutes / weeklyGoalMinutes).clamp(0, 1).toDouble(),
    );
  }

  final int studyMinutes;
  final int completedLessons;
  final int favoriteCount;
  final int correctAnswers;
  final int totalAnswers;
  final double goalProgress;

  bool get isEmpty => studyMinutes == 0 && completedLessons == 0 && favoriteCount == 0 && totalAnswers == 0;

  int get accuracyPercent => totalAnswers == 0 ? 0 : ((correctAnswers / totalAnswers) * 100).round();
}

class _Stat {
  const _Stat(this.en, this.ja, this.value, this.icon);

  final String en;
  final String ja;
  final String value;
  final IconData icon;
}
