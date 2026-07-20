import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../favorites/presentation/providers/favorite_providers.dart';
import '../../../grammar/domain/grammar_pattern.dart';
import '../../../grammar/presentation/providers/grammar_providers.dart';
import '../../../vocabulary/domain/vocabulary_word.dart';
import '../../../vocabulary/presentation/providers/vocabulary_providers.dart';
import '../../../../shared/presentation/widgets/app_state_views.dart';

class FavoritePage extends ConsumerWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favorites / お気に入り'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Vocabulary'),
            Tab(text: 'Grammar'),
          ]),
        ),
        body: const SafeArea(
          child: TabBarView(children: [
            _VocabularyFavorites(),
            _GrammarFavorites(),
          ]),
        ),
      ),
    );
  }
}

class _VocabularyFavorites extends ConsumerWidget {
  const _VocabularyFavorites();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(favoriteVocabularyProvider);
    final words = ref.watch(vocabularyWordsProvider);
    return ids.when(
      loading: () => const AppLoadingView(message: 'Loading favorites'),
      error: (error, _) => AppErrorView(
        title: 'Could not load favorites',
        message: error.toString(),
        onRetry: () => ref.invalidate(favoriteVocabularyProvider),
      ),
      data: (favoriteIds) => words.when(
        loading: () => const AppLoadingView(message: 'Loading vocabulary'),
        error: (error, _) => AppErrorView(
          title: 'Could not load vocabulary',
          message: error.toString(),
          onRetry: () => ref.invalidate(vocabularyWordsProvider),
        ),
        data: (items) => _FavoriteList<VocabularyWord>(
          items: items.where((item) => favoriteIds.contains(item.id)).toList(),
          id: (item) => item.id,
          title: (item) => item.word,
          level: (item) => item.jlptLevel,
          onRemove: (item) => ref
              .read(favoriteVocabularyProvider.notifier)
              .remove(item.id),
        ),
      ),
    );
  }
}

class _GrammarFavorites extends ConsumerWidget {
  const _GrammarFavorites();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(favoriteGrammarProvider);
    final patterns = ref.watch(grammarPatternsProvider);
    return ids.when(
      loading: () => const AppLoadingView(message: 'Loading favorites'),
      error: (error, _) => AppErrorView(
        title: 'Could not load favorites',
        message: error.toString(),
        onRetry: () => ref.invalidate(favoriteGrammarProvider),
      ),
      data: (favoriteIds) => patterns.when(
        loading: () => const AppLoadingView(message: 'Loading grammar'),
        error: (error, _) => AppErrorView(
          title: 'Could not load grammar',
          message: error.toString(),
          onRetry: () => ref.invalidate(grammarPatternsProvider),
        ),
        data: (items) => _FavoriteList<GrammarPattern>(
          items: items.where((item) => favoriteIds.contains(item.id)).toList(),
          id: (item) => item.id,
          title: (item) => item.grammar,
          level: (item) => item.jlpt,
          onRemove: (item) =>
              ref.read(favoriteGrammarProvider.notifier).remove(item.id),
        ),
      ),
    );
  }
}

class _FavoriteList<T> extends StatelessWidget {
  const _FavoriteList({
    required this.items,
    required this.id,
    required this.title,
    required this.level,
    required this.onRemove,
  });

  final List<T> items;
  final String Function(T) id;
  final String Function(T) title;
  final String Function(T) level;
  final Future<void> Function(T) onRemove;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No favorites yet.\nお気に入りはまだありません。'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          key: ValueKey(id(item)),
          child: ListTile(
            title: Text(title(item),
                style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(level(item).trim().toUpperCase()),
            trailing: IconButton(
              tooltip: 'Remove favorite / お気に入り解除',
              color: Colors.red,
              onPressed: () => onRemove(item),
              icon: const Icon(Icons.favorite),
            ),
          ),
        );
      },
    );
  }
}
