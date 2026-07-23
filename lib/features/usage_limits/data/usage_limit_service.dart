import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const freeVocabularyLimit = 5;
const freeGrammarLevel = 'N5';
const proPlanId = 'pro';

enum UsageFeature { vocabulary, grammar, kanji, mockExam, ai }

enum UsageLimitDecision { allowed, limitReached }

/// Firestore-backed source of truth for all per-user premium usage rules.
///
/// New metered features can use the same `freeUsage.<feature>` document shape
/// and transaction without putting persistence concerns in presentation code.
class UsageLimitService {
  UsageLimitService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    DateTime Function()? now,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _now = now ?? DateTime.now;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final DateTime Function() _now;

  String? get _uid => _auth.currentUser?.uid;

  Future<bool> isPro() async {
    final uid = _uid;
    if (uid == null) return false;
    final snapshot = await _firestore.collection('users').doc(uid).get();
    return snapshot.data()?['plan'] == proPlanId;
  }

  Future<int> getTodayUsage(UsageFeature feature) async {
    final uid = _uid;
    if (uid == null) return 0;
    final data = (await _firestore.collection('users').doc(uid).get()).data();
    final usage = _featureUsage(data, feature);
    return usage['date'] == _today ? _count(usage['answeredCount']) : 0;
  }

  Future<bool> canUseGrammarLevel(String level) async =>
      level == freeGrammarLevel || await isPro();

  /// Atomically checks and consumes one vocabulary answer.
  ///
  /// The plan is read in the same transaction, so a free account can never
  /// exceed the limit through concurrent Check Answer requests. Pro answers do
  /// not write usage counters.
  Future<UsageLimitDecision> recordVocabularyAnswer() async {
    final uid = _uid;
    // Never fail open while Firebase Auth is still resolving. Allowing an
    // answer here bypasses Firestore entirely and was the reason the daily
    // limit could be exceeded.
    if (uid == null) return UsageLimitDecision.limitReached;
    final userRef = _firestore.collection('users').doc(uid);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final data = snapshot.data();
      if (data?['plan'] == proPlanId) return UsageLimitDecision.allowed;

      final usage = _featureUsage(data, UsageFeature.vocabulary);
      final answeredCount = usage['date'] == _today
          ? _count(usage['answeredCount'])
          : 0;
      if (answeredCount >= freeVocabularyLimit) {
        return UsageLimitDecision.limitReached;
      }

      // Dot notation updates only this feature's counter and preserves any
      // sibling counters already stored under freeUsage.
      transaction.update(userRef, {
        'freeUsage.${UsageFeature.vocabulary.name}.date': _today,
        'freeUsage.${UsageFeature.vocabulary.name}.answeredCount':
            answeredCount + 1,
      });
      return UsageLimitDecision.allowed;
    });
  }

  String get _today {
    final value = _now().toLocal();
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    return '${value.year}-${twoDigits(value.month)}-${twoDigits(value.day)}';
  }

  static int _count(Object? value) => value is num ? value.toInt() : 0;

  static Map<String, dynamic> _featureUsage(
    Map<String, dynamic>? data,
    UsageFeature feature,
  ) {
    final freeUsage = data?['freeUsage'];
    if (freeUsage is! Map) return const {};
    final usage = freeUsage[feature.name];
    return usage is Map ? Map<String, dynamic>.from(usage) : const {};
  }
}

final usageLimitServiceProvider = Provider<UsageLimitService>(
  (ref) => UsageLimitService(),
);

final isProProvider = FutureProvider<bool>(
  (ref) => ref.watch(usageLimitServiceProvider).isPro(),
);
