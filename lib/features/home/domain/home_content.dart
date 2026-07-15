import 'package:flutter/material.dart';

@immutable
class LocalizedText {
  const LocalizedText({required this.en, required this.ja});

  final String en;
  final String ja;
}

@immutable
class JlptLevelCardData {
  const JlptLevelCardData({
    required this.level,
    required this.title,
    required this.description,
    required this.progress,
  });

  final String level;
  final LocalizedText title;
  final LocalizedText description;
  final double progress;
}

@immutable
class LearningMenuItemData {
  const LearningMenuItemData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.routePath,
  });

  final LocalizedText title;
  final LocalizedText subtitle;
  final IconData icon;
  final String routePath;
}

@immutable
class StudyStatusData {
  const StudyStatusData({
    required this.studyTimeLabel,
    required this.studyDays,
    required this.progressPercent,
    required this.goalProgress,
  });

  final String studyTimeLabel;
  final int studyDays;
  final int progressPercent;
  final double goalProgress;
}

@immutable
class StudyHistoryItemData {
  const StudyHistoryItemData({
    required this.title,
    required this.subtitle,
    required this.completedAtLabel,
    required this.accuracyPercent,
    required this.icon,
  });

  final LocalizedText title;
  final LocalizedText subtitle;
  final String completedAtLabel;
  final int accuracyPercent;
  final IconData icon;
}

@immutable
class HomeContent {
  const HomeContent({
    required this.levels,
    required this.learningMenuItems,
    required this.studyStatus,
    required this.recentHistory,
  });

  final List<JlptLevelCardData> levels;
  final List<LearningMenuItemData> learningMenuItems;
  final StudyStatusData studyStatus;
  final List<StudyHistoryItemData> recentHistory;
}
