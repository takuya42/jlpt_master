import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/presentation/widgets/app_state_views.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../../domain/home_content.dart';
import '../providers/home_content_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeContent = ref.watch(homeContentProvider);

    return Scaffold(
      appBar: AppBar(actions: const [PremiumButton()]),
      body: SafeArea(
        child: homeContent.when(
          data: (content) => _HomeContentView(content: content),
          error: (error, stackTrace) => AppErrorView(
            title: 'Home\nホームを読み込めません',
            message: error.toString(),
            onRetry: () => ref.invalidate(homeContentProvider),
          ),
          loading: () => const AppLoadingView(message: 'Loading Home\nホームを読み込み中'),
        ),
      ),
    );
  }
}

class _HomeContentView extends StatelessWidget {
  const _HomeContentView({required this.content});

  final HomeContent content;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
          children: [
            _TodayGoalCard(status: content.studyStatus),
            const SizedBox(height: 18),
            _ProgressCard(levels: content.levels),
            const SizedBox(height: 18),
            _SectionCard(
              icon: Icons.history_rounded,
              title: 'Recently Studied',
              subtitle: '最近学習した単語',
              child: Column(
                children: [
                  for (final item in content.recentHistory)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Icon(item.icon)),
                      title: Text(item.title.en, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        '${item.title.ja}・${item.completedAtLabel}・Accuracy 正答率 ${item.accuracyPercent}%',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

class _TodayGoalCard extends StatelessWidget {
  const _TodayGoalCard({required this.status});
  final StudyStatusData status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: const Icon(Icons.flag_outlined),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Today\'s Goal\n今日の目標',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
          ]),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 12.0;
              final metricWidth = (constraints.maxWidth - spacing) / 2;

              return Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: metricWidth,
                        child: _GoalMetric(
                          icon: Icons.timer_outlined,
                          label: 'Study Time',
                          japaneseLabel: '学習時間',
                          value: '${status.studyTimeMinutes} min',
                        ),
                      ),
                      const SizedBox(width: spacing),
                      SizedBox(
                        width: metricWidth,
                        child: _GoalMetric(
                          icon: Icons.calendar_month_outlined,
                          label: 'Learning Days',
                          japaneseLabel: '学習日数',
                          value: '${status.studyDays} days',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: spacing),
                  SizedBox(
                    width: double.infinity,
                    child: _GoalMetric(
                      icon: Icons.insights_outlined,
                      label: 'Accuracy',
                      japaneseLabel: '正答率',
                      value: '${status.accuracyPercent}%',
                    ),
                  ),
                ],
              );
            },
          ),
        ]),
      ),
    );
  }
}

class _GoalMetric extends StatelessWidget {
  const _GoalMetric({
    required this.icon,
    required this.label,
    required this.japaneseLabel,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String japaneseLabel;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card.filled(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            japaneseLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ]),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.levels});
  final List<JlptLevelCardData> levels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _SectionCard(
      icon: Icons.trending_up_rounded,
      title: 'Learning Progress',
      subtitle: '学習進捗',
      child: Column(
        children: [
          for (final level in levels)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(level.level, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(width: 10),
                  Expanded(child: Text('${level.title.en} / ${level.title.ja}', maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Text('${(level.progress * 100).round()}%'),
                ]),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: level.progress, borderRadius: BorderRadius.circular(99)),
              ]),
            ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.icon, required this.title, required this.subtitle, required this.child});
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
          ]),
          const SizedBox(height: 2),
          Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 14),
          child,
        ]),
      ),
    );
  }
}
