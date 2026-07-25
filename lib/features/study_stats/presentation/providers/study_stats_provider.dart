import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../grammar/data/google_sheet_grammar_repository.dart';
import '../../../vocabulary/data/google_sheet_vocabulary_repository.dart';
import '../../data/study_stats_repository.dart';
import '../../domain/study_stats.dart';

final studyStatsRepositoryProvider = Provider<StudyStatsRepository>((ref) {
  return StudyStatsRepository();
});

final studyQuestionTotalsProvider = FutureProvider<({int vocabulary, int grammar})>((ref) async {
  final vocabulary = await GoogleSheetVocabularyRepository().fetchWords();
  final grammar = await GoogleSheetGrammarRepository().fetchPatterns();
  return (vocabulary: vocabulary.length, grammar: grammar.length);
});

final studyStatsProvider = AsyncNotifierProvider<StudyStatsNotifier, StudyStatsSummary>(
  StudyStatsNotifier.new,
);

class StudyStatsNotifier extends AsyncNotifier<StudyStatsSummary> {
  @override
  Future<StudyStatsSummary> build() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return _emptySummary;

    final totals = await ref.watch(studyQuestionTotalsProvider.future);
    final stats = await ref.watch(studyStatsRepositoryProvider).load();
    return StudyStatsSummary(
      stats: stats,
      totalVocabularyQuestions: totals.vocabulary,
      totalGrammarQuestions: totals.grammar,
    );
  }

  Future<void> addStudyTime(Duration duration) async {
    if (!_isAuthenticated) return;
    final stats =
        await ref.read(studyStatsRepositoryProvider).addStudyTime(duration);
    await _setStats(stats);
  }

  Future<void> markVocabularySolved(String vocabularyId) async {
    if (!_isAuthenticated) return;
    final stats = await ref
        .read(studyStatsRepositoryProvider)
        .markVocabularySolved(vocabularyId);
    await _setStats(stats);
  }

  Future<void> markGrammarSolved(String grammarId) async {
    if (!_isAuthenticated) return;
    final stats = await ref
        .read(studyStatsRepositoryProvider)
        .markGrammarSolved(grammarId);
    await _setStats(stats);
  }

  Future<void> _setStats(StudyStats stats) async {
    if (!_isAuthenticated) {
      state = AsyncData(_emptySummary);
      return;
    }
    final totals = await ref.read(studyQuestionTotalsProvider.future);
    state = AsyncData(StudyStatsSummary(
      stats: stats,
      totalVocabularyQuestions: totals.vocabulary,
      totalGrammarQuestions: totals.grammar,
    ));
  }

  bool get _isAuthenticated =>
      ref.read(authRepositoryProvider).currentFirebaseUser != null;

  StudyStatsSummary get _emptySummary => StudyStatsSummary(
        stats: StudyStats.empty(),
        totalVocabularyQuestions: 0,
        totalGrammarQuestions: 0,
      );
}
