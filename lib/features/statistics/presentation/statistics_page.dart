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
                  _Stat('Total Study Time', '総学習時間', stats.formattedStudyTime, Icons.timer_outlined),
                  _Stat('Learning Streak', '連続学習日数', '${stats.learningStreakDays} days', Icons.local_fire_department_outlined),
                  _Stat('Accuracy', '正答率', '${stats.accuracyPercent}%', Icons.insights_outlined),
                ];

                return ListView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
                  children: [
                    Text('Statistics\n学習記録', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Weekly Study Time', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                          Text('週間学習時間', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 20),
                          _WeeklyBarChart(progress: stats.weeklyGoalProgress),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(spacing: 14, runSpacing: 14, children: [for (final stat in cards) _StatCard(stat: stat)]),
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
  const _WeeklyBarChart({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final values = [0.35, 0.55, 0.42, progress.clamp(0.1, 1.0).toDouble(), 0.68, 0.48, 0.76];
    final labels = ['Mon\n月', 'Tue\n火', 'Wed\n水', 'Thu\n木', 'Fri\n金', 'Sat\n土', 'Sun\n日'];
    return SizedBox(
      height: 190,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (var i = 0; i < values.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Flexible(
                  child: FractionallySizedBox(
                    heightFactor: values[i],
                    alignment: Alignment.bottomCenter,
                    child: Container(decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(999))),
                  ),
                ),
                const SizedBox(height: 8),
                Text(labels[i], textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall),
              ]),
            ),
          ),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});
  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 300,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            CircleAvatar(radius: 26, child: Icon(stat.icon)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(stat.value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
              Text(stat.en, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
              Text(stat.ja, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium),
            ])),
          ]),
        ),
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
