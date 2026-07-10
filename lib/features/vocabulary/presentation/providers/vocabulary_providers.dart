import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/google_sheet_vocabulary_repository.dart';
import '../../data/vocabulary_repository.dart';
import '../../../../features/learning/presentation/providers/learning_providers.dart';
import '../../domain/vocabulary_word.dart';

const jlptLevels = ['N5', 'N4', 'N3', 'N2', 'N1'];

final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  return GoogleSheetVocabularyRepository();
});

final vocabularyWordsProvider = FutureProvider<List<VocabularyWord>>((ref) async {
  return ref.watch(vocabularyRepositoryProvider).fetchWords();
});

final vocabularyWordProvider = FutureProvider.family<VocabularyWord?, String>((ref, id) async {
  final word = await ref.watch(vocabularyRepositoryProvider).fetchWordById(id);
  final favoriteIds = ref.watch(favoriteVocabularyIdsProvider).asData?.value ?? <String>{};

  if (word == null) {
    return null;
  }

  return word.copyWith(isFavorite: favoriteIds.contains(word.id));
});

final vocabularySearchQueryProvider = NotifierProvider<VocabularySearchQueryNotifier, String>(
  VocabularySearchQueryNotifier.new,
);

class VocabularySearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

final selectedJlptLevelProvider = NotifierProvider<SelectedJlptLevelNotifier, String>(
  SelectedJlptLevelNotifier.new,
);

class SelectedJlptLevelNotifier extends Notifier<String> {
  @override
  String build() => 'N5';

  void selectLevel(String level) {
    if (jlptLevels.contains(level)) {
      state = level;
    }
  }
}

final favoriteVocabularyIdsProvider = StreamProvider<Set<String>>((ref) {
  return ref.watch(userLearningRepositoryProvider).watchFavoriteIds('vocabulary');
});

final filteredVocabularyWordsProvider = Provider<AsyncValue<List<VocabularyWord>>>((ref) {
  final selectedLevel = ref.watch(selectedJlptLevelProvider);
  final query = ref.watch(vocabularySearchQueryProvider).trim().toLowerCase();
  final favoriteIds = ref.watch(favoriteVocabularyIdsProvider).asData?.value ?? <String>{};
  final words = ref.watch(vocabularyWordsProvider);

  return words.whenData((items) {
    return items
        .where((word) => word.jlptLevel == selectedLevel)
        .where((word) {
          if (query.isEmpty) {
            return true;
          }
          return word.word.toLowerCase().contains(query) ||
              word.reading.toLowerCase().contains(query) ||
              word.meaning.toLowerCase().contains(query) ||
              word.partOfSpeech.toLowerCase().contains(query);
        })
        .map((word) => word.copyWith(isFavorite: favoriteIds.contains(word.id)))
        .toList(growable: false);
  });
});

Future<void> toggleFavorite(WidgetRef ref, VocabularyWord word) async {
  final favorites = ref.read(favoriteVocabularyIdsProvider).asData?.value ?? <String>{};
  await ref.read(userLearningRepositoryProvider).setFavorite(
        type: 'vocabulary',
        itemId: word.id,
        isFavorite: !favorites.contains(word.id),
      );
}

Future<void> recordVocabularyView(WidgetRef ref, String wordId) {
  return ref.read(userLearningRepositoryProvider).recordVocabularyView(wordId);
}
