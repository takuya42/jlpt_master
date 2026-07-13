import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/vocabulary_word.dart';
import 'vocabulary_repository.dart';

class FirestoreVocabularyRepository implements VocabularyRepository {
  FirestoreVocabularyRepository({FirebaseFirestore? firestore, Random? random})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _random = random ?? Random();

  static const _collectionNames = ['Vocabulary', 'vocabulary'];

  final FirebaseFirestore _firestore;
  final Random _random;

  CollectionReference<Map<String, dynamic>> _collection(String name) => _firestore.collection(name);

  @override
  Future<List<VocabularyWord>> fetchWords() async {
    for (final collectionName in _collectionNames) {
      final snapshot = await _collection(collectionName).get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map(_wordFromSnapshot).toList(growable: false);
      }
    }
    return const [];
  }

  @override
  Future<VocabularyWord?> fetchWordById(String id) async {
    for (final collectionName in _collectionNames) {
      final snapshot = await _collection(collectionName).doc(id).get();
      if (snapshot.exists) {
        return _wordFromSnapshot(snapshot);
      }
    }
    return null;
  }

  @override
  Future<VocabularyWord?> fetchRandomWord({String? excludeWordId, String? jlpt}) async {
    final words = await fetchWords();
    if (words.isEmpty) {
      return null;
    }

    final normalizedJlpt = _normalizeJlpt(jlpt);
    final pool = words
        .where((word) => normalizedJlpt == null || word.jlptLevel == normalizedJlpt)
        .where((word) => excludeWordId == null || word.id != excludeWordId)
        .toList(growable: false);
    if (pool.isEmpty) {
      return null;
    }
    return pool[_random.nextInt(pool.length)];
  }

  VocabularyWord _wordFromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return VocabularyWord(
      id: (data['id'] as String?)?.trim().isNotEmpty == true ? (data['id'] as String).trim() : snapshot.id,
      word: _stringValue(data, ['word', 'japanese', 'meaning_ja', 'vocabulary']),
      reading: _stringValue(data, ['reading', 'kana', 'hiragana'], required: false),
      meaning: _stringValue(data, ['meaning_en', 'meaning', 'english', 'translation']),
      partOfSpeech: _stringValue(data, ['part_of_speech', 'partOfSpeech', 'pos'], required: false),
      jlptLevel: _normalizeJlpt(_stringValue(data, ['jlpt', 'jlptLevel', 'level', 'JLPT_Level'], required: false)) ?? '',
      isFavorite: false,
      exampleSentence: _stringValue(data, ['example_jp', 'exampleSentence', 'example'], required: false),
      exampleMeaning: _stringValue(data, ['example_en', 'exampleMeaning', 'example_translation'], required: false),
    );
  }

  String _stringValue(Map<String, dynamic> data, List<String> keys, {bool required = true}) {
    for (final key in keys) {
      final value = data[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) {
        return value;
      }
    }
    if (!required) {
      return '';
    }
    throw Exception(
      'Vocabulary document is missing required "${keys.first}" value.',
    );
  }

  String? _normalizeJlpt(String? value) {
    final normalized = value?.trim().toUpperCase().replaceFirst(RegExp(r'^JLPT[-_\s]*'), '') ?? '';
    if (normalized.isEmpty) {
      return null;
    }
    return normalized.startsWith('N') ? normalized : 'N$normalized';
  }
}
