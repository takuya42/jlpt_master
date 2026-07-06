import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/app_route.dart';
import '../../../../shared/presentation/widgets/app_state_views.dart';
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
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) => _VocabularyWordCard(word: items[index]),
                          ),
                    error: (error, stackTrace) => SliverFillRemaining(
                      hasScrollBody: false,
                      child: _VocabularyErrorView(message: error.toString()),
                    ),
                    loading: () => const SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppLoadingView(message: 'Loading vocabulary（単語を読み込み中）'),
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
        Text('Vocabulary（単語）', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text('Search vocabulary（単語検索）して、JLPTレベル別に学習しましょう。', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
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
          leading: const Icon(Icons.search, size: 22),
          hintText: 'Search vocabulary（単語検索）',
          onChanged: (value) => ref.read(vocabularySearchQueryProvider.notifier).setQuery(value),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<String>(
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStateProperty.all(const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              ),
              segments: [for (final level in jlptLevels) ButtonSegment(value: level, label: Text(level))],
              selected: {selectedLevel},
              onSelectionChanged: (selection) => ref.read(selectedJlptLevelProvider.notifier).selectLevel(selection.first),
            ),
          ),
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
        borderRadius: BorderRadius.circular(22),
        onTap: () => context.go(AppRoute.vocabularyDetailPath(word.id)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(word.word, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
                        const SizedBox(width: 8),
                        _Tag(label: word.jlptLevel),
                        const SizedBox(width: 6),
                        Flexible(child: _Tag(label: word.partOfSpeech)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(word.reading, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(word.meaning, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              IconButton(
                tooltip: word.isFavorite ? 'Favorite（お気に入り）解除' : 'Favorite（お気に入り）追加',
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
  const _Tag({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: theme.colorScheme.primaryContainer.withValues(alpha: .42), borderRadius: BorderRadius.circular(999)),
      child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w900)),
    );
  }
}

class _EmptyVocabularyView extends StatelessWidget {
  const _EmptyVocabularyView();
  @override
  Widget build(BuildContext context) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.search_off_outlined, size: 56, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(height: 14),
        Text('No vocabulary found（単語が見つかりません）', style: Theme.of(context).textTheme.titleMedium),
      ]);
}

class _VocabularyErrorView extends StatelessWidget {
  const _VocabularyErrorView({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => AppErrorView(title: 'Could not load vocabulary（単語を読み込めません）', message: message);
}
