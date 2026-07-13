import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/grammar_pattern.dart';
import '../providers/grammar_providers.dart';
import '../widgets/grammar_studied_toggle.dart';

class GrammarDetailPage extends ConsumerWidget {
  const GrammarDetailPage({super.key, required this.grammarId});

  final String grammarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pattern = ref.watch(grammarPatternProvider(grammarId));

    return Scaffold(
      appBar: AppBar(title: const Text('Grammar Detail / 文法詳細')),
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
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              elevation: 3,
              shadowColor: colorScheme.shadow.withValues(alpha: 0.14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              child: Padding(
                padding: const EdgeInsets.all(24),
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
                              Text(pattern.grammar, style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900)),
                              const SizedBox(height: 8),
                              Text(pattern.meaningEn, style: theme.textTheme.headlineSmall?.copyWith(color: colorScheme.primary)),
                              const SizedBox(height: 4),
                              Text(pattern.meaningJa, style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: isFavorite ? 'Favorite / お気に入り解除' : 'Favorite / お気に入り追加',
                          onPressed: () => toggleGrammarFavorite(ref, pattern),
                          iconSize: 28,
                          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                        ),
                      ],
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
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Example', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    Text('日本語', style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(pattern.exampleJp, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Text('English', style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(pattern.exampleEn, style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
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
