import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/home_content.dart';
import '../../../../shared/presentation/widgets/app_state_views.dart';
import '../providers/home_content_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeContent = ref.watch(homeContentProvider);

    return Scaffold(
      body: SafeArea(
        child: homeContent.when(
          data: (content) => _HomeContentView(content: content),
          error: (error, stackTrace) => AppErrorView(
            title: 'ホームを読み込めません',
            message: error.toString(),
            onRetry: () => ref.invalidate(homeContentProvider),
          ),
          loading: () => const AppLoadingView(message: 'ホームを読み込み中'),
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
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            _TodayGoalCard(status: content.studyStatus),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Continue Learning',
              subtitle: '続きから学習',
              child: Column(
                children: [
                  for (final item in content.learningMenuItems.take(3))
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
            const SizedBox(height: 16),
            _SectionCard(
              title: '最近学習した単語',
              child: Column(
                children: [
                  for (final item in content.recentHistory)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Icon(item.icon)),
                      title: Text('${item.title.en}（${item.title.ja}）', maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text('${item.completedAtLabel}・正答率 ${item.accuracyPercent}%', maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: '学習進捗',
              child: Column(
                children: [
                  for (final level in content.levels)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(level.level, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                            const SizedBox(width: 10),
                            Expanded(child: Text(level.title.ja, maxLines: 1, overflow: TextOverflow.ellipsis)),
                            Text('${(level.progress * 100).round()}%'),
                          ]),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(value: level.progress, borderRadius: BorderRadius.circular(99)),
                        ],
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
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('今日の目標', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('${status.studyTimeMinutes}分 学習済み', style: theme.textTheme.titleMedium),
          const SizedBox(height: 14),
          LinearProgressIndicator(value: status.goalProgress, minHeight: 10, borderRadius: BorderRadius.circular(99)),
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 10, children: [
            Chip(label: Text('正答率 ${status.accuracyPercent}%')),
            Chip(label: Text('連続 ${status.studyDays}日')),
          ]),
        ]),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.subtitle});
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
          const SizedBox(height: 12),
          child,
        ]),
      ),
    );
  }
}
