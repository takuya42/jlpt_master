import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../domain/app_user.dart';

class AuthSignInCancelled implements Exception {
  const AuthSignInCancelled();
}

class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  Future<void>? _googleInitialization;

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
    try {
      await (_googleInitialization ??= _googleSignIn.initialize());
      final googleUser = await _googleSignIn.authenticate();
      final googleAuthentication = googleUser.authentication;
      final firebaseCredential = GoogleAuthProvider.credential(
        idToken: googleAuthentication.idToken,
      );
      final userCredential = await _auth.signInWithCredential(
        firebaseCredential,
      );
      await ensureUserDocument(userCredential.user);
      return userCredential;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthSignInCancelled();
      }
      rethrow;
    }
  }

  Future<UserCredential> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final fullName = [
        appleCredential.givenName,
        appleCredential.familyName,
      ].whereType<String>().where((part) => part.trim().isNotEmpty).join(' ');
      final firebaseCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      final userCredential = await _auth.signInWithCredential(
        firebaseCredential,
      );
      if (fullName.isNotEmpty &&
          (userCredential.user?.displayName?.isNotEmpty != true)) {
        await userCredential.user?.updateDisplayName(fullName);
      }
      await ensureUserDocument(
        userCredential.user,
        displayName: fullName.isEmpty ? null : fullName,
        email: appleCredential.email,
      );
      return userCredential;
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        throw const AuthSignInCancelled();
      }
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) => _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() async {
    final signedInWithGoogle = _auth.currentUser?.providerData.any(
          (provider) => provider.providerId == 'google.com',
        ) ??
        false;
    if (signedInWithGoogle) {
      await (_googleInitialization ??= _googleSignIn.initialize());
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }

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

  Future<void> ensureUserDocument(
    User? user, {
    String? displayName,
    String? email,
  }) async {
    if (user == null) return;
    final ref = _userDoc(user.uid);
    final snapshot = await ref.get();
    final now = FieldValue.serverTimestamp();
    if (!snapshot.exists) {
      await ref.set({
        'uid': user.uid,
        'displayName': displayName?.trim().isNotEmpty == true ? displayName!.trim() : (user.displayName ?? ''),
        'email': email ?? user.email ?? '',
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
      'email': email ?? user.email ?? snapshot.data()?['email'] ?? '',
      'updatedAt': now,
    }, SetOptions(merge: true));
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) => _firestore.collection('users').doc(uid);
}
