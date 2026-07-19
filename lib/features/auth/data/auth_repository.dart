import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/app_user.dart';

class AuthRepository {
  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentFirebaseUser => _auth.currentUser;

  Stream<AppUser?> watchCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);
    return _userDoc(user.uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      return data == null ? null : AppUser.fromJson(data);
    });
  }

  Future<UserCredential> signInWithEmailAndPassword({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
    await ensureUserDocument(credential.user);
    return credential;
  }

  Future<UserCredential> createUserWithEmailAndPassword({required String displayName, required String email, required String password}) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    await credential.user?.updateDisplayName(displayName.trim());
    await ensureUserDocument(credential.user, displayName: displayName.trim());
    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    final credential = await _auth.signInWithProvider(GoogleAuthProvider());
    await ensureUserDocument(credential.user);
    return credential;
  }

  Future<UserCredential> signInWithApple() async {
    final provider = OAuthProvider('apple.com')..addScope('email')..addScope('name');
    final credential = await _auth.signInWithProvider(provider);
    await ensureUserDocument(credential.user);
    return credential;
  }

  Future<void> sendPasswordResetEmail(String email) => _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() => _auth.signOut();

  Future<void> deleteCurrentUserAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _deleteUserData(user.uid);
    await user.delete();
  }

  Future<void> _deleteUserData(String uid) async {
    final userRef = _userDoc(uid);
    // Firestore does not cascade deletes to a document's subcollections. Keep
    // this list in sync with every user-scoped collection created by the app.
    const collectionNames = [
      'favorites',
      'vocabulary_history',
      'grammar_history',
      'learning_history',
      'study_progress',
      'statistics',
      'settings',
    ];

    for (final collectionName in collectionNames) {
      await _deleteCollection(userRef.collection(collectionName));
    }

    await userRef.delete();
  }

  Future<void> _deleteCollection(CollectionReference<Map<String, dynamic>> collection) async {
    const batchLimit = 450;

    while (true) {
      final snapshot = await collection.limit(batchLimit).get();
      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  Future<void> ensureUserDocument(User? user, {String? displayName}) async {
    if (user == null) return;
    final ref = _userDoc(user.uid);
    final snapshot = await ref.get();
    final now = FieldValue.serverTimestamp();
    if (!snapshot.exists) {
      await ref.set({
        'uid': user.uid,
        'displayName': displayName?.trim().isNotEmpty == true ? displayName!.trim() : (user.displayName ?? ''),
        'email': user.email ?? '',
        'plan': 'free',
        'createdAt': now,
        'updatedAt': now,
      });
      await ref.collection('statistics').doc('summary').set({
        'totalStudyCount': 0,
        'learningStreakDays': 0,
        'accuracyPercent': 0,
        'vocabularyCount': 0,
        'grammarCount': 0,
        'studyTimeMinutes': 0,
        'updatedAt': now,
      });
      await ref.collection('study_progress').doc('summary').set({'updatedAt': now});
      return;
    }
    await ref.set({
      'displayName': displayName?.trim().isNotEmpty == true ? displayName!.trim() : (user.displayName ?? snapshot.data()?['displayName'] ?? ''),
      'email': user.email ?? snapshot.data()?['email'] ?? '',
      'updatedAt': now,
    }, SetOptions(merge: true));
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) => _firestore.collection('users').doc(uid);
}
