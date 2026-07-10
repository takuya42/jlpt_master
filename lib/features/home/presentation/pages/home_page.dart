import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
              icon: Icons.play_circle_outline_rounded,
              title: 'Continue Learning',
              subtitle: '学習を続ける',
              child: Column(
                children: [
                  for (final item in content.learningMenuItems)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Icon(item.icon)),
                      title: Text(item.title.en, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(item.title.ja, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.go(item.routePath),
                    ),
                ],
              ),
            ),
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
                      subtitle: Text('${item.title.ja}・${item.completedAtLabel}・Accuracy 正答率 ${item.accuracyPercent}%', maxLines: 1, overflow: TextOverflow.ellipsis),
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
            CircleAvatar(backgroundColor: theme.colorScheme.primaryContainer, child: const Icon(Icons.flag_outlined)),
            const SizedBox(width: 14),
            Expanded(child: Text('Today\'s Goal\n今日の目標', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900))),
          ]),
          const SizedBox(height: 18),
          Text('Study Time  学習時間', style: theme.textTheme.labelLarge),
          Text('${status.studyTimeMinutes} min', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          LinearProgressIndicator(value: status.goalProgress, minHeight: 10, borderRadius: BorderRadius.circular(99)),
          const SizedBox(height: 14),
          Wrap(spacing: 10, runSpacing: 10, children: [
            Chip(label: Text('Accuracy 正答率 ${status.accuracyPercent}%')),
            Chip(label: Text('Learning Days 学習日数 ${status.studyDays}')),
          ]),
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
