import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/app_route.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../shared/extensions/build_context_extensions.dart';
import '../../../../shared/presentation/widgets/app_state_views.dart';
import '../../../../shared/presentation/widgets/empty_state.dart';
import '../../../../shared/presentation/widgets/hero_app_bar_icon.dart';
import '../../../../shared/presentation/widgets/section_header.dart';
import '../../domain/home_content.dart';
import '../providers/home_content_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/home_menu_card.dart';
import '../widgets/progress_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(homeContentProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: content.when(
          data: (value) => _HomeDashboard(content: value),
          loading: () => const AppLoadingView(message: 'ホームを読み込み中'),
          error: (error, stackTrace) => AppErrorView(
            title: 'ホームを読み込めません',
            message: '$error',
            onRetry: () => ref.invalidate(homeContentProvider),
          ),
        ),
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard({required this.content});

  final HomeContent content;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'おはようございます';
    if (hour < 18) return 'こんにちは';
    return 'こんばんは';
  }

  @override
  Widget build(BuildContext context) {
    const menus = [
      _MenuData(Icons.history_edu_rounded, '過去問', '本番形式で演習', AppRoute.vocabulary),
      _MenuData(Icons.bolt_rounded, '一問一答', 'すきま時間に学習', AppRoute.grammar),
      _MenuData(Icons.grid_view_rounded, 'カテゴリ別', '苦手分野を集中対策', AppRoute.vocabulary),
      _MenuData(Icons.assignment_rounded, '模擬試験', '実力をチェック', AppRoute.grammar),
      _MenuData(Icons.favorite_rounded, 'お気に入り', '保存した問題', AppRoute.favorite),
      _MenuData(Icons.refresh_rounded, '間違えた問題', 'もう一度チャレンジ', AppRoute.vocabulary),
      _MenuData(Icons.insights_rounded, '学習履歴', '成長を振り返る', AppRoute.learningGoal),
    ];

    final solvedToday = content.recentHistory.length;
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          floating: true,
          snap: true,
          title: const Text('はりきゅうラボ'),
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: const Icon(Icons.spa_rounded, color: Colors.white),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => context.go(AppRoute.settings.path),
              tooltip: 'お知らせ',
              icon: const Icon(Icons.notifications_rounded),
            ),
            const SizedBox(width: 8),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 40),
          sliver: SliverList.list(
            children: [
              Text(
                _greeting,
                style: context.textStyles.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ).animate().fadeIn(duration: 220.ms, curve: Curves.easeOutCubic),
              const SizedBox(height: 6),
              Text(
                '今日も国家試験合格に向けて学習しましょう',
                style: context.textStyles.bodyMedium,
              ),
              const SizedBox(height: 28),
              const SectionHeader(title: '今日の学習'),
              const SizedBox(height: 12),
              DashboardCard(
                child: Column(
                  children: [
                    ProgressCard(solvedCount: solvedToday),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _StudyMetric(
                          icon: Icons.local_fire_department_rounded,
                          value: '${content.studyStatus.studyDays}日',
                          label: '連続学習',
                        ),
                        const _MetricDivider(),
                        _StudyMetric(
                          icon: Icons.task_alt_rounded,
                          value: '${content.studyStatus.progressPercent}%',
                          label: '正答率',
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(
                    delay: 40.ms,
                    duration: 220.ms,
                    curve: Curves.easeOutCubic,
                  ).slideY(begin: .08, curve: Curves.easeOutCubic),
              const SizedBox(height: 32),
              const SectionHeader(title: '学習メニュー'),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: menus.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 166,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final item = menus[index];
                  final hero = HeroIconData(
                    tag: 'home-menu-$index',
                    icon: item.icon,
                  );
                  return HomeMenuCard(
                    heroTag: hero.tag,
                    icon: item.icon,
                    title: item.title,
                    subtitle: item.subtitle,
                    onTap: () => context.go(item.route.path, extra: hero),
                  ).animate().fadeIn(
                        delay: (40 + index * 25).ms,
                        duration: 220.ms,
                        curve: Curves.easeOutCubic,
                      ).slideY(begin: .08, curve: Curves.easeOutCubic);
                },
              ),
              const SizedBox(height: 32),
              const SectionHeader(title: '最近の学習'),
              const SizedBox(height: 12),
              DashboardCard(
                padding: const EdgeInsets.all(10),
                child: content.recentHistory.isEmpty
                    ? EmptyState(
                        icon: Icons.auto_stories_rounded,
                        title: 'まだ学習履歴がありません',
                        message: '最初の問題に挑戦して、\n学習をスタートしましょう。',
                        action: FilledButton.icon(
                          onPressed: () => context.go(AppRoute.vocabulary.path),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('学習を始める'),
                        ),
                      )
                    : Column(
                        children: [
                          for (final item in content.recentHistory.take(3))
                            ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.surface,
                                child: Icon(
                                  Icons.auto_stories_rounded,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              title: Text(item.title.ja),
                              subtitle: Text(item.completedAtLabel),
                              trailing: Text('${item.accuracyPercent}%'),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StudyMetric extends StatelessWidget {
  const _StudyMetric({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: AppColors.textSecondary),
            const SizedBox(width: 9),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: context.textStyles.titleMedium),
                Text(
                  label,
                  style: context.textStyles.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      );
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 36,
        child: VerticalDivider(width: 24),
      );
}

class _MenuData {
  const _MenuData(this.icon, this.title, this.subtitle, this.route);

  final IconData icon;
  final String title;
  final String subtitle;
  final AppRoute route;
}
