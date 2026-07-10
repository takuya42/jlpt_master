import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

class UserLearningRepository {
  UserLearningRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;
  DocumentReference<Map<String, dynamic>>? get _userRef => _uid == null ? null : _firestore.collection('users').doc(_uid);

  Stream<Set<String>> watchFavoriteIds(String type) {
    final ref = _userRef;
    if (ref == null) return Stream.value(<String>{});
    return ref.collection('favorites').where('type', isEqualTo: type).snapshots().map((s) => s.docs.map((d) => d.id).toSet());
  }

  Future<void> setFavorite({required String type, required String itemId, required bool isFavorite}) async {
    final ref = _userRef;
    if (ref == null) return;
    final doc = ref.collection('favorites').doc(itemId);
    if (isFavorite) {
      await doc.set({'type': type, 'itemId': itemId, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    } else {
      await doc.delete();
    }
  }

  Future<void> recordVocabularyView(String wordId, {String? jlptLevel}) async {
    final ref = _userRef;
    if (ref == null) return;
    final now = FieldValue.serverTimestamp();
    await ref.collection('vocabulary_history').doc(wordId).set({
      'wordId': wordId,
      if (jlptLevel != null) 'jlptLevel': jlptLevel,
      'lastViewedAt': now,
      'views': FieldValue.increment(1),
      'updatedAt': now,
    }, SetOptions(merge: true));
    await ref.collection('study_progress').doc('vocabulary').set({'lastViewedWordId': wordId, 'updatedAt': now}, SetOptions(merge: true));
    await _incrementStat('vocabularyCount');
  }

  Future<void> recordGrammarStudy(String grammarId, {String? jlptLevel}) async {
    final ref = _userRef;
    if (ref == null) return;
    await ref.collection('grammar_history').doc(grammarId).set({
      'grammarId': grammarId,
      if (jlptLevel != null) 'jlptLevel': jlptLevel,
      'studiedAt': FieldValue.serverTimestamp(),
      'attempts': FieldValue.increment(1),
    }, SetOptions(merge: true));
    await _incrementStat('grammarCount');
  }

  Stream<LearningStatistics> watchStatistics({required Map<String, int> totalQuestionsByLevel}) {
    final ref = _userRef;
    if (ref == null) return Stream.value(LearningStatistics.empty(totalQuestionsByLevel: totalQuestionsByLevel));

    late StreamController<LearningStatistics> controller;
    DocumentSnapshot<Map<String, dynamic>>? summarySnapshot;
    QuerySnapshot<Map<String, dynamic>>? vocabularySnapshot;
    QuerySnapshot<Map<String, dynamic>>? grammarSnapshot;
    final subscriptions = <StreamSubscription<dynamic>>[];

    void emitIfReady() {
      if (summarySnapshot == null || vocabularySnapshot == null || grammarSnapshot == null || controller.isClosed) {
        return;
      }
      controller.add(
        LearningStatistics.fromSnapshots(
          summary: summarySnapshot!.data() ?? const {},
          vocabularyDocs: vocabularySnapshot!.docs,
          grammarDocs: grammarSnapshot!.docs,
          totalQuestionsByLevel: totalQuestionsByLevel,
        ),
      );
    }

    controller = StreamController<LearningStatistics>(
      onListen: () {
        subscriptions
          ..add(ref.collection('statistics').doc('summary').snapshots().listen((snapshot) {
            summarySnapshot = snapshot;
            emitIfReady();
          }, onError: controller.addError))
          ..add(ref.collection('vocabulary_history').snapshots().listen((snapshot) {
            vocabularySnapshot = snapshot;
            emitIfReady();
          }, onError: controller.addError))
          ..add(ref.collection('grammar_history').snapshots().listen((snapshot) {
            grammarSnapshot = snapshot;
            emitIfReady();
          }, onError: controller.addError));
      },
      onCancel: () async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      },
    );

    return controller.stream;
  }

  Future<void> _incrementStat(String field) async {
    final ref = _userRef;
    if (ref == null) return;
    await ref.collection('statistics').doc('summary').set({
      field: FieldValue.increment(1),
      'totalStudyCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

class LearningStatistics {
  const LearningStatistics({
    required this.totalStudyCount,
    required this.learningStreakDays,
    required this.accuracyPercent,
    required this.vocabularyCount,
    required this.grammarCount,
    required this.studyTimeMinutes,
    required this.progressByLevel,
    required this.learnedQuestionsByLevel,
    required this.totalQuestionsByLevel,
  });

  factory LearningStatistics.empty({Map<String, int> totalQuestionsByLevel = const {}}) => LearningStatistics(
        totalStudyCount: 0,
        learningStreakDays: 0,
        accuracyPercent: 0,
        vocabularyCount: 0,
        grammarCount: 0,
        studyTimeMinutes: 0,
        progressByLevel: {for (final level in _jlptLevels) level: 0},
        learnedQuestionsByLevel: {for (final level in _jlptLevels) level: 0},
        totalQuestionsByLevel: {for (final level in _jlptLevels) level: totalQuestionsByLevel[level] ?? 0},
      );

  factory LearningStatistics.fromSnapshots({
    required Map<String, dynamic> summary,
    required Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> vocabularyDocs,
    required Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> grammarDocs,
    required Map<String, int> totalQuestionsByLevel,
  }) {
    final learned = {for (final level in _jlptLevels) level: 0};
    for (final doc in [...vocabularyDocs, ...grammarDocs]) {
      final level = (doc.data()['jlptLevel'] as String?)?.toUpperCase();
      if (level != null && learned.containsKey(level)) {
        learned[level] = learned[level]! + 1;
      }
    }

    final totals = {for (final level in _jlptLevels) level: totalQuestionsByLevel[level] ?? 0};
    final progress = {
      for (final level in _jlptLevels)
        level: totals[level] == 0 ? 0.0 : (learned[level]! / totals[level]!).clamp(0.0, 1.0).toDouble(),
    };

    return LearningStatistics(
      totalStudyCount: (summary['totalStudyCount'] as num?)?.toInt() ?? learned.values.fold(0, (sum, count) => sum + count),
      learningStreakDays: (summary['learningStreakDays'] as num?)?.toInt() ?? 0,
      accuracyPercent: (summary['accuracyPercent'] as num?)?.toInt() ?? 0,
      vocabularyCount: vocabularyDocs.length,
      grammarCount: grammarDocs.length,
      studyTimeMinutes: (summary['studyTimeMinutes'] as num?)?.toInt() ?? 0,
      progressByLevel: progress,
      learnedQuestionsByLevel: learned,
      totalQuestionsByLevel: totals,
    );
  }

  static const _jlptLevels = ['N5', 'N4', 'N3', 'N2', 'N1'];

  final int totalStudyCount, learningStreakDays, accuracyPercent, vocabularyCount, grammarCount, studyTimeMinutes;
  final Map<String, double> progressByLevel;
  final Map<String, int> learnedQuestionsByLevel;
  final Map<String, int> totalQuestionsByLevel;
}
