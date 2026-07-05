import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreLearningRepository {
  const FirestoreLearningRepository._();

  static Future<bool> recordActivity({
    required String type,
    required String title,
    required int studyMinutes,
    int correctAnswers = 0,
    int totalAnswers = 0,
    Map<String, Object?> metadata = const {},
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await userRef.collection('studyHistory').add({
      'type': type,
      'title': title,
      'studyMinutes': studyMinutes,
      'correctAnswers': correctAnswers,
      'totalAnswers': totalAnswers,
      'metadata': metadata,
      'completedAt': FieldValue.serverTimestamp(),
    });

    await userRef.set({
      'statistics': {
        'studyMinutes': FieldValue.increment(studyMinutes),
        'weeklyStudyMinutes': FieldValue.increment(studyMinutes),
        'completedLessons': FieldValue.increment(1),
        'correctAnswers': FieldValue.increment(correctAnswers),
        'totalAnswers': FieldValue.increment(totalAnswers),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return true;
  }
}
