import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jlpt_master/features/grammar/data/google_sheet_grammar_repository.dart';
import 'package:jlpt_master/features/grammar/data/grammar_repository.dart';
import 'package:jlpt_master/features/grammar/domain/grammar_pattern.dart';
import 'package:jlpt_master/features/grammar/presentation/providers/grammar_providers.dart';

void main() {
  group('GoogleSheetGrammarRepository parser', () {
    test('keeps rows with optional trailing columns missing', () {
      const csv = '''id,jlpt,grammar,meaning_en,meaning_ja,explanation_en,explanation_ja,example_jp,example_en,example_ja
1,N5,です,is,です,,,,,
2,N4,なら,if
3,JLPT N3,ほど,to the extent
4,n2,わけだ,it follows
5,1,に至る,lead to''';

      final patterns = GoogleSheetGrammarRepository().parseText(csv);

      expect(patterns, hasLength(5));
      expect(patterns.map((pattern) => pattern.jlpt),
          orderedEquals(['N5', 'N4', 'N3', 'N2', 'N1']));
    });

    test('parses TSV and searches all requested fields after level filtering', () {
      const tsv =
          'id\tjlpt\tgrammar\tmeaning_en\tmeaning_ja\texplanation_en\texplanation_ja\texample_jp\texample_en\texample_ja\n1\tN4\t〜そうだ\tlooks like\t〜ように見える';
      final pattern = GoogleSheetGrammarRepository().parseText(tsv).single;

      expect(pattern.grammar, '〜そうだ');
      expect(pattern.meaningEn, 'looks like');
      expect(pattern.meaningJa, '〜ように見える');
      expect(pattern.jlpt, 'N4');
    });

    test('uses the dedicated published Grammar source', () {
      expect(
        GoogleSheetGrammarRepository.csvUrl,
        contains('/spreadsheets/d/e/2PACX-'),
      );
      expect(
        GoogleSheetGrammarRepository.csvUrl,
        isNot(contains('1vl_IRVwh7FWgcT-C8fTQltTQWwx8ejRJG9HnCctW0BU')),
      );
    });

    test('rejects a vocabulary header instead of parsing it as grammar', () {
      const csv = 'id,category,word,reading,romaji\n1,noun,猫,ねこ,neko';

      expect(
        () => GoogleSheetGrammarRepository().parseText(csv),
        throwsA(isA<GrammarRepositoryException>()),
      );
    });

    test('fetches and combines every JLPT sheet', () async {
      final requestedSheets = <String>[];
      final client = MockClient((request) async {
        final sheet = request.url.queryParameters['sheet'];
        requestedSheets.add(sheet!);
        return http.Response(
          'id,jlpt,grammar,meaning_en,meaning_ja,explanation_en,'
          'explanation_ja,example_jp,example_en,example_ja\n'
          '$sheet-1,$sheet,grammar-$sheet,,,,,,,',
          200,
        );
      });
      final repository = GoogleSheetGrammarRepository(
        client: client,
        csvUri: Uri.parse('https://example.com/grammar?gid=0&output=csv'),
      );

      final patterns = await repository.fetchPatterns();

      expect(requestedSheets, orderedEquals(['N5', 'N4', 'N3', 'N2', 'N1']));
      expect(patterns, hasLength(5));
      expect(
        patterns.map((pattern) => pattern.jlpt),
        orderedEquals(['N5', 'N4', 'N3', 'N2', 'N1']),
      );
    });
  });

  test('All and every JLPT filter use the complete repository result', () async {
    final patterns = List.generate(5, (index) {
      final level = 5 - index;
      return GrammarPattern(
        id: 'grammar-$level',
        jlpt: ' n$level ',
        grammar: '文法$level',
        meaningEn: '',
        meaningJa: '',
        explanationEn: '',
        explanationJa: '',
        exampleJp: '',
        exampleEn: '',
        exampleJa: '',
      );
    });
    final container = ProviderContainer(overrides: [
      grammarRepositoryProvider.overrideWithValue(_GrammarRepository(patterns)),
    ]);
    addTearDown(container.dispose);

    await container.read(grammarPatternsProvider.future);
    expect(
      container.read(filteredGrammarPatternsProvider).requireValue,
      hasLength(5),
    );
    for (final level in const ['N5', 'N4', 'N3', 'N2', 'N1']) {
      container
          .read(selectedGrammarJlptLevelProvider.notifier)
          .selectLevel(level);
      expect(
        container.read(filteredGrammarPatternsProvider).requireValue,
        hasLength(1),
        reason: '$level must not be skipped',
      );
    }
  });
}

class _GrammarRepository implements GrammarRepository {
  const _GrammarRepository(this.patterns);
  final List<GrammarPattern> patterns;

  @override
  Future<GrammarPattern?> fetchPatternById(String id) async {
    for (final pattern in patterns) {
      if (pattern.id == id) return pattern;
    }
    return null;
  }

  @override
  Future<List<GrammarPattern>> fetchPatterns() async => patterns;
}
