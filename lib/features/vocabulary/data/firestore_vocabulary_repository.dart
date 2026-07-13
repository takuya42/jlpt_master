import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/vocabulary_word.dart';
import 'vocabulary_repository.dart';

class FirestoreVocabularyRepository implements VocabularyRepository {
  FirestoreVocabularyRepository({FirebaseFirestore? firestore, Random? random})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _random = random ?? Random();

  final FirebaseFirestore _firestore;
  final Random _random;

  CollectionReference<Map<String, dynamic>> get _collection => _firestore.collection('Vocabulary');

  @override
  Future<List<VocabularyWord>> fetchWords() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map(_wordFromSnapshot).toList(growable: false);
  }

  @override
  Future<VocabularyWord?> fetchWordById(String id) async {
    final snapshot = await _collection.doc(id).get();
    if (!snapshot.exists) {
      return null;
    }
    return _wordFromSnapshot(snapshot);
  }

  @override
  Future<VocabularyWord?> fetchRandomWord({String? excludeWordId, String? jlpt}) async {
    final query = jlpt == null ? _collection : _collection.where('jlpt', isEqualTo: jlpt);
    final snapshot = await query.get();
    final words = snapshot.docs.map(_wordFromSnapshot).toList(growable: false);
    if (words.isEmpty) {
      return null;
    }

    final pool = excludeWordId == null
        ? words
        : words
            .where((word) => word.id != excludeWordId)
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
      word: _stringValue(data, ['word', 'japanese', 'meaning_ja']),
      reading: _stringValue(data, ['reading', 'kana'], required: false),
      meaning: _stringValue(data, ['meaning_en', 'meaning', 'english']),
      partOfSpeech: _stringValue(data, ['part_of_speech', 'partOfSpeech'], required: false),
      jlptLevel: _stringValue(data, ['jlpt', 'jlptLevel'], required: false).toUpperCase(),
      isFavorite: false,
      exampleSentence: _stringValue(data, ['example_jp', 'exampleSentence'], required: false),
      exampleMeaning: _stringValue(data, ['example_en', 'exampleMeaning'], required: false),
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
}
