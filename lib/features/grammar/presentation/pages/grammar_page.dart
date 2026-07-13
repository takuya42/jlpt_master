import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/widgets/app_state_views.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../../domain/grammar_pattern.dart';
import '../providers/grammar_providers.dart';

class GrammarPage extends ConsumerWidget {
  const GrammarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patterns = ref.watch(filteredGrammarPatternsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(actions: const [PremiumButton()]),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: CustomScrollView(
              slivers: [
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 18, 20, 12),
                  sliver: SliverToBoxAdapter(child: _GrammarHeader()),
                ),
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(child: _GrammarFilters()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  sliver: patterns.when(
                    data: (items) => items.isEmpty
                        ? const SliverFillRemaining(hasScrollBody: false, child: _EmptyGrammarView())
                        : SliverList.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) => _GrammarCard(pattern: items[index]),
                          ),
                    error: (error, stackTrace) => SliverFillRemaining(
                      hasScrollBody: false,
                      child: _GrammarErrorView(message: error.toString()),
                    ),
                    loading: () => const SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppLoadingView(message: 'Loading Grammar\n文法を読み込み中'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GrammarHeader extends StatelessWidget {
  const _GrammarHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.primaryContainer.withValues(alpha: 0.72),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.86), borderRadius: BorderRadius.circular(18)),
              child: Icon(Icons.subject_rounded, color: colorScheme.primary, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Grammar\n文法', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.05)),
                  const SizedBox(height: 6),
                  Text(
                    'Study Japanese grammar with examples.\n例文付きで文法を学びましょう。',
                    style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimaryContainer.withValues(alpha: 0.78), height: 1.25),
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

class _GrammarFilters extends ConsumerWidget {
  const _GrammarFilters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLevel = ref.watch(selectedGrammarJlptLevelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SearchBar(
          leading: const Icon(Icons.search, size: 22),
          trailing: [
            IconButton(tooltip: 'Filter / 絞り込み', onPressed: () {}, icon: const Icon(Icons.tune_rounded)),
          ],
          hintText: 'Search grammar / 文法を検索',
          onChanged: (value) => ref.read(grammarSearchQueryProvider.notifier).setQuery(value),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final level in grammarJlptLevels)
              FilterChip(
                label: Text(level),
                selected: selectedLevel == level,
                onSelected: (_) => ref.read(selectedGrammarJlptLevelProvider.notifier).selectLevel(level),
              ),
          ],
        ),
      ],
    );
  }
}

class _GrammarCard extends ConsumerWidget {
  const _GrammarCard({required this.pattern});

  final GrammarPattern pattern;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final favoriteIds = ref.watch(favoriteGrammarIdsProvider).asData?.value ?? <String>{};
    final studiedIds = ref.watch(studiedGrammarIdsProvider).asData?.value ?? <String>{};
    final isFavorite = favoriteIds.contains(pattern.id);
    final isStudied = studiedIds.contains(pattern.id);

    return Card(
      color: Colors.white,
      elevation: 1,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Badge(label: pattern.jlpt),
                const Spacer(),
                IconButton(
                  tooltip: isFavorite ? 'Favorite / お気に入り解除' : 'Favorite / お気に入り追加',
                  onPressed: () => toggleGrammarFavorite(ref, pattern),
                  icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? colorScheme.error : colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(pattern.grammar, textAlign: TextAlign.center, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(pattern.meaningEn, textAlign: TextAlign.center, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 3),
                  Text(pattern.meaningJa, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.7)),
            const SizedBox(height: 10),
            Text('Example', style: theme.textTheme.labelLarge?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Text(pattern.exampleJp, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('🇺🇸 ${pattern.exampleEn}', maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            Row(
              children: [
                if (isStudied)
                  _StudiedLabel()
                else
                  FilledButton.tonalIcon(
                    onPressed: () => recordGrammarStudy(ref, pattern),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Mark Studied'),
                  ),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('Learn')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w900)),
    );
  }
}

class _StudiedLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_rounded, size: 20, color: Colors.green.shade700),
        const SizedBox(width: 6),
        Text('Studied', style: theme.textTheme.labelLarge?.copyWith(color: Colors.green.shade700, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _EmptyGrammarView extends StatelessWidget {
  const _EmptyGrammarView();
  @override
  Widget build(BuildContext context) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.search_off_outlined, size: 56, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(height: 14),
        Text('No grammar found / 文法が見つかりません', style: Theme.of(context).textTheme.titleMedium),
      ]);
}

class _GrammarErrorView extends StatelessWidget {
  const _GrammarErrorView({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => AppErrorView(title: 'Could not load Grammar / 文法を読み込めません', message: message);
}
