import 'package:flutter/foundation.dart';

@immutable
class StudyStats {
  const StudyStats({
    required this.totalStudySeconds,
    required this.studiedDates,
    required this.solvedVocabularyIds,
    required this.solvedGrammarIds,
    required this.lastStudiedAt,
  });

  factory StudyStats.empty() => const StudyStats(
        totalStudySeconds: 0,
        studiedDates: <String>{},
        solvedVocabularyIds: <String>{},
        solvedGrammarIds: <String>{},
        lastStudiedAt: null,
      );

  final int totalStudySeconds;
  final Set<String> studiedDates;
  final Set<String> solvedVocabularyIds;
  final Set<String> solvedGrammarIds;
  final DateTime? lastStudiedAt;

  int get learningDays => studiedDates.length;

  StudyStats copyWith({
    int? totalStudySeconds,
    Set<String>? studiedDates,
    Set<String>? solvedVocabularyIds,
    Set<String>? solvedGrammarIds,
    DateTime? lastStudiedAt,
    bool clearLastStudiedAt = false,
  }) {
    return StudyStats(
      totalStudySeconds: totalStudySeconds ?? this.totalStudySeconds,
      studiedDates: studiedDates ?? this.studiedDates,
      solvedVocabularyIds: solvedVocabularyIds ?? this.solvedVocabularyIds,
      solvedGrammarIds: solvedGrammarIds ?? this.solvedGrammarIds,
      lastStudiedAt: clearLastStudiedAt ? null : lastStudiedAt ?? this.lastStudiedAt,
    );
  }
}

@immutable
class StudyStatsSummary {
  const StudyStatsSummary({
    required this.stats,
    required this.totalVocabularyQuestions,
    required this.totalGrammarQuestions,
  });

  final StudyStats stats;
  final int totalVocabularyQuestions;
  final int totalGrammarQuestions;

  int get totalStudySeconds => stats.totalStudySeconds;
  int get learningDays => stats.learningDays;
  int get solvedQuestionCount => stats.solvedVocabularyIds.length + stats.solvedGrammarIds.length;
  int get totalQuestionCount => totalVocabularyQuestions + totalGrammarQuestions;
  double get progress => totalQuestionCount == 0 ? 0 : (solvedQuestionCount / totalQuestionCount).clamp(0, 1).toDouble();
  int get progressPercent => (progress * 100).round();

  String get formattedStudyTime {
    final totalMinutes = totalStudySeconds ~/ 60;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    return '${minutes}m';
  }
}
