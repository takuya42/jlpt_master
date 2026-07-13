import '../domain/vocabulary_word.dart';

abstract interface class VocabularyRepository {
  Future<List<VocabularyWord>> fetchWords();

  Future<VocabularyWord?> fetchWordById(String id);

  Future<VocabularyWord?> fetchRandomWord({String? excludeWordId}) async {
    final words = await fetchWords();
    if (words.isEmpty) {
      return null;
    }
    final candidates = words.where((word) => word.id != excludeWordId).toList(growable: false);
    final pool = candidates.isEmpty ? words : candidates;
    pool.shuffle();
    return pool.first;
  }
}
