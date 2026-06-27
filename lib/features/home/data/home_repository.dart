import 'package:flutter/material.dart';

import '../../../app/navigation/app_route.dart';
import '../domain/home_content.dart';

abstract interface class HomeRepository {
  Future<HomeContent> fetchHomeContent();
}

class MockHomeRepository implements HomeRepository {
  const MockHomeRepository();

  @override
  Future<HomeContent> fetchHomeContent() async {
    return HomeContent(
      levels: const [
        JlptLevelCardData(
          level: 'N5',
          title: LocalizedText(en: 'Beginner', ja: '入門'),
          description: LocalizedText(
            en: 'Start with daily words and basic grammar.',
            ja: '日常語彙と基本文法から始めましょう。',
          ),
          progress: 0.64,
        ),
        JlptLevelCardData(
          level: 'N4',
          title: LocalizedText(en: 'Elementary', ja: '初級'),
          description: LocalizedText(
            en: 'Build practical reading and listening skills.',
            ja: '実用的な読解・聴解力を伸ばします。',
          ),
          progress: 0.38,
        ),
        JlptLevelCardData(
          level: 'N3',
          title: LocalizedText(en: 'Intermediate', ja: '中級'),
          description: LocalizedText(
            en: 'Connect grammar, kanji, and real examples.',
            ja: '文法・漢字・実例をつなげて学習します。',
          ),
          progress: 0.22,
        ),
        JlptLevelCardData(
          level: 'N2',
          title: LocalizedText(en: 'Upper Intermediate', ja: '中上級'),
          description: LocalizedText(
            en: 'Practice longer passages and nuanced grammar.',
            ja: '長文と細かな文法表現を練習します。',
          ),
          progress: 0.12,
        ),
        JlptLevelCardData(
          level: 'N1',
          title: LocalizedText(en: 'Advanced', ja: '上級'),
          description: LocalizedText(
            en: 'Master advanced vocabulary and exam strategy.',
            ja: '高度な語彙と試験戦略を習得します。',
          ),
          progress: 0.06,
        ),
      ],
      learningMenuItems: [
        LearningMenuItemData(
          title: LocalizedText(en: 'Vocabulary', ja: '語彙'),
          subtitle: LocalizedText(en: 'Words by level', ja: 'レベル別の単語'),
          icon: Icons.menu_book_outlined,
          routePath: AppRoute.vocabulary.path,
        ),
        LearningMenuItemData(
          title: LocalizedText(en: 'Grammar', ja: '文法'),
          subtitle: LocalizedText(en: 'Patterns and examples', ja: '文型と例文'),
          icon: Icons.subject_outlined,
          routePath: AppRoute.grammar.path,
        ),
        LearningMenuItemData(
          title: LocalizedText(en: 'Kanji', ja: '漢字'),
          subtitle: LocalizedText(en: 'Readings and meanings', ja: '読み方と意味'),
          icon: Icons.translate_outlined,
          routePath: AppRoute.kanji.path,
        ),
        LearningMenuItemData(
          title: LocalizedText(en: 'Mock Exam', ja: '模擬試験'),
          subtitle: LocalizedText(en: 'Timed practice tests', ja: '時間制限付き演習'),
          icon: Icons.quiz_outlined,
          routePath: AppRoute.mockExam.path,
        ),
      ],
      studyStatus: const StudyStatusData(
        studyTimeMinutes: 45,
        studyDays: 12,
        accuracyPercent: 86,
        goalProgress: 0.72,
      ),
      recentHistory: const [
        StudyHistoryItemData(
          title: LocalizedText(en: 'N5 Vocabulary Review', ja: 'N5 語彙復習'),
          subtitle: LocalizedText(en: '32 words practiced', ja: '32語を練習'),
          completedAtLabel: 'Today',
          accuracyPercent: 91,
          icon: Icons.menu_book_outlined,
        ),
        StudyHistoryItemData(
          title: LocalizedText(en: 'Grammar: particles', ja: '文法：助詞'),
          subtitle: LocalizedText(en: '10 questions completed', ja: '10問完了'),
          completedAtLabel: 'Yesterday',
          accuracyPercent: 80,
          icon: Icons.subject_outlined,
        ),
        StudyHistoryItemData(
          title: LocalizedText(en: 'Kanji quick practice', ja: '漢字クイック練習'),
          subtitle: LocalizedText(en: '15 kanji reviewed', ja: '15字を復習'),
          completedAtLabel: '2 days ago',
          accuracyPercent: 87,
          icon: Icons.translate_outlined,
        ),
      ],
    );
  }
}
