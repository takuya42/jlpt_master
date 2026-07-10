import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';
import '../../domain/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());
final authStateProvider = StreamProvider<User?>((ref) => ref.watch(authRepositoryProvider).authStateChanges());
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(authRepositoryProvider).watchCurrentUser();
});
final isPremiumProvider = Provider<bool>((ref) => ref.watch(currentUserProvider).asData?.value?.isPremium ?? false);
