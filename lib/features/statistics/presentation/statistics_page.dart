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
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  children: [
                    Text('Statistics（学習統計）', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 14),
                    _WeeklyBarChart(minutes: [18, 32, 24, 45, 28, 52, stats.studyTimeMinutes.clamp(0, 60).toInt()]),
                    const SizedBox(height: 14),
                    LayoutBuilder(builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 760 ? 3 : 1;
                      final cards = [
                        _Stat('Study Time', '学習時間', stats.formattedStudyTime, Icons.schedule_outlined),
                        _Stat('Correct Rate', '正答率', '${stats.mockExamAccuracy}%', Icons.insights_outlined),
                        _Stat('Study Streak', '連続学習日数', '${stats.favoriteWords}', Icons.local_fire_department_outlined),
                      ];
                      return GridView.count(
                        crossAxisCount: columns,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: columns == 1 ? 3.2 : 1.45,
                        children: [for (final stat in cards) _StatCard(stat: stat)],
                      );
                    }),
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

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({required this.minutes});

  final List<int> minutes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxValue = minutes.reduce((a, b) => a > b ? a : b).clamp(1, 999).toDouble();
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Study Time（週間学習時間）', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 18),
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < minutes.length; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: minutes[i] / maxValue,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const SizedBox(width: 18),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(labels[i], style: theme.textTheme.labelSmall),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
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
        padding: const EdgeInsets.all(18),
        child: Row(children: [
          Icon(stat.icon, color: theme.colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(stat.value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            Text('${stat.en}（${stat.ja}）', style: theme.textTheme.bodyMedium),
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
