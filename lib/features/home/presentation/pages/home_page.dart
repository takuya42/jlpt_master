import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
          error: (error, stackTrace) => _HomeErrorView(message: error.toString()),
          loading: () => const Center(child: CircularProgressIndicator()),
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
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width >= 1200
        ? 40.0
        : width >= 600
            ? 32.0
            : 20.0;
    final maxContentWidth = width >= 1200 ? 1180.0 : double.infinity;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                32,
              ),
              sliver: SliverList.list(
                children: [
                  const _HeroCard(),
                  const SizedBox(height: 28),
                  _SectionHeader(title: 'JLPT Levels', subtitle: 'レベルを選択'),
                  const SizedBox(height: 12),
                  _ResponsiveGrid(
                    minTileWidth: 190,
                    children: [
                      for (final level in content.levels) _LevelCard(level: level),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _SectionHeader(title: 'Learning Menu', subtitle: '学習メニュー'),
                  const SizedBox(height: 12),
                  _ResponsiveGrid(
                    minTileWidth: 220,
                    children: [
                      for (final item in content.learningMenuItems)
                        _LearningMenuCard(item: item),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _ResponsiveTwoColumn(
                    left: _StudyStatusCard(status: content.studyStatus),
                    right: _RecentHistoryCard(items: content.recentHistory),
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

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 3,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.18),
      color: colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to JLPT Master',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Study Japanese step by step. / 日本語を一歩ずつ学びましょう。',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer.withValues(alpha: 0.78),
                    ),
                  ),
                ],
              ),
            ),
            if (MediaQuery.sizeOf(context).width >= 700) ...[
              const SizedBox(width: 24),
              CircleAvatar(
                radius: 46,
                backgroundColor: colorScheme.primary,
                child: Icon(
                  Icons.school_outlined,
                  size: 48,
                  color: colorScheme.onPrimary,
                ),
              ),
            ],
          ],
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.level});

  final JlptLevelCardData level;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            level.level,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${level.title.en} / ${level.title.ja}',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '${level.description.en}\n${level.description.ja}',
            style: theme.textTheme.bodyMedium,
          ),
          const Spacer(),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: level.progress,
            borderRadius: BorderRadius.circular(99),
          ),
        ],
      ),
    );
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
          CircleAvatar(child: Icon(item.icon)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title.en,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.title.ja} • ${item.subtitle.en} / ${item.subtitle.ja}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudyStatusCard extends StatelessWidget {
  const _StudyStatusCard({required this.status});

  final StudyStatusData status;

  @override
  Widget build(BuildContext context) {
    return _RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Today\'s Study Status',
            subtitle: '今日の学習状況',
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(
            value: status.goalProgress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(99),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricChip(
                icon: Icons.schedule_outlined,
                label: 'Study Time\n学習時間',
                value: '${status.studyTimeMinutes} min',
              ),
              _MetricChip(
                icon: Icons.local_fire_department_outlined,
                label: 'Study Days\n学習日数',
                value: '${status.studyDays} days',
              ),
              _MetricChip(
                icon: Icons.check_circle_outline,
                label: 'Accuracy\n正答率',
                value: '${status.accuracyPercent}%',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(label, style: theme.textTheme.bodySmall),
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
    return _RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Recent History', subtitle: '最近の学習履歴'),
          const SizedBox(height: 12),
          for (final item in items)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(item.icon)),
              title: Text('${item.title.en} / ${item.title.ja}'),
              subtitle: Text('${item.subtitle.en} / ${item.subtitle.ja}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(item.completedAtLabel),
                  Text('${item.accuracyPercent}%'),
                ],
              ),
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
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(padding: const EdgeInsets.all(20), child: child),
      ),
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({required this.children, required this.minTileWidth});

  final List<Widget> children;
  final double minTileWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / minTileWidth).floor().clamp(1, 5);
        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: count == 1 ? 1.45 : 1.05,
          children: children,
        );
      },
    );
  }
}

class _ResponsiveTwoColumn extends StatelessWidget {
  const _ResponsiveTwoColumn({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 860) {
          return Column(children: [left, const SizedBox(height: 12), right]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 12),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}

class _HomeErrorView extends StatelessWidget {
  const _HomeErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Could not load home content.\n$message', textAlign: TextAlign.center));
  }
}
