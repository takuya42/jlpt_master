import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/app_route.dart';
import '../../../../shared/presentation/widgets/app_state_views.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../../domain/vocabulary_word.dart';
import '../providers/vocabulary_providers.dart';

class VocabularyPage extends ConsumerWidget {
  const VocabularyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final words = ref.watch(filteredVocabularyWordsProvider);

    return Scaffold(
      appBar: AppBar(actions: const [PremiumButton()]),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: CustomScrollView(
              slivers: [
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                  sliver: SliverToBoxAdapter(child: _VocabularyHeader()),
                ),
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(child: _VocabularyFilters()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  sliver: words.when(
                    data: (items) => items.isEmpty
                        ? const SliverFillRemaining(hasScrollBody: false, child: _EmptyVocabularyView())
                        : SliverList.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) => _VocabularyWordCard(word: items[index]),
                          ),
                    error: (error, stackTrace) => SliverFillRemaining(
                      hasScrollBody: false,
                      child: _VocabularyErrorView(message: error.toString()),
                    ),
                    loading: () => const SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppLoadingView(message: 'Loading Vocabulary\n単語を読み込み中'),
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

class _VocabularyHeader extends StatelessWidget {
  const _VocabularyHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Vocabulary\n単語', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text('Compare English and Japanese while reviewing by JLPT level.\n英語と日本語を見比べながら、JLPTレベル別に復習できます。', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _VocabularyFilters extends ConsumerWidget {
  const _VocabularyFilters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLevel = ref.watch(selectedJlptLevelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SearchBar(
          leading: const Icon(Icons.search, size: 22),
          trailing: [
            IconButton(
              tooltip: 'Filter / 絞り込み',
              onPressed: () {},
              icon: const Icon(Icons.tune_rounded),
            ),
          ],
          hintText: 'Search vocabulary / 単語を検索',
          onChanged: (value) => ref.read(vocabularySearchQueryProvider.notifier).setQuery(value),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final level in jlptLevels)
              FilterChip(
                label: Text(level),
                selected: selectedLevel == level,
                onSelected: (_) => ref.read(selectedJlptLevelProvider.notifier).selectLevel(level),
              ),
          ],
        ),
      ],
    );
  }
}

class _VocabularyWordCard extends ConsumerWidget {
  const _VocabularyWordCard({required this.word});

  final VocabularyWord word;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.go(AppRoute.vocabularyDetailPath(word.id)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      word.meaning,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      word.word,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(word.reading, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Tag(label: word.jlptLevel, brand: true),
                        _Tag(label: word.partOfSpeech),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: word.isFavorite ? 'Favorite / お気に入り解除' : 'Favorite / お気に入り追加',
                onPressed: () => toggleFavorite(ref, word),
                icon: Icon(word.isFavorite ? Icons.favorite : Icons.favorite_border, color: word.isFavorite ? colorScheme.error : colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.brand = false});
  final String label;
  final bool brand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = brand ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest;
    final foreground = brand ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelSmall?.copyWith(color: foreground, fontWeight: FontWeight.w900)),
    );
  }
}

class _EmptyVocabularyView extends StatelessWidget {
  const _EmptyVocabularyView();
  @override
  Widget build(BuildContext context) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.search_off_outlined, size: 56, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(height: 14),
        Text('No vocabulary found / 単語が見つかりません', style: Theme.of(context).textTheme.titleMedium),
      ]);
}

class _VocabularyErrorView extends StatelessWidget {
  const _VocabularyErrorView({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => AppErrorView(title: 'Could not load Vocabulary / 単語を読み込めません', message: message);
}
