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

  String get expression => grammar;
  String get level => jlpt;
  String get example => exampleJp;
  String get translationEn => exampleEn;
  String get translationJa => exampleJa;
}
