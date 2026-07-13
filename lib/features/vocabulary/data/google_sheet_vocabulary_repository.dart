import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/vocabulary_word.dart';
import 'vocabulary_repository.dart';

class GoogleSheetVocabularyRepository implements VocabularyRepository {
  GoogleSheetVocabularyRepository({
    http.Client? client,
    String? spreadsheetId,
    String? apiKey,
  })  : _client = client,
        _spreadsheetId = spreadsheetId ?? _defaultSpreadsheetId,
        _apiKey = apiKey ?? _defaultApiKey;

  static const String _defaultSpreadsheetId =
      '1vl_IRVwh7FWgcT-C8fTQltTQWwx8ejRJG9HnCctW0BU';
  static const String _defaultApiKey = 'AIzaSyBJUdsHFsKKcgpnJJH81Qks5dessKJIWQo';
  static const List<String> _jlptSheets = ['N5', 'N4', 'N3', 'N2', 'N1'];

  final http.Client? _client;
  final String _spreadsheetId;
  final String _apiKey;

  @override
  Future<List<VocabularyWord>> fetchWords({String? jlpt}) async {
    final levels =
        jlpt == null || jlpt == 'All' ? _jlptSheets : [jlpt.toUpperCase()];
    final wordsBySheet = await Future.wait(levels.map(_fetchSheetWords));
    return wordsBySheet.expand((words) => words).toList(growable: false);
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
  Future<VocabularyWord?> fetchRandomWord({String? excludeWordId, String? jlpt}) async {
    final words = await fetchWords(jlpt: jlpt);
    if (words.isEmpty) {
      return null;
    }

    final pool = words
        .where((word) => excludeWordId == null || word.id != excludeWordId)
        .toList(growable: false);
    if (pool.isEmpty) {
      return null;
    }
    pool.shuffle();
    return pool.first;
  }

  Future<List<VocabularyWord>> _fetchSheetWords(String sheetName) async {
    if (!_jlptSheets.contains(sheetName)) {
      throw ArgumentError.value(
        sheetName,
        'sheetName',
        'Expected one of $_jlptSheets.',
      );
    }

    final uri = Uri.https(
      'sheets.googleapis.com',
      '/v4/spreadsheets/$_spreadsheetId/values/$sheetName',
      {'key': _apiKey},
    );
    final client = _client;
    final response =
        client == null ? await http.get(uri) : await client.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to load vocabulary from Google Sheets API sheet=$sheetName. '
        'Status code: ${response.statusCode}',
      );
    }

    final payload =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final values = (payload['values'] as List<dynamic>? ?? const [])
        .map((row) => (row as List<dynamic>).cast<dynamic>())
        .toList(growable: false);
    return _parseRows(values, fallbackJlpt: sheetName);
  }

  List<VocabularyWord> _parseRows(
    List<List<dynamic>> rows, {
    required String fallbackJlpt,
  }) {
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

      final jlpt = (record['jlpt']?.trim().isNotEmpty ?? false)
          ? record['jlpt']!.trim().toUpperCase()
          : fallbackJlpt;
      final meaningEn = record['meaning_en']?.trim() ?? '';
      final meaningJa = record['meaning_ja']?.trim() ?? '';
      final exampleEn = record['example_en']?.trim() ?? '';
      final exampleJa = record['example_ja']?.trim() ?? '';

      return VocabularyWord(
        id: _requiredValue(record, 'id'),
        category: record['category'] ?? '',
        word: _requiredValue(record, 'word'),
        reading: record['reading'] ?? '',
        romaji: record['romaji'] ?? '',
        meaning: meaningEn.isNotEmpty ? meaningEn : meaningJa,
        meaningEn: meaningEn,
        meaningJa: meaningJa,
        partOfSpeech: record['part_of_speech'] ?? '',
        jlptLevel: jlpt,
        isFavorite: false,
        exampleSentence: record['example_jp'] ?? '',
        exampleMeaning: exampleEn.isNotEmpty ? exampleEn : exampleJa,
        exampleEn: exampleEn,
        exampleJa: exampleJa,
      );
    }).toList(growable: false);
  }

  String _requiredValue(Map<String, String> record, String columnName) {
    final value = record[columnName]?.trim() ?? '';
    if (value.isEmpty) {
      throw Exception(
        'Vocabulary Google Sheets row is missing required "$columnName" value.',
      );
    }
    return value;
  }
}
