import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;

import '../domain/vocabulary_word.dart';
import 'vocabulary_repository.dart';

class GoogleSheetVocabularyRepository implements VocabularyRepository {
  GoogleSheetVocabularyRepository({
    http.Client? client,
    Uri? csvUri,
  })  : _client = client,
        _csvUri = csvUri ?? _defaultCsvUri;

  static final Uri _defaultCsvUri = Uri.parse(
    'https://docs.google.com/spreadsheets/d/1vl_IRVwh7FWgcT-C8fTQltTQWwx8ejRJG9HnCctW0BU/export?format=csv&gid=0',
  );

  final http.Client? _client;
  final Uri _csvUri;

  @override
  Future<List<VocabularyWord>> fetchWords() async {
    final client = _client;
    final response = client == null
        ? await http.get(_csvUri)
        : await client.get(_csvUri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to load vocabulary CSV. Status code: ${response.statusCode}',
      );
    }

    final csvText = utf8.decode(response.bodyBytes);
    return _parseCsv(csvText);
  }

  @override
  Future<VocabularyWord?> fetchWordById(String id) async {
    final words = await fetchWords();

    for (final word in words) {
      if (word.id == id) {
        return word;
      }
    }

    return null;
  }

  @override
  Future<VocabularyWord?> fetchRandomWord({String? excludeWordId}) async {
    final words = await fetchWords();
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
    pool.shuffle();
    return pool.first;
  }

  List<VocabularyWord> _parseCsv(String csvText) {
    final rows = const CsvToListConverter(
      shouldParseNumbers: false,
    ).convert(csvText);

    if (rows.isEmpty) {
      return const [];
    }

    final headers = rows.first
        .map((header) => header.toString().trim())
        .toList(growable: false);

    return rows
        .skip(1)
        .where((row) => row.any((cell) => cell.toString().trim().isNotEmpty))
        .map((row) {
      final record = <String, String>{};

      for (var index = 0; index < headers.length; index++) {
        final value = index < row.length ? row[index].toString().trim() : '';
        record[headers[index]] = value;
      }

      return VocabularyWord(
        id: _requiredValue(record, 'id'),
        word: _requiredValue(record, 'word'),
        reading: record['reading'] ?? '',
        meaning: _meaning(record),
        partOfSpeech: record['part_of_speech'] ?? '',
        jlptLevel: _requiredValue(record, 'jlpt').toUpperCase(),
        isFavorite: false,
        exampleSentence: record['example_jp'] ?? '',
        exampleMeaning: _exampleMeaning(record),
      );
    }).toList(growable: false);
  }

  String _requiredValue(Map<String, String> record, String columnName) {
    final value = record[columnName]?.trim() ?? '';
    if (value.isEmpty) {
      throw Exception(
        'Vocabulary CSV is missing required "$columnName" value.',
      );
    }
    return value;
  }

  String _meaning(Map<String, String> record) {
    final english = record['meaning_en']?.trim() ?? '';
    if (english.isNotEmpty) {
      return english;
    }
    return record['meaning_ja']?.trim() ?? '';
  }

  String _exampleMeaning(Map<String, String> record) {
    final english = record['example_en']?.trim() ?? '';
    if (english.isNotEmpty) {
      return english;
    }
    return record['example_ja']?.trim() ?? '';
  }
}
