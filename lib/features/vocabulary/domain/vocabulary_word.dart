import 'package:flutter/foundation.dart';

@immutable
class VocabularyWord {
  const VocabularyWord({
    required this.id,
    required this.word,
    required this.reading,
    required this.meaning,
    required this.partOfSpeech,
    required this.jlptLevel,
    required this.isFavorite,
    required this.exampleSentence,
    required this.exampleMeaning,
  });

  final String id;
  final String word;
  final String reading;
  final String meaning;
  final String partOfSpeech;
  final String jlptLevel;
  final bool isFavorite;
  final String exampleSentence;
  final String exampleMeaning;

  VocabularyWord copyWith({bool? isFavorite}) {
    return VocabularyWord(
      id: id,
      word: word,
      reading: reading,
      meaning: meaning,
      partOfSpeech: partOfSpeech,
      jlptLevel: jlptLevel,
      isFavorite: isFavorite ?? this.isFavorite,
      exampleSentence: exampleSentence,
      exampleMeaning: exampleMeaning,
    );
  }
}
