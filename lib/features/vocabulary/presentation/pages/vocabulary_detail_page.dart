import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/vocabulary_word.dart';
import '../providers/vocabulary_providers.dart';

class VocabularyDetailPage extends ConsumerWidget {
  const VocabularyDetailPage({super.key, required this.wordId});

  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final word = ref.watch(vocabularyWordProvider(wordId));

    return Scaffold(
      appBar: AppBar(title: const Text('Vocabulary Detail')),
      body: SafeArea(
        child: word.when(
          data: (data) {
            if (data == null) {
              return const _WordNotFoundView();
            }
            return _VocabularyDetailContent(word: data);
          },
          error: (error, stackTrace) => Center(
            child: Text('Could not load vocabulary detail.\n$error', textAlign: TextAlign.center),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _VocabularyDetailContent extends ConsumerWidget {
  const _VocabularyDetailContent({required this.word});

  final VocabularyWord word;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width >= 900 ? 840 : double.infinity),
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
                              Text(
                                word.word,
                                style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                word.reading,
                                style: theme.textTheme.headlineSmall?.copyWith(color: colorScheme.primary),
                              ),
                            ],
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: word.isFavorite ? 'Remove favorite' : 'Add favorite',
                          onPressed: () async {
                            final saved = await toggleFavorite(ref, word);
                            if (!saved && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('ログインするとお気に入りを保存できます。'),
                                ),
                              );
                            }
                          },
                          iconSize: 28,
                          icon: Icon(word.isFavorite ? Icons.favorite : Icons.favorite_border),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('English', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Text(word.meaning, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 20),
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
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Example sentence', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    Text(word.exampleSentence, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(word.exampleMeaning, style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
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

class _WordNotFoundView extends StatelessWidget {
  const _WordNotFoundView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Vocabulary word not found.'));
  }
}
