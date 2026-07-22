import 'package:flutter/foundation.dart';

@immutable
class GrammarPattern {
  const GrammarPattern({
    required this.id,
    required this.jlpt,
    required this.grammar,
    required this.meaningEn,
    required this.meaningJa,
    required this.explanationEn,
    required this.explanationJa,
    required this.exampleJp,
    required this.exampleEn,
    required this.exampleJa,
  });

  final String id;
  final String jlpt;
  final String grammar;
  final String meaningEn;
  final String meaningJa;
  final String explanationEn;
  final String explanationJa;
  final String exampleJp;
  final String exampleEn;
  final String exampleJa;

  /// Creates a pattern from a record whose keys are the Grammar sheet headers.
  ///
  /// The JLPT value deliberately has no fallback. A missing or invalid value
  /// is a malformed grammar record and must not silently turn into an N5 item.
  factory GrammarPattern.fromMap(Map<String, String> map) {
    final jlpt = _normalizeJlpt(map['jlpt'] ?? '');
    if (jlpt == null) {
      throw FormatException('Invalid GrammarPattern jlpt: ${map['jlpt']}');
    }

    return GrammarPattern(
      id: (map['id'] ?? '').trim(),
      jlpt: jlpt,
      grammar: (map['grammar'] ?? '').trim(),
      meaningEn: (map['meaning_en'] ?? '').trim(),
      meaningJa: (map['meaning_ja'] ?? '').trim(),
      explanationEn: (map['explanation_en'] ?? '').trim(),
      explanationJa: (map['explanation_ja'] ?? '').trim(),
      exampleJp: (map['example_jp'] ?? '').trim(),
      exampleEn: (map['example_en'] ?? '').trim(),
      exampleJa: (map['example_ja'] ?? '').trim(),
    );
  }

  /// Converts one CSV row to a header-keyed record before parsing it.
  factory GrammarPattern.fromCsv(
    List<dynamic> row,
    List<String> headers,
  ) {
    final map = <String, String>{};
    for (var index = 0; index < headers.length; index++) {
      map[headers[index]] =
          index < row.length ? row[index].toString().trim() : '';
    }
    return GrammarPattern.fromMap(map);
  }

  String get expression => grammar;
  String get level => jlpt;
  String get example => exampleJp;
  String get translationEn => exampleEn;
  String get translationJa => exampleJa;

  static String? _normalizeJlpt(String value) {
    final match = RegExp(
      r'^(?:JLPT\s*)?N?\s*([1-5])$',
      caseSensitive: false,
    ).firstMatch(value.trim());
    return match == null ? null : 'N${match.group(1)}';
  }

  @override
  String toString() {
    return 'GrammarPattern(id: $id, jlpt: $jlpt, grammar: $grammar, '
        'meaningEn: $meaningEn, meaningJa: $meaningJa, '
        'explanationEn: $explanationEn, explanationJa: $explanationJa, '
        'exampleJp: $exampleJp, exampleEn: $exampleEn, exampleJa: $exampleJa)';
  }
}
