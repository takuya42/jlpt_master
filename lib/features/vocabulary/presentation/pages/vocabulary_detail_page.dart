import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/vocabulary_word.dart';
import '../../../notes/presentation/pages/notes_page.dart';
import '../providers/vocabulary_providers.dart';

class VocabularyDetailPage extends ConsumerStatefulWidget {
  const VocabularyDetailPage({super.key, required this.wordId, this.word});

  final String wordId;
  final VocabularyWord? word;

  @override
  ConsumerState<VocabularyDetailPage> createState() =>
      _VocabularyDetailPageState();
}

class _VocabularyDetailPageState extends ConsumerState<VocabularyDetailPage> {
  bool _recordedView = false;

  @override
  Widget build(BuildContext context) {
    // Normal navigation passes the already-rendered object in `extra`. The
    // provider lookup only supports restored/deep-linked routes and reads the
    // list cache synchronously; it never fetches an individual word.
    final word = widget.word ??
        ref.watch(vocabularyWordByIdProvider(widget.wordId));

    if (word != null && !_recordedView) {
      _recordedView = true;
      Future.microtask(() => recordVocabularyView(ref, word));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Vocabulary Detail / 単語詳細')),
      body: SafeArea(
        child: word == null
            ? const _WordNotFoundView()
            : _VocabularyDetailContent(word: word),
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
    final favoriteIds = ref.watch(favoriteVocabularyIdsProvider).asData?.value ??
        <String>{};
    final isFavorite = favoriteIds.contains(word.id);

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
                        FilledButton.tonal(
                          onPressed: () => showMemoBottomSheet(context),
                          child: const Text('📝 Memo'),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          tooltip: isFavorite ? 'Favorite / お気に入り解除' : 'Favorite / お気に入り追加',
                          onPressed: () => toggleFavorite(ref, word),
                          iconSize: 28,
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('English / 日本語', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Text(word.meaning, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text(word.word, style: theme.textTheme.titleLarge?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w800)),
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
                    Text('Example Sentence / 例文', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
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
    return const Center(child: Text('Vocabulary word not found. / 単語が見つかりません。'));
  }
}
