import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class LearningStats {
  const LearningStats({
    required this.studyTimeMinutes,
    required this.completedLessons,
    required this.favoriteWords,
    required this.mockExamAccuracy,
    required this.weeklyGoalProgress,
  });

  factory LearningStats.empty() => const LearningStats(
        studyTimeMinutes: 0,
        completedLessons: 0,
        favoriteWords: 0,
        mockExamAccuracy: 0,
        weeklyGoalProgress: 0,
      );

  factory LearningStats.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) return LearningStats.empty();

    return LearningStats(
      studyTimeMinutes: (data['studyTimeMinutes'] as num?)?.toInt() ?? 0,
      completedLessons: (data['completedLessons'] as num?)?.toInt() ?? 0,
      favoriteWords: (data['favoriteWords'] as num?)?.toInt() ?? 0,
      mockExamAccuracy: (data['mockExamAccuracy'] as num?)?.toInt() ?? 0,
      weeklyGoalProgress: ((data['weeklyGoalProgress'] as num?)?.toDouble() ?? 0).clamp(0, 1).toDouble(),
    );
  }

  final int studyTimeMinutes;
  final int completedLessons;
  final int favoriteWords;
  final int mockExamAccuracy;
  final double weeklyGoalProgress;

  String get formattedStudyTime {
    final hours = studyTimeMinutes ~/ 60;
    final minutes = studyTimeMinutes % 60;
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }
}

class FirestoreLearningRepository {
  FirestoreLearningRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  Stream<LearningStats> watchStats() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(LearningStats.empty());

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('learning')
        .doc('stats')
        .snapshots()
        .map(LearningStats.fromFirestore);
  }

  Future<void> recordStudySession({
    required int minutes,
    required int correctAnswers,
    required int totalAnswers,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).collection('learningHistory').add({
      'minutes': minutes,
      'correctAnswers': correctAnswers,
      'totalAnswers': totalAnswers,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Reference userStorageRoot() {
    final user = _auth.currentUser;
    if (user == null) return _storage.ref('anonymous');
    return _storage.ref('users/${user.uid}');
  }
}
