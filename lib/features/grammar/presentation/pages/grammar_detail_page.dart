import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/app_route.dart';
import '../../../notes/presentation/pages/notes_page.dart';
import '../../domain/grammar_pattern.dart';
import '../providers/grammar_providers.dart';
import '../../../study_stats/presentation/providers/study_stats_provider.dart';
import '../widgets/grammar_studied_toggle.dart';

class GrammarDetailPage extends ConsumerStatefulWidget {
  const GrammarDetailPage({super.key, required this.grammarId});

  final String grammarId;

  @override
  ConsumerState<GrammarDetailPage> createState() => _GrammarDetailPageState();
}

class _GrammarDetailPageState extends ConsumerState<GrammarDetailPage> {
  late final DateTime _studyStartedAt;

  @override
  void initState() {
    super.initState();
    _studyStartedAt = DateTime.now();
  }

  @override
  void dispose() {
    unawaited(ref.read(studyStatsProvider.notifier).addStudyTime(DateTime.now().difference(_studyStartedAt)));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pattern = ref.watch(grammarPatternProvider(widget.grammarId));

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(AppRoute.grammar.path)),
        title: const Text('Grammar Detail\n文法詳細'),
      ),
      body: SafeArea(
        child: pattern.when(
          data: (data) => data == null
              ? const _GrammarNotFoundView()
              : _GrammarDetailContent(pattern: data),
          error: (error, stackTrace) => Center(
            child: Text('Could not load grammar detail. / 文法詳細を読み込めません。\n$error', textAlign: TextAlign.center),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _GrammarDetailContent extends ConsumerWidget {
  const _GrammarDetailContent({required this.pattern});

  final GrammarPattern pattern;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final favoriteIds = ref.watch(favoriteGrammarIdsProvider).asData?.value ?? <String>{};
    final isFavorite = favoriteIds.contains(pattern.id);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 840),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
              shadowColor: colorScheme.shadow.withValues(alpha: 0.14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final grammar = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Grammar',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              pattern.grammar,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Meaning',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(pattern.meaningEn, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(pattern.meaningJa, style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                          ],
                        );
                        final actions = _GrammarActions(
                          isFavorite: isFavorite,
                          onMemoPressed: () => showMemoBottomSheet(context),
                          onFavoritePressed: () => toggleGrammarFavorite(ref, pattern),
                        );

                        if (constraints.maxWidth < 500) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              grammar,
                              const SizedBox(height: 16),
                              Align(alignment: Alignment.centerRight, child: actions),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: grammar),
                            const SizedBox(width: 16),
                            actions,
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Chip(label: Text(pattern.jlpt)),
                        GrammarStudiedToggle(pattern: pattern),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Explanation',
              children: [
                Text(pattern.explanationEn, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 12),
                Text(pattern.explanationJa, style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Example',
              children: [
                Text('日本語', style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(pattern.exampleJp, style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                Text('English', style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(pattern.exampleEn, style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GrammarActions extends StatelessWidget {
  const _GrammarActions({
    required this.isFavorite,
    required this.onMemoPressed,
    required this.onFavoritePressed,
  });

  final bool isFavorite;
  final VoidCallback onMemoPressed;
  final VoidCallback onFavoritePressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton.tonal(
          onPressed: onMemoPressed,
          child: const Text('Memo'),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          tooltip: isFavorite ? 'Favorite / お気に入り解除' : 'Favorite / お気に入り追加',
          onPressed: onFavoritePressed,
          iconSize: 28,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(isFavorite),
              color: isFavorite ? Colors.red : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _GrammarNotFoundView extends StatelessWidget {
  const _GrammarNotFoundView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Grammar pattern not found. / 文法が見つかりません。'));
  }
}
