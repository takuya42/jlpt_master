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
      final patterns = parseText(csvText);
      debugPrint(
        'GoogleSheetGrammarRepository.fetchPatterns(): patterns.length=${patterns.length}',
      );

      if (patterns.isEmpty) {
        debugPrint(
          'GoogleSheetGrammarRepository.fetchPatterns(): patterns.length=0 のためCSV内容を出力します',
        );
        debugPrint(
          'GoogleSheetGrammarRepository.fetchPatterns(): csvText=$csvText',
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

  /// Parses the complete export. Google Sheets normally returns CSV, while a
  /// checked-in/exported grammar.tsv uses tabs; both formats are supported.
  List<GrammarPattern> parseText(String text) {
    final lines = text.split(RegExp(r'\r?\n'));
    final firstLine = lines.isEmpty ? '' : lines.first;
    final delimiter = firstLine.contains('\t') ? '\t' : ',';
    final converter = CsvToListConverter(
      fieldDelimiter: delimiter,
      shouldParseNumbers: false,
    );
    final List<List<dynamic>> rows;
    try {
      rows = converter.convert(text);
    } on FormatException catch (error) {
      // One corrupt record must not prevent all records after it from loading.
      debugPrint(
        'GoogleSheetGrammarRepository.parseText(): full parse failed; '
        'retrying each physical row: $error',
      );
      rows = <List<dynamic>>[];
      for (var lineNumber = 0; lineNumber < lines.length; lineNumber++) {
        final line = lines[lineNumber];
        if (line.trim().isEmpty) continue;
        try {
          rows.add(converter.convert(line).single);
        } on FormatException catch (rowError) {
          debugPrint(
            'GoogleSheetGrammarRepository.parseText(): '
            'skipped malformed line ${lineNumber + 1}: $rowError',
          );
        }
      }
    }

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

    final headers = <String, int>{
      for (var index = 0; index < rows.first.length; index++)
        _headerName(rows.first[index].toString()): index,
    };
    int column(List<String> names, int fallback) {
      for (final name in names) {
        final index = headers[_headerName(name)];
        if (index != null) return index;
      }
      return fallback;
    }

    final idColumn = column(const ['id'], 0);
    final levelColumn = column(const ['jlpt', 'level', 'jlpt_level'], 1);
    final grammarColumn = column(const ['grammar', 'pattern'], 2);
    final meaningEnColumn = column(const ['meaning_en', 'english meaning'], 3);
    final meaningJaColumn = column(const ['meaning_ja', 'japanese meaning'], 4);
    final explanationEnColumn = column(const ['explanation_en'], 5);
    final explanationJaColumn = column(const ['explanation_ja'], 6);
    final exampleJpColumn = column(const ['example_jp', 'example_ja'], 7);
    final exampleEnColumn = column(const ['example_en'], 8);
    final exampleJaColumn = column(const ['example_translation_ja'], 9);
    final requiredColumn = [idColumn, levelColumn, grammarColumn].reduce(
      (largest, value) => value > largest ? value : largest,
    );

    final grammarPatterns = <GrammarPattern>[];
    var skippedCount = 0;

    for (final row in rows.skip(1)) {
      if (row.length <= requiredColumn) {
        skippedCount++;
        continue;
      }

      final grammar = _csvValue(row, grammarColumn);
      final level = _normalizeJlpt(_csvValue(row, levelColumn));
      if (grammar.isEmpty || level == null) {
        skippedCount++;
        continue;
      }

      grammarPatterns.add(
        GrammarPattern(
          id: _csvValue(row, idColumn),
          jlpt: level,
          grammar: grammar,
          meaningEn: _csvValue(row, meaningEnColumn),
          meaningJa: _csvValue(row, meaningJaColumn),
          explanationEn: _csvValue(row, explanationEnColumn),
          explanationJa: _csvValue(row, explanationJaColumn),
          exampleJp: _csvValue(row, exampleJpColumn),
          exampleEn: _csvValue(row, exampleEnColumn),
          exampleJa: _csvValue(row, exampleJaColumn),
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
    final counts = <String, int>{
      for (final level in const ['N5', 'N4', 'N3', 'N2', 'N1']) level: 0,
    };
    for (final pattern in grammarPatterns) {
      counts[pattern.jlpt] = (counts[pattern.jlpt] ?? 0) + 1;
    }
    debugPrint(
      'GoogleSheetGrammarRepository.fetchPatterns(): JLPT別取得件数=$counts',
    );

    return grammarPatterns;
  }

  String _csvValue(List<dynamic> row, int index) =>
      index < row.length ? row[index].toString().trim() : '';

  String _headerName(String value) => value
      .replaceFirst('\ufeff', '')
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[\s-]+'), '_');

  String? _normalizeJlpt(String value) {
    final normalized = value.trim().toUpperCase();
    final match = RegExp(r'(?:JLPT\s*)?N?\s*([1-5])', caseSensitive: false)
        .firstMatch(normalized);
    return match == null ? null : 'N${match.group(1)}';
  }
}

class GrammarRepositoryException implements Exception {
  const GrammarRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
