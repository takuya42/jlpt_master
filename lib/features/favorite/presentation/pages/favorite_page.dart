import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/app_route.dart';
import '../../../../shared/presentation/widgets/app_background.dart';
import '../../../../shared/presentation/widgets/app_state_views.dart';
import '../../../favorites/presentation/providers/favorite_providers.dart';
import '../../../grammar/domain/grammar_pattern.dart';
import '../../../grammar/presentation/providers/grammar_providers.dart';

const _favoriteLevels = ['ALL', 'N5', 'N4', 'N3', 'N2', 'N1'];

/// Displays grammar favorites saved with their globally unique JLPT/id key.
class FavoritePage extends ConsumerStatefulWidget {
  const FavoritePage({super.key});

  @override
  ConsumerState<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends ConsumerState<FavoritePage> {
  String _selectedLevel = 'ALL';

  @override
  Widget build(BuildContext context) {
    final favoriteIds = ref.watch(favoriteGrammarProvider);
    final patterns = ref.watch(grammarPatternsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Grammar Favorites\n文法のお気に入り')),
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: _favoriteLevels.map((level) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(level),
                            selected: _selectedLevel == level,
                            showCheckmark: false,
                            onSelected: (_) =>
                                setState(() => _selectedLevel = level),
                          ),
                        );
                      }).toList(growable: false),
                    ),
                  ),
                  Expanded(
                    child: favoriteIds.when(
                      loading: () => const AppLoadingView(
                        message: 'Loading favorites',
                      ),
                      error: (error, _) => AppErrorView(
                        title: 'Could not load favorites',
                        message: error.toString(),
                        onRetry: () => ref.invalidate(favoriteGrammarProvider),
                      ),
                      data: (ids) => patterns.when(
                        loading: () => const AppLoadingView(
                          message: 'Loading grammar',
                        ),
                        error: (error, _) => AppErrorView(
                          title: 'Could not load grammar',
                          message: error.toString(),
                          onRetry: () => ref.invalidate(grammarPatternsProvider),
                        ),
                        data: (items) => _GrammarFavoriteList(
                          items: items.where((pattern) {
                            return ids.contains(pattern.id) &&
                                (_selectedLevel == 'ALL' ||
                                    pattern.jlpt.toUpperCase() ==
                                        _selectedLevel);
                          }).toList(growable: false),
                          onRemove: (pattern) => ref
                              .read(favoriteGrammarProvider.notifier)
                              .remove(pattern.id),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GrammarFavoriteList extends StatelessWidget {
  const _GrammarFavoriteList({required this.items, required this.onRemove});

  final List<GrammarPattern> items;
  final Future<void> Function(GrammarPattern) onRemove;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No grammar favorites yet.\n文法のお気に入りはまだありません。',
          textAlign: TextAlign.center,
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final pattern = items[index];
        return Card(
          key: ValueKey(pattern.id),
          color: colorScheme.surfaceContainerHigh,
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
            onTap: () => context.push(
              AppRoute.grammarDetailPath(pattern.id),
            ),
            title: Text(
              pattern.grammar,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(pattern.jlpt.toUpperCase()),
            trailing: IconButton(
              tooltip: 'Remove favorite / お気に入り解除',
              onPressed: () => onRemove(pattern),
              icon: const Icon(Icons.favorite, color: Colors.redAccent),
            ),
          ),
        );
      },
    );
  }
}
