import 'package:flutter/foundation.dart';

import '../domain/vocabulary_word.dart';
import 'vocabulary_repository.dart';

class FallbackVocabularyRepository implements VocabularyRepository {
  const FallbackVocabularyRepository({
    required VocabularyRepository primary,
    required VocabularyRepository fallback,
  })  : _primary = primary,
        _fallback = fallback;

  final VocabularyRepository _primary;
  final VocabularyRepository _fallback;

  @override
  Future<List<VocabularyWord>> fetchWords() async {
    debugPrint(
      'FallbackVocabularyRepository.fetchWords primary=${_primary.runtimeType}',
    );
    final primaryWords = await _primary.fetchWords();
    debugPrint(
      'FallbackVocabularyRepository primary count=${primaryWords.length}',
    );
    if (primaryWords.isNotEmpty) {
      return primaryWords;
    }

    debugPrint(
      'FallbackVocabularyRepository primary returned 0; '
      'using fallback=${_fallback.runtimeType}',
    );
    final fallbackWords = await _fallback.fetchWords();
    debugPrint(
      'FallbackVocabularyRepository fallback count=${fallbackWords.length}',
    );
    return fallbackWords;
  }

  @override
  Future<VocabularyWord?> fetchWordById(String id) async {
    debugPrint(
      'FallbackVocabularyRepository.fetchWordById '
      'id=$id primary=${_primary.runtimeType}',
    );
    final primaryWord = await _primary.fetchWordById(id);
    if (primaryWord != null) {
      debugPrint(
        'FallbackVocabularyRepository.fetchWordById found primary id=$id',
      );
      return primaryWord;
    }

    debugPrint(
      'FallbackVocabularyRepository.fetchWordById primary miss; '
      'using fallback=${_fallback.runtimeType}',
    );
    return _fallback.fetchWordById(id);
  }

  @override
  Future<VocabularyWord?> fetchRandomWord({
    String? excludeWordId,
    String? jlpt,
  }) async {
    final words = await fetchWords();
    final pool = words
        .where((word) => jlpt == null || word.jlptLevel == jlpt)
        .where((word) => excludeWordId == null || word.id != excludeWordId)
        .toList(growable: false);
    debugPrint(
      'FallbackVocabularyRepository.fetchRandomWord '
      'pool count=${pool.length} jlpt=$jlpt',
    );
    if (pool.isEmpty) {
      return null;
    }
    pool.shuffle();
    return pool.first;
  }
}
