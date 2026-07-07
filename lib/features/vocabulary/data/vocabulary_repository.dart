import '../domain/vocabulary_word.dart';

abstract interface class VocabularyRepository {
  Future<List<VocabularyWord>> fetchWords();

  Future<VocabularyWord?> fetchWordById(String id);
}
