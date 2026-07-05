import 'package:firebase_core/firebase_core.dart';

/// Firebase configuration placeholder.
///
/// Replace these values with `flutterfire configure` output before submitting a
/// production build. Keeping the file in the app makes Firebase initialization
/// explicit and prevents missing-code build failures while CI environments run
/// without platform secrets.
class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform => const FirebaseOptions(
        apiKey: 'replace-with-firebase-api-key',
        appId: 'replace-with-firebase-app-id',
        messagingSenderId: 'replace-with-sender-id',
        projectId: 'jlpt-master',
        storageBucket: 'jlpt-master.appspot.com',
      );
}
