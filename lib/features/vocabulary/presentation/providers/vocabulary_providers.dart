import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/firestore_vocabulary_repository.dart';
import '../../data/vocabulary_repository.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../features/learning/presentation/providers/learning_providers.dart';
import '../../domain/vocabulary_word.dart';

const jlptLevels = ['N5', 'N4', 'N3', 'N2', 'N1'];
const vocabularyJlptLevels = ['All', ...jlptLevels];

class VocabularyQuizState {
  const VocabularyQuizState({this.word, this.answer = '', this.isCorrect});

  final VocabularyWord? word;
  final String answer;
  final bool? isCorrect;

  VocabularyQuizState copyWith({
    VocabularyWord? word,
    String? answer,
    bool? isCorrect,
    bool clearResult = false,
  }) {
    return VocabularyQuizState(
      word: word ?? this.word,
      answer: answer ?? this.answer,
      isCorrect: clearResult ? null : isCorrect ?? this.isCorrect,
    );
  }
}

final vocabularyQuizProvider =
    AsyncNotifierProvider<VocabularyQuizNotifier, VocabularyQuizState>(
  VocabularyQuizNotifier.new,
);

class VocabularyQuizNotifier extends AsyncNotifier<VocabularyQuizState> {
  @override
  Future<VocabularyQuizState> build() async {
    debugPrint('vocabularyQuizProvider build start');
    final selectedLevel = ref.watch(selectedVocabularyJlptProvider);
    try {
      final word = await ref
          .read(vocabularyRepositoryProvider)
          .fetchRandomWord(jlpt: selectedLevel == 'All' ? null : selectedLevel);
      debugPrint('Quiz created');
      debugPrint('Provider completed');
      return VocabularyQuizState(word: word);
    } on Object catch (error, stackTrace) {
      debugPrint('vocabularyQuizProvider failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      debugPrint('Provider completed');
      return const VocabularyQuizState();
    }
  }

  void updateAnswer(String answer) {
    if (!state.hasValue) {
      return;
    }
    final current = state.value;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(answer: answer, clearResult: true));
  }

  Future<void> checkAnswer() async {
    if (!state.hasValue) {
      return;
    }
    final current = state.value;
    final word = current?.word;
    if (current == null || word == null) {
      return;
    }

    final isCorrect = _normalize(current.answer) == _normalize(word.meaning);
    state = AsyncData(current.copyWith(isCorrect: isCorrect));
    await ref.read(userLearningRepositoryProvider).recordVocabularyQuizAnswer(
          wordId: word.id,
          isCorrect: isCorrect,
        );
  }

  Future<void> nextQuestion() async {
    final previousWordId = state.hasValue ? state.value?.word?.id : null;
    state = const AsyncLoading();
    try {
      final selectedLevel = ref.read(selectedVocabularyJlptProvider);
      final word = await ref.read(vocabularyRepositoryProvider).fetchRandomWord(
            excludeWordId: previousWordId,
            jlpt: selectedLevel == 'All' ? null : selectedLevel,
          );
      debugPrint('Quiz created');
      debugPrint('Provider completed');
      state = AsyncData(VocabularyQuizState(word: word));
    } on Object catch (error, stackTrace) {
      debugPrint('vocabularyQuizProvider nextQuestion failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      debugPrint('Provider completed');
      state = const AsyncData(VocabularyQuizState());
    }
  }

  String _normalize(String value) => value.trim().toLowerCase();
}

final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  return FirestoreVocabularyRepository();
});

final vocabularyWordsProvider = FutureProvider<List<VocabularyWord>>((ref) async {
  debugPrint('vocabularyWordsProvider start');
  try {
    final words = await ref.read(vocabularyRepositoryProvider).fetchWords();
    debugPrint('vocabularyWordsProvider completed ${words.length}');
    return words;
  } on Object catch (error, stackTrace) {
    debugPrint('vocabularyWordsProvider failed: $error');
    debugPrintStack(stackTrace: stackTrace);
    debugPrint('vocabularyWordsProvider completed 0');
    return const [];
  }
});

final vocabularyWordProvider =
    FutureProvider.family<VocabularyWord?, String>((ref, id) async {
  final word = await ref.watch(vocabularyRepositoryProvider).fetchWordById(id);
  final favoriteIds =
      ref.watch(favoriteVocabularyIdsProvider).asData?.value ?? <String>{};

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

final selectedVocabularyJlptProvider =
    NotifierProvider<SelectedVocabularyJlptNotifier, String>(
  SelectedVocabularyJlptNotifier.new,
);

class SelectedVocabularyJlptNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void selectLevel(String level) {
    if (vocabularyJlptLevels.contains(level)) {
      state = level;
    }
  }
}

final favoriteVocabularyIdsProvider = StreamProvider<Set<String>>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(userLearningRepositoryProvider).watchFavoriteIds('vocabulary');
});

final filteredVocabularyWordsProvider =
    Provider<AsyncValue<List<VocabularyWord>>>((ref) {
  debugPrint('filteredVocabularyWordsProvider start');
  final selectedLevel = ref.watch(selectedVocabularyJlptProvider);
  final query = ref.watch(vocabularySearchQueryProvider).trim().toLowerCase();
  final favoriteIds =
      ref.watch(favoriteVocabularyIdsProvider).asData?.value ?? <String>{};
  final words = ref.watch(vocabularyWordsProvider);

  return words.whenData((items) {
    final filtered = items
        .where((word) => selectedLevel == 'All' || word.jlptLevel == selectedLevel)
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
    debugPrint('Filtered ${filtered.length}');
    return filtered;
  });
});

Future<void> toggleFavorite(WidgetRef ref, VocabularyWord word) async {
  final favorites = ref.read(favoriteVocabularyIdsProvider).asData?.value ?? <String>{};
  await ref.read(userLearningRepositoryProvider).setFavorite(
        type: 'vocabulary',
        itemId: word.id,
        isFavorite: !favorites.contains(word.id),
        title: word.word,
        subtitle: word.meaning,
        jlptLevel: word.jlptLevel,
      );
}

Future<void> recordVocabularyView(WidgetRef ref, VocabularyWord word) {
  return ref.read(userLearningRepositoryProvider).recordVocabularyView(
        word.id,
        jlptLevel: word.jlptLevel,
        title: word.word,
      );
}
