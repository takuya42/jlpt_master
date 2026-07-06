import '../domain/vocabulary_word.dart';

abstract interface class VocabularyRepository {
  Future<List<VocabularyWord>> fetchWords();

  Future<VocabularyWord?> fetchWordById(String id);
}

class MockVocabularyRepository implements VocabularyRepository {
  const MockVocabularyRepository();

  static const _words = [
    VocabularyWord(
      id: 'n5-001',
      word: '学校',
      reading: 'がっこう',
      meaning: 'school（学校）',
      partOfSpeech: 'Noun',
      jlptLevel: 'N5',
      isFavorite: true,
      exampleSentence: '毎日、学校へ行きます。',
      exampleMeaning: 'I go to school every day.',
    ),
    VocabularyWord(
      id: 'n5-002',
      word: '食べる',
      reading: 'たべる',
      meaning: 'to eat（食べる）',
      partOfSpeech: 'Verb',
      jlptLevel: 'N5',
      isFavorite: false,
      exampleSentence: '朝ご飯を食べます。',
      exampleMeaning: 'I eat breakfast.',
    ),
    VocabularyWord(
      id: 'n4-001',
      word: '必要',
      reading: 'ひつよう',
      meaning: 'necessary（必要）',
      partOfSpeech: 'Na-adjective',
      jlptLevel: 'N4',
      isFavorite: false,
      exampleSentence: '予約が必要です。',
      exampleMeaning: 'A reservation is necessary.',
    ),
    VocabularyWord(
      id: 'n3-001',
      word: '確認',
      reading: 'かくにん',
      meaning: 'confirmation（確認）',
      partOfSpeech: 'Noun / Suru verb',
      jlptLevel: 'N3',
      isFavorite: true,
      exampleSentence: '予定を確認してください。',
      exampleMeaning: 'Please confirm the schedule.',
    ),
    VocabularyWord(
      id: 'n2-001',
      word: '把握',
      reading: 'はあく',
      meaning: 'understanding; grasp（把握）',
      partOfSpeech: 'Noun / Suru verb',
      jlptLevel: 'N2',
      isFavorite: false,
      exampleSentence: '状況を正確に把握する必要があります。',
      exampleMeaning: 'It is necessary to grasp the situation accurately.',
    ),
    VocabularyWord(
      id: 'n1-001',
      word: '著しい',
      reading: 'いちじるしい',
      meaning: 'remarkable; considerable（著しい）',
      partOfSpeech: 'I-adjective',
      jlptLevel: 'N1',
      isFavorite: false,
      exampleSentence: '技術の進歩は著しいです。',
      exampleMeaning: 'Technological progress is remarkable.',
    ),
  ];

  @override
  Future<List<VocabularyWord>> fetchWords() async {
    return _words;
  }

  @override
  Future<VocabularyWord?> fetchWordById(String id) async {
    for (final word in _words) {
      if (word.id == id) {
        return word;
      }
    }
    return null;
  }
}
