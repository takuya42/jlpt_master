import '../domain/vocabulary_word.dart';

abstract interface class VocabularyRepository {
  Future<List<VocabularyWord>> fetchWords({String? jlpt});

  Future<VocabularyWord?> fetchWordById(String id);

  Future<VocabularyWord?> fetchRandomWord({String? excludeWordId, String? jlpt}) async {
    final words = await fetchWords();
    if (words.isEmpty) {
      return null;
    }
    final pool = words
        .where((word) => jlpt == null || word.jlptLevel == jlpt)
        .where((word) => excludeWordId == null || word.id != excludeWordId)
        .toList(growable: false);
    if (pool.isEmpty) {
      return null;
    }
    pool.shuffle();
    return pool.first;
  }
}
