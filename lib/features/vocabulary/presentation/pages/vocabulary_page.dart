import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/app_route.dart';
import '../../domain/vocabulary_word.dart';
import '../providers/vocabulary_providers.dart';

class VocabularyPage extends ConsumerWidget {
  const VocabularyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final words = ref.watch(filteredVocabularyWordsProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: CustomScrollView(
              slivers: [
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                  sliver: SliverToBoxAdapter(child: _VocabularyHeader()),
                ),
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(child: _VocabularyFilters()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  sliver: words.when(
                    data: (items) => items.isEmpty
                        ? const SliverFillRemaining(
                            hasScrollBody: false,
                            child: _EmptyVocabularyView(),
                          )
                        : _VocabularyWordGrid(words: items),
                    error: (error, stackTrace) => SliverFillRemaining(
                      hasScrollBody: false,
                      child: _VocabularyErrorView(message: error.toString()),
                    ),
                    loading: () => const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
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
      children: [
        Text(
          'Vocabulary',
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          '単語を検索して、JLPTレベル別に学習しましょう。',
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
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
      children: [
        SearchBar(
          leading: const Icon(Icons.search),
          hintText: 'Search vocabulary / 単語を検索',
          onChanged: (value) {
            ref.read(vocabularySearchQueryProvider.notifier).update(value);
          },
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<String>(
            segments: [
              for (final level in jlptLevels)
                ButtonSegment(value: level, label: Text(level)),
            ],
            selected: {selectedLevel},
            onSelectionChanged: (selection) {
              ref.read(selectedJlptLevelProvider.notifier).select(selection.first);
            },
          ),
        ),
      ],
    );
  }
}

class _VocabularyWordGrid extends StatelessWidget {
  const _VocabularyWordGrid({required this.words});

  final List<VocabularyWord> words;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final crossAxisCount = width >= 1000
            ? 3
            : width >= 640
                ? 2
                : 1;

        return SliverGrid.builder(
          itemCount: words.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: crossAxisCount == 1 ? 2.65 : 1.7,
          ),
          itemBuilder: (context, index) => _VocabularyWordCard(word: words[index]),
        );
      },
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
      elevation: 2,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.go(AppRoute.vocabularyDetailPath(word.id)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          word.word,
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          word.reading,
                          style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: word.isFavorite ? 'Remove favorite' : 'Add favorite',
                    onPressed: () => toggleFavorite(ref, word),
                    icon: Icon(word.isFavorite ? Icons.favorite : Icons.favorite_border),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                word.meaning,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(word.partOfSpeech)),
                  Chip(label: Text(word.jlptLevel)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyVocabularyView extends StatelessWidget {
  const _EmptyVocabularyView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off_outlined, size: 64, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: 16),
        Text('No vocabulary found', style: theme.textTheme.titleLarge),
        const SizedBox(height: 6),
        Text('検索条件に一致する単語がありません。', style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _VocabularyErrorView extends StatelessWidget {
  const _VocabularyErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Could not load vocabulary.\n$message', textAlign: TextAlign.center),
    );
  }
}
