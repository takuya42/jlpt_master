import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/vocabulary_repository.dart';
import '../../domain/vocabulary_word.dart';

const jlptLevels = ['N5', 'N4', 'N3', 'N2', 'N1'];

final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  return const MockVocabularyRepository();
});

final vocabularyWordsProvider = FutureProvider<List<VocabularyWord>>((ref) async {
  return ref.watch(vocabularyRepositoryProvider).fetchWords();
});

final vocabularyWordProvider = FutureProvider.family<VocabularyWord?, String>((ref, id) async {
  final word = await ref.watch(vocabularyRepositoryProvider).fetchWordById(id);
  final favoriteIds = ref.watch(favoriteVocabularyIdsProvider);

  if (word == null) {
    return null;
  }

  return word.copyWith(isFavorite: favoriteIds.contains(word.id));
});

final vocabularySearchQueryProvider = StateProvider<String>((ref) => '');

final selectedJlptLevelProvider = StateProvider<String>((ref) => 'N5');

final favoriteVocabularyIdsProvider = StateProvider<Set<String>>((ref) {
  return const {'n5-001', 'n3-001'};
});

final filteredVocabularyWordsProvider = Provider<AsyncValue<List<VocabularyWord>>>((ref) {
  final selectedLevel = ref.watch(selectedJlptLevelProvider);
  final query = ref.watch(vocabularySearchQueryProvider).trim().toLowerCase();
  final favoriteIds = ref.watch(favoriteVocabularyIdsProvider);
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

void toggleFavorite(WidgetRef ref, VocabularyWord word) {
  final current = ref.read(favoriteVocabularyIdsProvider);
  final updated = {...current};

  if (updated.contains(word.id)) {
    updated.remove(word.id);
  } else {
    updated.add(word.id);
  }

  ref.read(favoriteVocabularyIdsProvider.notifier).state = updated;
}
