import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../domain/vocabulary_word.dart';
import 'vocabulary_repository.dart';

class GoogleSheetVocabularyRepository implements VocabularyRepository {
  GoogleSheetVocabularyRepository({
    http.Client? client,
    String? spreadsheetId,
    Uri? csvUri,
  })  : _client = client,
        _spreadsheetId = spreadsheetId ?? _defaultSpreadsheetId,
        _csvUri = csvUri ?? _defaultCsvUri;

  static const String _defaultSpreadsheetId =
      '1vl_IRVwh7FWgcT-C8fTQltTQWwx8ejRJG9HnCctW0BU';
  static const List<String> _jlptSheets = ['N5', 'N4', 'N3', 'N2', 'N1'];
  static const String csvUrl =
      'https://docs.google.com/spreadsheets/d/$_defaultSpreadsheetId/export?format=csv&gid=0';

  static final Uri _defaultCsvUri = Uri.parse(csvUrl);

  final http.Client? _client;
  final String _spreadsheetId;
  final Uri _csvUri;

  @override
  Future<List<VocabularyWord>> fetchWords({String? jlpt}) async {
    final levels =
        jlpt == null || jlpt == 'All' ? _jlptSheets : [jlpt.toUpperCase()];
    final all = <VocabularyWord>[];

    for (final sheet in levels) {
      try {
        final words = await _fetchSheetWords(sheet);
        all.addAll(words);
      } catch (e, st) {
        debugPrint('Sheet $sheet failed: $e');
        debugPrintStack(stackTrace: st);
      }
    }

    return all;
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
  Future<VocabularyWord?> fetchRandomWord({
    String? excludeWordId,
    String? jlpt,
  }) async {
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

    final uri = _publishedCsvUri(sheetName);
    debugPrint('Loading: $sheetName');
    debugPrint('URL: $uri');
    final client = _client;
    final response = client == null
        ? await http.get(uri)
        : await client.get(uri);
    debugPrint('Status: ${response.statusCode}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to load vocabulary CSV sheet=$sheetName. '
        'Status code: ${response.statusCode}',
      );
    }

    final csvText = utf8.decode(response.bodyBytes);
    final words = _parseCsv(csvText, fallbackJlpt: sheetName);
    debugPrint('Words: ${words.length}');
    return words;
  }

  Uri _publishedCsvUri(String sheetName) {
    if (sheetName == 'N5') {
      return _csvUri;
    }

    return Uri.parse(
      'https://docs.google.com/spreadsheets/d/$_spreadsheetId/export?format=csv&sheet=$sheetName',
    );
  }

  List<VocabularyWord> _parseCsv(
    String csvText, {
    required String fallbackJlpt,
  }) {
    final rows = const CsvToListConverter().convert(csvText);
    debugPrint('Rows: ${rows.length}');

    if (rows.isEmpty) {
      return const [];
    }

    final headers = rows.first
        .map((header) => header.toString().trim())
        .toList(growable: false);
    debugPrint(headers.toString());

    return rows
        .skip(1)
        .where((row) => row.any((cell) => cell.toString().trim().isNotEmpty))
        .map((row) {
      final record = <String, String>{};

      for (var index = 0; index < headers.length; index++) {
        final value = index < row.length ? row[index].toString().trim() : '';
        record[headers[index]] = value;
      }
      debugPrint(record.toString());

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
        'Vocabulary CSV row is missing required "$columnName" value.',
      );
    }
    return value;
  }
}
