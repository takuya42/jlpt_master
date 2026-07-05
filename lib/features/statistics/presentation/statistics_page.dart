import 'package:flutter/material.dart';

import '../data/firestore_learning_repository.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repository = FirestoreLearningRepository();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: StreamBuilder<LearningStats>(
              stream: repository.watchStats(),
              initialData: LearningStats.empty(),
              builder: (context, snapshot) {
                final stats = snapshot.data ?? LearningStats.empty();
                final cards = [
                  _Stat('Total study time', '学習時間合計', stats.formattedStudyTime, Icons.schedule_outlined),
                  _Stat('Completed lessons', '完了レッスン', '${stats.completedLessons}', Icons.task_alt_outlined),
                  _Stat('Favorite words', 'お気に入り単語', '${stats.favoriteWords}', Icons.favorite_outline),
                  _Stat('Mock exam accuracy', '模擬試験正答率', '${stats.mockExamAccuracy}%', Icons.insights_outlined),
                ];

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  children: [
                    Text(
                      'Statistics',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('学習履歴から進捗を可視化します。', style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 20),
                    LayoutBuilder(builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 760 ? 2 : 1;
                      return GridView.count(
                        crossAxisCount: columns,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: columns == 1 ? 2.5 : 2.0,
                        children: [for (final stat in cards) _StatCard(stat: stat)],
                      );
                    }),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Weekly goal', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: stats.weeklyGoalProgress,
                            minHeight: 12,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          const SizedBox(height: 8),
                          Text('${(stats.weeklyGoalProgress * 100).round()}% complete / 週間目標達成率'),
                        ]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
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
        child: Row(children: [
          CircleAvatar(radius: 28, child: Icon(stat.icon)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(stat.value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            Text('${stat.en} / ${stat.ja}', style: theme.textTheme.bodyMedium),
          ])),
        ]),
      ),
    );
  }
}

class _Stat {
  const _Stat(this.en, this.ja, this.value, this.icon);
  final String en;
  final String ja;
  final String value;
  final IconData icon;
}
