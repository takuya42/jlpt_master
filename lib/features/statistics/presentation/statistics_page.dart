import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/learning/data/user_learning_repository.dart';
import '../../../features/learning/presentation/providers/learning_providers.dart';
import '../../../shared/presentation/widgets/app_state_views.dart';
import '../../../shared/presentation/widgets/premium_button.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsProvider);
    return Scaffold(
      appBar: AppBar(actions: const [PremiumButton()]),
      body: SafeArea(
        child: stats.when(
          loading: () => const AppLoadingView(message: 'Loading Statistics\n学習記録を読み込み中'),
          error: (error, stackTrace) => AppErrorView(title: 'Statistics\n学習記録', message: error.toString(), onRetry: () => ref.invalidate(statisticsProvider)),
          data: (data) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: ListView(padding: const EdgeInsets.fromLTRB(24, 28, 24, 36), children: [
                Text('Statistics\n学習記録', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 20),
                Wrap(spacing: 14, runSpacing: 14, children: [
                  _StatCard(stat: _Stat('Total Study Count', '総学習数', '${data.totalStudyCount}', Icons.school_outlined)),
                  _StatCard(stat: _Stat('Learning Streak', '連続学習日数', '${data.learningStreakDays} days', Icons.local_fire_department_outlined)),
                  _StatCard(stat: _Stat('Accuracy', '正答率', '${data.accuracyPercent}%', Icons.insights_outlined)),
                  _StatCard(stat: _Stat('Vocabulary', '単語数', '${data.vocabularyCount}', Icons.menu_book_outlined)),
                  _StatCard(stat: _Stat('Grammar', '文法数', '${data.grammarCount}', Icons.subject_outlined)),
                  _StatCard(stat: _Stat('Study Time', '学習時間', '${data.studyTimeMinutes} min', Icons.timer_outlined)),
                ]),
                const SizedBox(height: 20),
                _LearningProgressList(stats: data),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget { const _StatCard({required this.stat}); final _Stat stat; @override Widget build(BuildContext context) { final theme = Theme.of(context); return SizedBox(width: 300, child: Card(child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [CircleAvatar(radius: 26, child: Icon(stat.icon)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(stat.value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)), Text(stat.en, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)), Text(stat.ja, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium)]))])))); }}
class _Stat { const _Stat(this.en, this.ja, this.value, this.icon); final String en, ja, value; final IconData icon; }


class _LearningProgressList extends StatelessWidget {
  const _LearningProgressList({required this.stats});

  final LearningStatistics stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Learning Progress\n学習進捗', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          for (final entry in stats.progressByLevel.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(entry.key, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(width: 10),
                  Expanded(child: Text('${stats.learnedQuestionsByLevel[entry.key] ?? 0} / ${stats.totalQuestionsByLevel[entry.key] ?? 0}')),
                  Text('${(entry.value * 100).round()}%'),
                ]),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: entry.value, borderRadius: BorderRadius.circular(99)),
              ]),
            ),
        ]),
      ),
    );
  }
}
