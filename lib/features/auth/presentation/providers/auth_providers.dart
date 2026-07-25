import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';
import '../../domain/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());
final authStateProvider = StreamProvider<User?>((ref) => ref.watch(authRepositoryProvider).authStateChanges());

/// Privacy boundary for every piece of user-owned state.
///
/// Unlike reading `FirebaseAuth.currentUser` directly, this value can be
/// cleared synchronously before an asynchronous sign-out starts. Providers
/// must use it as part of their cache identity so data from one uid can never
/// be reused for another uid.
final activeUserIdProvider = NotifierProvider<ActiveUserIdNotifier, String?>(
  ActiveUserIdNotifier.new,
);

class ActiveUserIdNotifier extends Notifier<String?> {
  @override
  String? build() => ref.watch(authStateProvider).asData?.value?.uid;

  void clear() => state = null;

  void restoreCurrentUser() {
    state = ref.read(authRepositoryProvider).currentFirebaseUser?.uid;
  }
}

final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final uid = ref.watch(activeUserIdProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(authRepositoryProvider).watchCurrentUser();
});
