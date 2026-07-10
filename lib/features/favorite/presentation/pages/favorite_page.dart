import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../learning/data/user_learning_repository.dart';
import '../../../learning/presentation/providers/learning_providers.dart';
import '../../../../shared/presentation/widgets/app_state_views.dart';

class FavoritePage extends ConsumerWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteEntriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite / お気に入り')),
      body: SafeArea(
        child: favorites.when(
          loading: () => const AppLoadingView(message: 'Loading favorites\nお気に入りを読み込み中'),
          error: (error, stackTrace) => AppErrorView(title: 'Favorite\nお気に入り', message: error.toString(), onRetry: () => ref.invalidate(favoriteEntriesProvider)),
          data: (items) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: items.isEmpty
                  ? const _EmptyFavorites()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
                      itemCount: items.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Text('Favorite\nお気に入り', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900));
                        }
                        return _FavoriteTile(entry: items[index - 1]);
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteTile extends ConsumerWidget {
  const _FavoriteTile({required this.entry});
  final FavoriteEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVocabulary = entry.type == 'vocabulary';
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(child: Icon(isVocabulary ? Icons.menu_book_outlined : Icons.subject_outlined)),
        title: Text(entry.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        subtitle: Text([
          isVocabulary ? 'Vocabulary / 単語' : 'Grammar / 文法',
          if (entry.jlptLevel != null) entry.jlptLevel!,
          if (entry.subtitle.isNotEmpty) entry.subtitle,
        ].join(' • ')),
        trailing: IconButton.filledTonal(
          tooltip: 'Remove favorite / お気に入り解除',
          onPressed: () => ref.read(userLearningRepositoryProvider).setFavorite(type: entry.type, itemId: entry.id, isFavorite: false),
          icon: const Icon(Icons.favorite),
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();
  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
        children: [
          Text('Favorite\nお気に入り', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          const Card(child: Padding(padding: EdgeInsets.all(24), child: Text('No favorites yet.\n単語・文法のお気に入りはまだありません。'))),
        ],
      );
}
