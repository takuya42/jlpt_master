import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../domain/vocabulary_word.dart';
import 'vocabulary_repository.dart';

class FirestoreVocabularyRepository implements VocabularyRepository {
  FirestoreVocabularyRepository({FirebaseFirestore? firestore, Random? random})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _random = random ?? Random();

  static const _collectionNames = ['Vocabulary', 'vocabulary'];
  static const _fetchTimeout = Duration(seconds: 10);

  final FirebaseFirestore _firestore;
  final Random _random;

  CollectionReference<Map<String, dynamic>> _collection(String name) =>
      _firestore.collection(name);

  @override
  Future<List<VocabularyWord>> fetchWords({String? jlpt}) async {
    debugPrint('fetchWords start');
    for (final collectionName in _collectionNames) {
      try {
        debugPrint('fetchWords collection $collectionName start');
        final snapshot =
            await _collection(collectionName).get().timeout(_fetchTimeout);
        debugPrint('Firestore loaded ${snapshot.docs.length} from $collectionName');
        if (snapshot.docs.isNotEmpty) {
          final words =
              snapshot.docs.map(_wordFromSnapshot).toList(growable: false);
          debugPrint('fetchWords completed ${words.length}');
          return words;
        }
      } on Object catch (error, stackTrace) {
        debugPrint('fetchWords failed for $collectionName: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
    debugPrint('fetchWords completed 0');
    return const [];
  }

  @override
  Future<VocabularyWord?> fetchWordById(String id) async {
    debugPrint('fetchWordById start $id');
    for (final collectionName in _collectionNames) {
      try {
        final snapshot = await _collection(collectionName)
            .doc(id)
            .get()
            .timeout(_fetchTimeout);
        debugPrint(
          'fetchWordById loaded $id from $collectionName exists=${snapshot.exists}',
        );
        if (snapshot.exists) {
          return _wordFromSnapshot(snapshot);
        }
      } on Object catch (error, stackTrace) {
        debugPrint('fetchWordById failed for $collectionName/$id: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
    debugPrint('fetchWordById completed null $id');
    return null;
  }

  @override
  Future<VocabularyWord?> fetchRandomWord({
    String? excludeWordId,
    String? jlpt,
  }) async {
    debugPrint(
      'fetchRandomWord start jlpt=$jlpt excludeWordId=$excludeWordId',
    );
    final words = await fetchWords();
    debugPrint('fetchRandomWord loaded ${words.length} words');
    if (words.isEmpty) {
      debugPrint('fetchRandomWord completed null: no words');
      return null;
    }

    final normalizedJlpt = _normalizeJlpt(jlpt);
    final pool = words
        .where((word) => normalizedJlpt == null || word.jlptLevel == normalizedJlpt)
        .where((word) => excludeWordId == null || word.id != excludeWordId)
        .toList(growable: false);
    debugPrint('Filtered ${pool.length}');
    if (pool.isEmpty) {
      debugPrint('fetchRandomWord completed null: empty filtered pool');
      return null;
    }
    final word = pool[_random.nextInt(pool.length)];
    debugPrint('fetchRandomWord completed ${word.id}');
    return word;
  }

  VocabularyWord _wordFromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return VocabularyWord(
      id: (data['id'] as String?)?.trim().isNotEmpty == true
          ? (data['id'] as String).trim()
          : snapshot.id,
      word: _stringValue(data, ['word', 'japanese', 'meaning_ja', 'vocabulary']),
      reading: _stringValue(data, ['reading', 'kana', 'hiragana'], required: false),
      meaning: _stringValue(data, ['meaning_en', 'meaning', 'english', 'translation']),
      partOfSpeech: _stringValue(data, ['part_of_speech', 'partOfSpeech', 'pos'], required: false),
      jlptLevel: _normalizeJlpt(
            _stringValue(
              data,
              ['jlpt', 'jlptLevel', 'level', 'JLPT_Level'],
              required: false,
            ),
          ) ??
          '',
      isFavorite: false,
      exampleSentence: _stringValue(
        data,
        ['example_jp', 'exampleSentence', 'example'],
        required: false,
      ),
      exampleMeaning: _stringValue(
        data,
        ['example_en', 'exampleMeaning', 'example_translation'],
        required: false,
      ),
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
    final normalized =
        value?.trim().toUpperCase().replaceFirst(RegExp(r'^JLPT[-_\s]*'), '') ??
            '';
    if (normalized.isEmpty) {
      return null;
    }
    return normalized.startsWith('N') ? normalized : 'N$normalized';
  }
}
