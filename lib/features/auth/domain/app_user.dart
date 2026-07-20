import 'package:flutter/foundation.dart';

@immutable
class AppUser {
  const AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.plan,
  });

  final String uid;
  final String displayName;
  final String email;
  final String plan;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        uid: json['uid'] as String? ?? '',
        displayName: json['displayName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        plan: json['plan'] as String? ?? 'free',
      );
}
