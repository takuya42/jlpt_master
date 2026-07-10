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

  Future<void> recordVocabularyView(String wordId) async {
    final ref = _userRef;
    if (ref == null) return;
    final now = FieldValue.serverTimestamp();
    await ref.collection('vocabulary_history').doc(wordId).set({
      'wordId': wordId,
      'lastViewedAt': now,
      'views': FieldValue.increment(1),
      'updatedAt': now,
    }, SetOptions(merge: true));
    await ref.collection('study_progress').doc('vocabulary').set({'lastViewedWordId': wordId, 'updatedAt': now}, SetOptions(merge: true));
    await _incrementStat('vocabularyCount');
  }

  Future<void> recordGrammarStudy(String grammarId) async {
    final ref = _userRef;
    if (ref == null) return;
    await ref.collection('grammar_history').doc(grammarId).set({
      'grammarId': grammarId,
      'studiedAt': FieldValue.serverTimestamp(),
      'attempts': FieldValue.increment(1),
    }, SetOptions(merge: true));
    await _incrementStat('grammarCount');
  }

  Stream<LearningStatistics> watchStatistics() {
    final ref = _userRef;
    if (ref == null) return Stream.value(LearningStatistics.empty());
    return ref.collection('statistics').doc('summary').snapshots().map((doc) => LearningStatistics.fromJson(doc.data() ?? const {}));
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
  const LearningStatistics({required this.totalStudyCount, required this.learningStreakDays, required this.accuracyPercent, required this.vocabularyCount, required this.grammarCount, required this.studyTimeMinutes});
  factory LearningStatistics.empty() => const LearningStatistics(totalStudyCount: 0, learningStreakDays: 0, accuracyPercent: 0, vocabularyCount: 0, grammarCount: 0, studyTimeMinutes: 0);
  factory LearningStatistics.fromJson(Map<String, dynamic> json) => LearningStatistics(
        totalStudyCount: (json['totalStudyCount'] as num?)?.toInt() ?? 0,
        learningStreakDays: (json['learningStreakDays'] as num?)?.toInt() ?? 0,
        accuracyPercent: (json['accuracyPercent'] as num?)?.toInt() ?? 0,
        vocabularyCount: (json['vocabularyCount'] as num?)?.toInt() ?? 0,
        grammarCount: (json['grammarCount'] as num?)?.toInt() ?? 0,
        studyTimeMinutes: (json['studyTimeMinutes'] as num?)?.toInt() ?? 0,
      );
  final int totalStudyCount, learningStreakDays, accuracyPercent, vocabularyCount, grammarCount, studyTimeMinutes;
}
