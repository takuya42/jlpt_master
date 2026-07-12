import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/widgets/premium_button.dart';
import '../../domain/grammar_pattern.dart';
import '../providers/grammar_providers.dart';

class GrammarPage extends ConsumerWidget {
  const GrammarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final patterns = ref.watch(grammarPatternsProvider);
    final favoriteIds = ref.watch(favoriteGrammarIdsProvider).asData?.value ?? <String>{};

    return Scaffold(
      appBar: AppBar(actions: const [PremiumButton()]),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: patterns.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Failed to load grammar data.\n$error'),
                ),
              ),
              data: (items) => ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
                itemCount: items.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _PageHeader(
                      title: 'Grammar\n文法',
                      subtitle: 'Study each pattern with English and Japanese example sentences.\n文型を英語訳・日本語訳つきの例文で確認しましょう。',
                      icon: Icons.subject_outlined,
                      color: theme.colorScheme.tertiaryContainer,
                    );
                  }
                  final pattern = items[index - 1];
                  return _GrammarCard(
                    pattern: pattern,
                    isFavorite: favoriteIds.contains(pattern.id),
                    onFavorite: () => toggleGrammarFavorite(ref, pattern),
                    onStudied: () => recordGrammarStudy(ref, pattern),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GrammarCard extends StatelessWidget {
  const _GrammarCard({required this.pattern, required this.isFavorite, required this.onFavorite, required this.onStudied});
  final GrammarPattern pattern;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onStudied;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Chip(label: Text(pattern.jlpt)),
            const SizedBox(width: 10),
            Expanded(child: Text(pattern.grammar, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900))),
            IconButton.filledTonal(onPressed: onFavorite, icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border), tooltip: 'Favorite / お気に入り'),
          ]),
          const SizedBox(height: 12),
          Text(pattern.meaningEn, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          Text(pattern.meaningJa, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const Divider(height: 30),
          Text('Example / 例文', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
          const SizedBox(height: 8),
          Text(pattern.exampleJp, style: theme.textTheme.titleLarge),
          const SizedBox(height: 10),
          Text('English: ${pattern.exampleEn}', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 4),
          Text('日本語: ${pattern.exampleJa}', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerRight, child: FilledButton.tonal(onPressed: onStudied, child: const Text('Mark Studied / 学習済み'))),
        ]),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.subtitle, required this.icon, required this.color});
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(children: [
          Icon(icon, size: 42),
          const SizedBox(width: 18),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(subtitle, style: theme.textTheme.bodyLarge),
          ])),
        ]),
      ),
    );
  }
}
