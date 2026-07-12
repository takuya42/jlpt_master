import '../domain/grammar_pattern.dart';

abstract interface class GrammarRepository {
  Future<List<GrammarPattern>> fetchPatterns();

  Future<GrammarPattern?> fetchPatternById(String id);
}
