import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/presentation/widgets/app_state_views.dart';
import '../../domain/home_content.dart';
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
            title: 'Could not load home content（ホームを読み込めません）',
            message: error.toString(),
            onRetry: () => ref.invalidate(homeContentProvider),
          ),
          loading: () => const AppSkeletonListView(itemCount: 4),
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
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Text(
              'Home（ホーム）',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            _TodayGoalCard(status: content.studyStatus),
            const SizedBox(height: 14),
            _SectionHeader(title: 'Continue Learning', subtitle: '続きから学習'),
            const SizedBox(height: 10),
            for (final item in content.learningMenuItems) ...[
              _LearningMenuCard(item: item),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 4),
            const _SectionHeader(title: 'Recently Studied Words', subtitle: '最近学習した単語'),
            const SizedBox(height: 10),
            _RecentHistoryCard(items: content.recentHistory),
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
    return _RoundedCard(
      child: Row(
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: status.goalProgress,
                  strokeWidth: 9,
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  '${(status.goalProgress * 100).round()}%',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Today’s Goal（今日の目標）', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text('Study Time（学習時間） ${status.studyTimeMinutes} min', style: theme.textTheme.bodyMedium),
                Text('Correct Rate（正答率） ${status.accuracyPercent}%', style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text('$title（$subtitle）', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900));
  }
}

class _LearningMenuCard extends StatelessWidget {
  const _LearningMenuCard({required this.item});

  final LearningMenuItemData item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _RoundedCard(
      onTap: () => context.go(item.routePath),
      child: Row(
        children: [
          Icon(item.icon, color: theme.colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.title.en}（${item.title.ja}）', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text('${item.subtitle.en}（${item.subtitle.ja}）', style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _RecentHistoryCard extends StatelessWidget {
  const _RecentHistoryCard({required this.items});

  final List<StudyHistoryItemData> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const AppEmptyView(
        icon: Icons.history_rounded,
        title: 'No recent words（最近の単語はありません）',
        message: 'Start learning to see your history.（学習すると履歴が表示されます。）',
      );
    }
    return _RoundedCard(
      child: Column(
        children: [
          for (final item in items)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(item.icon, color: Theme.of(context).colorScheme.primary),
              title: Text('${item.title.en}（${item.title.ja}）'),
              subtitle: Text('${item.subtitle.en}（${item.subtitle.ja}）'),
              trailing: Text('${item.accuracyPercent}%'),
            ),
        ],
      ),
    );
  }
}

class _RoundedCard extends StatelessWidget {
  const _RoundedCard({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(padding: const EdgeInsets.all(18), child: child),
      ),
    );
  }
}
