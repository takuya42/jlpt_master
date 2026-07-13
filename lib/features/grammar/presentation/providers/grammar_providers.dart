import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../features/learning/presentation/providers/learning_providers.dart';
import '../../data/google_sheet_grammar_repository.dart';
import '../../data/grammar_repository.dart';
import '../../domain/grammar_pattern.dart';

const grammarJlptLevels = ['All', 'N5', 'N4', 'N3', 'N2', 'N1'];

final grammarRepositoryProvider = Provider<GrammarRepository>((ref) {
  return GoogleSheetGrammarRepository();
});

final grammarPatternsProvider =
    FutureProvider<List<GrammarPattern>>((ref) async {
  debugPrint('grammarPatternsProvider: 開始');
  final repository = ref.watch(grammarRepositoryProvider);
  debugPrint(
    'grammarPatternsProvider: Repository呼び出し ${repository.runtimeType}',
  );
  final patterns = await repository.fetchPatterns();
  debugPrint('grammarPatternsProvider: Repository終了');
  debugPrint('grammarPatternsProvider: 取得件数=${patterns.length}');
  return patterns;
});

final grammarPatternProvider = FutureProvider.family<GrammarPattern?, String>((ref, id) async {
  return ref.watch(grammarRepositoryProvider).fetchPatternById(id);
});

final grammarSearchQueryProvider = NotifierProvider<GrammarSearchQueryNotifier, String>(
  GrammarSearchQueryNotifier.new,
);

class GrammarSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

final selectedGrammarJlptLevelProvider = NotifierProvider<SelectedGrammarJlptLevelNotifier, String>(
  SelectedGrammarJlptLevelNotifier.new,
);

class SelectedGrammarJlptLevelNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void selectLevel(String level) {
    if (grammarJlptLevels.contains(level)) {
      state = level;
    }
  }
}

final favoriteGrammarIdsProvider = StreamProvider<Set<String>>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(userLearningRepositoryProvider).watchFavoriteIds('grammar');
});

final studiedGrammarIdsProvider = StreamProvider<Set<String>>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(userLearningRepositoryProvider).watchStudiedGrammarIds();
});

final filteredGrammarPatternsProvider = Provider<AsyncValue<List<GrammarPattern>>>((ref) {
  final selectedLevel = ref.watch(selectedGrammarJlptLevelProvider);
  final query = ref.watch(grammarSearchQueryProvider).trim().toLowerCase();
  final patterns = ref.watch(grammarPatternsProvider);

  return patterns.whenData((items) {
    return items
        .where((pattern) => selectedLevel == 'All' || pattern.jlpt == selectedLevel)
        .where((pattern) {
          if (query.isEmpty) {
            return true;
          }
          return pattern.grammar.toLowerCase().contains(query) ||
              pattern.meaningEn.toLowerCase().contains(query) ||
              pattern.meaningJa.toLowerCase().contains(query) ||
              pattern.explanationEn.toLowerCase().contains(query) ||
              pattern.explanationJa.toLowerCase().contains(query);
        })
        .toList(growable: false);
  });
});

Future<void> toggleGrammarFavorite(WidgetRef ref, GrammarPattern pattern) async {
  final favorites = ref.read(favoriteGrammarIdsProvider).asData?.value ?? <String>{};
  await ref.read(userLearningRepositoryProvider).setFavorite(
        type: 'grammar',
        itemId: pattern.id,
        isFavorite: !favorites.contains(pattern.id),
        title: pattern.grammar,
        subtitle: pattern.meaningEn,
        jlptLevel: pattern.jlpt,
      );
}

Future<void> recordGrammarStudy(WidgetRef ref, GrammarPattern pattern) {
  return ref.read(userLearningRepositoryProvider).recordGrammarStudy(
        pattern.id,
        jlptLevel: pattern.jlpt,
        title: pattern.grammar,
      );
}
