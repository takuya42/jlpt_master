import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_master/features/grammar/data/google_sheet_grammar_repository.dart';

void main() {
  group('GoogleSheetGrammarRepository parser', () {
    test('keeps rows with optional trailing columns missing', () {
      const csv = '''id,jlpt,grammar,meaning_en,meaning_ja,explanation_en,explanation_ja,example_jp,example_en,example_translation_ja
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
          'id\tlevel\tgrammar\tmeaning_en\tmeaning_ja\n1\tN4\t〜そうだ\tlooks like\t〜ように見える';
      final pattern = GoogleSheetGrammarRepository().parseText(tsv).single;

      expect(pattern.grammar, '〜そうだ');
      expect(pattern.meaningEn, 'looks like');
      expect(pattern.meaningJa, '〜ように見える');
      expect(pattern.jlpt, 'N4');
    });
  });
}
