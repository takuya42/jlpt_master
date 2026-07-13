import '../domain/vocabulary_word.dart';
import 'vocabulary_repository.dart';

class MockVocabularyRepository implements VocabularyRepository {
  static const List<VocabularyWord> _words = [
    VocabularyWord(
      id: 'mock-vocab-001',
      word: '水',
      reading: 'みず',
      meaning: 'water',
      partOfSpeech: 'noun',
      jlptLevel: 'N5',
      isFavorite: false,
      exampleSentence: '水を飲みます。',
      exampleMeaning: 'I drink water.',
    ),
    VocabularyWord(
      id: 'mock-vocab-002',
      word: '本',
      reading: 'ほん',
      meaning: 'book',
      partOfSpeech: 'noun',
      jlptLevel: 'N5',
      isFavorite: false,
      exampleSentence: '本を読みます。',
      exampleMeaning: 'I read a book.',
    ),
    VocabularyWord(
      id: 'mock-vocab-003',
      word: '食べる',
      reading: 'たべる',
      meaning: 'to eat',
      partOfSpeech: 'verb',
      jlptLevel: 'N5',
      isFavorite: false,
      exampleSentence: '朝ご飯を食べます。',
      exampleMeaning: 'I eat breakfast.',
    ),
    VocabularyWord(
      id: 'mock-vocab-004',
      word: '大きい',
      reading: 'おおきい',
      meaning: 'big',
      partOfSpeech: 'i-adjective',
      jlptLevel: 'N5',
      isFavorite: false,
      exampleSentence: '大きい犬がいます。',
      exampleMeaning: 'There is a big dog.',
    ),
    VocabularyWord(
      id: 'mock-vocab-005',
      word: '学校',
      reading: 'がっこう',
      meaning: 'school',
      partOfSpeech: 'noun',
      jlptLevel: 'N5',
      isFavorite: false,
      exampleSentence: '学校へ行きます。',
      exampleMeaning: 'I go to school.',
    ),
    VocabularyWord(
      id: 'mock-vocab-006',
      word: '時間',
      reading: 'じかん',
      meaning: 'time',
      partOfSpeech: 'noun',
      jlptLevel: 'N5',
      isFavorite: false,
      exampleSentence: '時間があります。',
      exampleMeaning: 'I have time.',
    ),
    VocabularyWord(
      id: 'mock-vocab-007',
      word: '新しい',
      reading: 'あたらしい',
      meaning: 'new',
      partOfSpeech: 'i-adjective',
      jlptLevel: 'N5',
      isFavorite: false,
      exampleSentence: '新しい車です。',
      exampleMeaning: 'It is a new car.',
    ),
    VocabularyWord(
      id: 'mock-vocab-008',
      word: '友達',
      reading: 'ともだち',
      meaning: 'friend',
      partOfSpeech: 'noun',
      jlptLevel: 'N5',
      isFavorite: false,
      exampleSentence: '友達に会います。',
      exampleMeaning: 'I meet a friend.',
    ),
    VocabularyWord(
      id: 'mock-vocab-009',
      word: '駅',
      reading: 'えき',
      meaning: 'station',
      partOfSpeech: 'noun',
      jlptLevel: 'N5',
      isFavorite: false,
      exampleSentence: '駅は近いです。',
      exampleMeaning: 'The station is near.',
    ),
    VocabularyWord(
      id: 'mock-vocab-010',
      word: '話す',
      reading: 'はなす',
      meaning: 'to speak',
      partOfSpeech: 'verb',
      jlptLevel: 'N5',
      isFavorite: false,
      exampleSentence: '日本語を話します。',
      exampleMeaning: 'I speak Japanese.',
    ),
  ];

  @override
  Future<List<VocabularyWord>> fetchWords() async => _words;

  @override
  Future<VocabularyWord?> fetchWordById(String id) async {
    for (final word in _words) {
      if (word.id == id) return word;
    }
    return null;
  }
}
