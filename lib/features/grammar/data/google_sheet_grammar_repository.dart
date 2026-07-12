import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
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
    debugPrint(
      'GoogleSheetGrammarRepository.fetchPatterns(): HTTP開始 $_csvUri',
    );

    try {
      final client = _client;
      final response = client == null
          ? await http.get(_csvUri)
          : await client.get(_csvUri);
      debugPrint('GoogleSheetGrammarRepository.fetchPatterns(): HTTP終了');
      debugPrint(
        'GoogleSheetGrammarRepository.fetchPatterns(): statusCode=${response.statusCode}',
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw GrammarRepositoryException(
          'Failed to load grammar CSV from $_csvUri. Status code: ${response.statusCode}',
        );
      }

      final csvText = utf8.decode(response.bodyBytes);
      debugPrint('GoogleSheetGrammarRepository.fetchPatterns(): CSV取得完了');
      debugPrint(
        'GoogleSheetGrammarRepository.fetchPatterns(): CSV文字数=${csvText.length}',
      );
      debugPrint(
        'GoogleSheetGrammarRepository.fetchPatterns(): response.body.substring(0, 300)=${response.body.substring(0, response.body.length < 300 ? response.body.length : 300)}',
      );
      final patterns = _parseCsv(csvText);
      debugPrint(
        'GoogleSheetGrammarRepository.fetchPatterns(): GrammarPattern件数=${patterns.length}',
      );

      if (patterns.isEmpty) {
        throw GrammarRepositoryException(
          'GrammarRepository.fetchPatterns() returned 0 patterns from $_csvUri.',
        );
      }

      return patterns;
    } catch (error, stackTrace) {
      debugPrint(
        'GoogleSheetGrammarRepository.fetchPatterns(): exception=$error',
      );
      debugPrint(stackTrace.toString());
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

    debugPrint(
      'GoogleSheetGrammarRepository.fetchPatterns(): rows.length=${rows.length}',
    );
    if (rows.isNotEmpty) {
      debugPrint(
        'GoogleSheetGrammarRepository.fetchPatterns(): rows.first=${rows.first}',
      );
    }

    if (rows.isEmpty) {
      debugPrint(
        'GoogleSheetGrammarRepository.fetchPatterns(): GrammarPattern件数=0',
      );
      debugPrint(
        'GoogleSheetGrammarRepository.fetchPatterns(): rows.length=0, 成功件数=0, スキップ件数=0',
      );
      return const [];
    }

    final grammarPatterns = <GrammarPattern>[];
    var skippedCount = 0;

    for (final row in rows.skip(1)) {
      if (row.length < 10) {
        skippedCount++;
        continue;
      }

      final grammar = _csvValue(row, 2);
      if (grammar.isEmpty) {
        skippedCount++;
        continue;
      }

      grammarPatterns.add(
        GrammarPattern(
          id: _csvValue(row, 0),
          jlpt: _csvValue(row, 1).toUpperCase(),
          grammar: grammar,
          meaningEn: _csvValue(row, 3),
          meaningJa: _csvValue(row, 4),
          explanationEn: _csvValue(row, 5),
          explanationJa: _csvValue(row, 6),
          exampleJp: _csvValue(row, 7),
          exampleEn: _csvValue(row, 8),
          exampleJa: _csvValue(row, 9),
        ),
      );
    }

    debugPrint(
      'GoogleSheetGrammarRepository.fetchPatterns(): パース成功件数=${grammarPatterns.length}',
    );
    if (grammarPatterns.isNotEmpty) {
      debugPrint(
        'GoogleSheetGrammarRepository.fetchPatterns(): first GrammarPattern=${grammarPatterns.first}',
      );
    }
    debugPrint(
      'GoogleSheetGrammarRepository.fetchPatterns(): rows.length=${rows.length}, 成功件数=${grammarPatterns.length}, スキップ件数=$skippedCount',
    );

    return grammarPatterns;
  }

  String _csvValue(List<dynamic> row, int index) => row[index].toString().trim();
}

class GrammarRepositoryException implements Exception {
  const GrammarRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
