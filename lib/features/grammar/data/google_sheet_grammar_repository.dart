import 'dart:convert';
import 'dart:developer' as developer;

import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;

import '../domain/grammar_pattern.dart';
import 'grammar_repository.dart';

class GoogleSheetGrammarRepository implements GrammarRepository {
  GoogleSheetGrammarRepository({
    http.Client? client,
    Uri? csvUri,
  })  : _client = client,
        _csvUri = csvUri ?? _defaultCsvUri;

  static const String spreadsheetId =
      '1vl_IRVwh7FWgcT-C8fTQltTQWwx8ejRJG9HnCctW0BU';
  static const String grammarSheetName = 'Grammar';

  // The Grammar sheet is selected explicitly by name so the exported CSV always
  // matches the Grammar tab even if Google Sheets regenerates numeric gids.
  static const String csvUrl =
      'https://docs.google.com/spreadsheets/d/$spreadsheetId/gviz/tq?tqx=out:csv&sheet=$grammarSheetName';

  static final Uri _defaultCsvUri = Uri.parse(csvUrl);

  final http.Client? _client;
  final Uri _csvUri;

  @override
  Future<List<GrammarPattern>> fetchPatterns() async {
    developer.log(
      'Fetching Grammar CSV from $_csvUri',
      name: 'GoogleSheetGrammarRepository',
    );

    try {
      final client = _client;
      final response = client == null
          ? await http.get(_csvUri)
          : await client.get(_csvUri);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw GrammarRepositoryException(
          'Failed to load grammar CSV from $_csvUri. Status code: ${response.statusCode}',
        );
      }

      final csvText = utf8.decode(response.bodyBytes);
      final patterns = _parseCsv(csvText);
      developer.log(
        'GrammarRepository.fetchPatterns() returned ${patterns.length} patterns',
        name: 'GoogleSheetGrammarRepository',
      );

      if (patterns.isEmpty) {
        throw GrammarRepositoryException(
          'GrammarRepository.fetchPatterns() returned 0 patterns from $_csvUri.',
        );
      }

      return patterns;
    } catch (error, stackTrace) {
      developer.log(
        'Failed to fetch Grammar CSV from $_csvUri',
        name: 'GoogleSheetGrammarRepository',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<GrammarPattern?> fetchPatternById(String id) async {
    final patterns = await fetchPatterns();

    for (final pattern in patterns) {
      if (pattern.id == id) {
        return pattern;
      }
    }

    return null;
  }

  List<GrammarPattern> _parseCsv(String csvText) {
    final rows = const CsvToListConverter(
      shouldParseNumbers: false,
    ).convert(csvText);

    developer.log(
      'CSV rows.length: ${rows.length}',
      name: 'GoogleSheetGrammarRepository',
    );

    if (rows.isEmpty) {
      developer.log(
        'Parsed grammarPatterns.length: 0',
        name: 'GoogleSheetGrammarRepository',
      );
      return const [];
    }

    final headers = rows.first
        .map((header) => header.toString().trim())
        .toList(growable: false);

    final grammarPatterns = rows
        .skip(1)
        .where((row) => row.any((cell) => cell.toString().trim().isNotEmpty))
        .map((row) {
      final record = <String, String>{};

      for (var index = 0; index < headers.length; index++) {
        final value = index < row.length ? row[index].toString().trim() : '';
        record[headers[index]] = value;
      }

      return GrammarPattern(
        id: _requiredValue(record, 'id'),
        jlpt: _requiredValue(record, 'jlpt').toUpperCase(),
        grammar: _requiredValue(record, 'grammar'),
        meaningEn: record['meaning_en'] ?? '',
        meaningJa: record['meaning_ja'] ?? '',
        explanationEn: record['explanation_en'] ?? '',
        explanationJa: record['explanation_ja'] ?? '',
        exampleJp: record['example_jp'] ?? '',
        exampleEn: record['example_en'] ?? '',
        exampleJa: record['example_ja'] ?? '',
      );
    }).toList(growable: false);

    developer.log(
      'Parsed grammarPatterns.length: ${grammarPatterns.length}',
      name: 'GoogleSheetGrammarRepository',
    );

    return grammarPatterns;
  }

  String _requiredValue(Map<String, String> record, String columnName) {
    final value = record[columnName]?.trim() ?? '';
    if (value.isEmpty) {
      throw GrammarRepositoryException(
        'Grammar CSV is missing required "$columnName" value.',
      );
    }
    return value;
  }
}

class GrammarRepositoryException implements Exception {
  const GrammarRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
