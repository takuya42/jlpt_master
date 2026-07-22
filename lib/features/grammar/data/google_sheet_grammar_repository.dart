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

  // This is the published Grammar-only data source. Do not replace it with the
  // spreadsheet used by GoogleSheetVocabularyRepository: an unknown `sheet`
  // parameter can silently fall back to that spreadsheet's first vocabulary
  // tab.
  static const String csvUrl =
      'https://docs.google.com/spreadsheets/d/e/2PACX-1vRmRT1zho5hgMAfNv7mDeukWnAh2dLC87TjNTOZJh1p7KzB7c1KjxmnqQQE5ZZ5lwvDVjpJryPccLFr/pub?gid=0&single=true&output=csv';
  static const List<String> _jlptSheets = ['N5', 'N4', 'N3', 'N2', 'N1'];

  static final Uri _defaultCsvUri = Uri.parse(csvUrl);

  final http.Client? _client;
  final Uri _csvUri;

  @override
  Future<List<GrammarPattern>> fetchPatterns() async {
    try {
      final patterns = <GrammarPattern>[];
      for (final sheet in _jlptSheets) {
        patterns.addAll(await _fetchSheetPatterns(sheet));
      }

      debugPrint(
        'GoogleSheetGrammarRepository.fetchPatterns(): patterns.length=${patterns.length}',
      );
      _logJlptCounts(patterns);

      return patterns;
    } catch (error, stackTrace) {
      debugPrint(
        'GoogleSheetGrammarRepository.fetchPatterns(): exception=$error',
      );
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }

  Future<List<GrammarPattern>> _fetchSheetPatterns(String sheetName) async {
    final uri = _sheetCsvUri(sheetName);
    debugPrint(
      'GoogleSheetGrammarRepository.fetchPatterns(): sheet=$sheetName HTTP開始 $uri',
    );
    final client = _client;
    final response = client == null ? await http.get(uri) : await client.get(uri);
    debugPrint(
      'GoogleSheetGrammarRepository.fetchPatterns(): sheet=$sheetName '
      'statusCode=${response.statusCode}',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw GrammarRepositoryException(
        'Failed to load grammar CSV sheet=$sheetName from $uri. '
        'Status code: ${response.statusCode}',
      );
    }

    final patterns = parseText(utf8.decode(response.bodyBytes));
    debugPrint(
      'GoogleSheetGrammarRepository.fetchPatterns(): '
      'sheet=$sheetName patterns.length=${patterns.length}',
    );
    return patterns;
  }

  Uri _sheetCsvUri(String sheetName) {
    final query = Map<String, String>.from(_csvUri.queryParameters)
      ..remove('gid')
      ..remove('single')
      ..['output'] = 'csv'
      ..['sheet'] = sheetName;
    return _csvUri.replace(queryParameters: query);
  }

  void _logJlptCounts(List<GrammarPattern> patterns) {
    final counts = <String, int>{};
    for (final level in _jlptSheets) {
      final count = patterns.where((pattern) => pattern.jlpt == level).length;
      if (count > 0) counts[level] = count;
    }
    debugPrint(
      'GoogleSheetGrammarRepository.fetchPatterns(): JLPT別取得件数=$counts',
    );
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
    List<List<dynamic>> rows;
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
      debugPrint(
        'GoogleSheetGrammarRepository.fetchPatterns(): header=${rows.first}',
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
    const requiredHeaders = <String>{
      'id',
      'jlpt',
      'grammar',
      'meaning_en',
      'meaning_ja',
      'explanation_en',
      'explanation_ja',
      'example_jp',
      'example_en',
      'example_ja',
    };
    final missingHeaders = requiredHeaders.difference(headers.keys.toSet());
    if (missingHeaders.isNotEmpty) {
      throw GrammarRepositoryException(
        'Grammar CSV has an unexpected header. Missing: '
        '${missingHeaders.join(', ')}. Actual: ${rows.first}',
      );
    }
    final normalizedHeaders = rows.first
        .map((header) => _headerName(header.toString()))
        .toList(growable: false);

    final grammarPatterns = <GrammarPattern>[];
    var skippedCount = 0;

    for (final row in rows.skip(1)) {
      final map = <String, String>{};
      for (var index = 0; index < normalizedHeaders.length; index++) {
        map[normalizedHeaders[index]] = _csvValue(row, index);
      }
      if ((map['grammar'] ?? '').isEmpty || (map['jlpt'] ?? '').isEmpty) {
        skippedCount++;
        continue;
      }

      try {
        final pattern = GrammarPattern.fromCsv(row, normalizedHeaders);
        grammarPatterns.add(pattern);
        debugPrint('${pattern.jlpt} ${pattern.grammar}');
      } on FormatException {
        skippedCount++;
      }
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
}

class GrammarRepositoryException implements Exception {
  const GrammarRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
