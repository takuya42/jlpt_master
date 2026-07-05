import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseServices {
  const FirebaseServices._();

  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
  static FirebaseAnalytics get analytics => FirebaseAnalytics.instance;
  static FirebaseCrashlytics get crashlytics => FirebaseCrashlytics.instance;
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;

  static Future<void> registerMessagingToken() async {
    final user = auth.currentUser;
    if (user == null) return;

    await messaging.requestPermission();
    final token = await messaging.getToken();
    if (token == null) return;

    await firestore.collection('users').doc(user.uid).set({
      'messagingTokens': FieldValue.arrayUnion([token]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> uploadProfileBackup() async {
    final user = auth.currentUser;
    if (user == null) return;

    final backup = jsonEncode({
      'uid': user.uid,
      'email': user.email,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
    });

    await storage.ref('users/${user.uid}/profile_backup.json').putString(
          backup,
          format: PutStringFormat.raw,
          metadata: SettableMetadata(contentType: 'application/json'),
        );
  }

  static Future<void> logScreenView(String screenName) {
    return analytics.logScreenView(screenName: screenName);
  }
}
