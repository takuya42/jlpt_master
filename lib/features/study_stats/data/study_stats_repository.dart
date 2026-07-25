import 'package:shared_preferences/shared_preferences.dart';

import '../domain/study_stats.dart';

class StudyStatsRepository {
  StudyStatsRepository({SharedPreferencesAsync? preferences, String? userId})
      : _preferences = preferences ?? SharedPreferencesAsync(),
        _prefix = userId == null ? 'anonymous.' : 'user.$userId.';

  static const _totalStudySecondsKey = 'studyStats.totalStudySeconds';
  static const _studiedDatesKey = 'studyStats.studiedDates';
  static const _solvedVocabularyIdsKey = 'studyStats.solvedVocabularyIds';
  static const _solvedGrammarIdsKey = 'studyStats.solvedGrammarIds';
  static const _lastStudiedAtKey = 'studyStats.lastStudiedAt';

  final SharedPreferencesAsync _preferences;
  final String _prefix;

  String _key(String key) => '$_prefix$key';

  Future<StudyStats> load() async {
    final lastStudiedAtValue = await _preferences.getString(_key(_lastStudiedAtKey));
    return StudyStats(
      totalStudySeconds: await _preferences.getInt(_key(_totalStudySecondsKey)) ?? 0,
      studiedDates: (await _preferences.getStringList(_key(_studiedDatesKey)) ?? const <String>[]).toSet(),
      solvedVocabularyIds: (await _preferences.getStringList(_key(_solvedVocabularyIdsKey)) ?? const <String>[]).toSet(),
      solvedGrammarIds: (await _preferences.getStringList(_key(_solvedGrammarIdsKey)) ?? const <String>[]).toSet(),
      lastStudiedAt: lastStudiedAtValue == null ? null : DateTime.tryParse(lastStudiedAtValue),
    );
  }

  Future<StudyStats> addStudyTime(Duration duration, {DateTime? studiedAt}) {
    return _update((current) {
      final now = studiedAt ?? DateTime.now();
      final addedSeconds = duration.inSeconds < 0 ? 0 : duration.inSeconds;
      return current.copyWith(
        totalStudySeconds: current.totalStudySeconds + addedSeconds,
        studiedDates: {...current.studiedDates, _dateKey(now)},
        lastStudiedAt: now,
      );
    });
  }

  Future<StudyStats> markVocabularySolved(String vocabularyId, {DateTime? studiedAt}) {
    return _markSolved(vocabularyId, isVocabulary: true, studiedAt: studiedAt);
  }

  Future<StudyStats> markGrammarSolved(String grammarId, {DateTime? studiedAt}) {
    return _markSolved(grammarId, isVocabulary: false, studiedAt: studiedAt);
  }

  Future<StudyStats> _markSolved(String id, {required bool isVocabulary, DateTime? studiedAt}) {
    return _update((current) {
      final now = studiedAt ?? DateTime.now();
      return current.copyWith(
        studiedDates: {...current.studiedDates, _dateKey(now)},
        solvedVocabularyIds: isVocabulary ? {...current.solvedVocabularyIds, id} : current.solvedVocabularyIds,
        solvedGrammarIds: isVocabulary ? current.solvedGrammarIds : {...current.solvedGrammarIds, id},
        lastStudiedAt: now,
      );
    });
  }

  Future<StudyStats> _update(StudyStats Function(StudyStats current) change) async {
    final next = change(await load());
    await save(next);
    return next;
  }

  Future<void> save(StudyStats stats) async {
    await _preferences.setInt(_key(_totalStudySecondsKey), stats.totalStudySeconds);
    await _preferences.setStringList(_key(_studiedDatesKey), stats.studiedDates.toList()..sort());
    await _preferences.setStringList(_key(_solvedVocabularyIdsKey), stats.solvedVocabularyIds.toList()..sort());
    await _preferences.setStringList(_key(_solvedGrammarIdsKey), stats.solvedGrammarIds.toList()..sort());
    final lastStudiedAt = stats.lastStudiedAt;
    if (lastStudiedAt == null) {
      await _preferences.remove(_key(_lastStudiedAtKey));
    } else {
      await _preferences.setString(_key(_lastStudiedAtKey), lastStudiedAt.toIso8601String());
    }
  }

  /// Deletes the obsolete device-wide stats cache. Firestore is the source of
  /// truth for signed-in home statistics.
  Future<void> clear() async {
    await Future.wait([
      _preferences.remove(_key(_totalStudySecondsKey)),
      _preferences.remove(_key(_studiedDatesKey)),
      _preferences.remove(_key(_solvedVocabularyIdsKey)),
      _preferences.remove(_key(_solvedGrammarIdsKey)),
      _preferences.remove(_key(_lastStudiedAtKey)),
      // Also purge device-wide keys created by older app versions.
      _preferences.remove(_totalStudySecondsKey),
      _preferences.remove(_studiedDatesKey),
      _preferences.remove(_solvedVocabularyIdsKey),
      _preferences.remove(_solvedGrammarIdsKey),
      _preferences.remove(_lastStudiedAtKey),
    ]);
  }

  static String _dateKey(DateTime date) {
    final local = date.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }
}
