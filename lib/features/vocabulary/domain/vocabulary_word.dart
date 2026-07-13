import 'package:flutter/foundation.dart';

@immutable
class VocabularyWord {
  const VocabularyWord({
    required this.id,
    this.category = '',
    required this.word,
    required this.reading,
    this.romaji = '',
    required this.meaning,
    this.meaningEn = '',
    this.meaningJa = '',
    required this.partOfSpeech,
    required this.jlptLevel,
    required this.isFavorite,
    required this.exampleSentence,
    required this.exampleMeaning,
    this.exampleEn = '',
    this.exampleJa = '',
  });

  final String id;
  final String category;
  final String word;
  final String reading;
  final String romaji;
  final String meaning;
  final String meaningEn;
  final String meaningJa;
  final String partOfSpeech;
  final String jlptLevel;
  final bool isFavorite;
  final String exampleSentence;
  final String exampleMeaning;
  final String exampleEn;
  final String exampleJa;

  VocabularyWord copyWith({bool? isFavorite}) {
    return VocabularyWord(
      id: id,
      category: category,
      word: word,
      reading: reading,
      romaji: romaji,
      meaning: meaning,
      meaningEn: meaningEn,
      meaningJa: meaningJa,
      partOfSpeech: partOfSpeech,
      jlptLevel: jlptLevel,
      isFavorite: isFavorite ?? this.isFavorite,
      exampleSentence: exampleSentence,
      exampleMeaning: exampleMeaning,
      exampleEn: exampleEn,
      exampleJa: exampleJa,
    );
  }
}
