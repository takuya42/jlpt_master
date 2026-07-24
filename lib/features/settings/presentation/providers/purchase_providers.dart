import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/pro_purchase_service.dart';
import '../../data/purchase_repository.dart';

final purchaseServiceProvider = Provider<PurchaseService>(
  (ref) => PurchaseService(),
);

final purchaseVerifierProvider = Provider<PurchaseVerifier>(
  (ref) => const StorePurchaseVerifier(),
);

final proStatusProvider = NotifierProvider<ProStatusNotifier, bool>(
  ProStatusNotifier.new,
);

final adsEnabledProvider = Provider<bool>((ref) => !ref.watch(proStatusProvider));
final allProblemsEnabledProvider = Provider<bool>(
  (ref) => ref.watch(proStatusProvider),
);
final unlimitedLearningProvider = Provider<bool>(
  (ref) => ref.watch(proStatusProvider),
);

class ProStatusNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void update(bool value) => state = value;
}

class PurchaseState {
  const PurchaseState({
    this.product,
    this.isPurchasing = false,
    this.isRestoring = false,
    this.message,
  });

  final ProductDetails? product;
  final bool isPurchasing;
  final bool isRestoring;
  final String? message;

  PurchaseState copyWith({
    ProductDetails? product,
    bool? isPurchasing,
    bool? isRestoring,
    String? message,
    bool clearMessage = false,
  }) =>
      PurchaseState(
        product: product ?? this.product,
        isPurchasing: isPurchasing ?? this.isPurchasing,
        isRestoring: isRestoring ?? this.isRestoring,
        message: clearMessage ? null : message ?? this.message,
      );
}

final purchaseProvider = AsyncNotifierProvider<PurchaseNotifier, PurchaseState>(
  PurchaseNotifier.new,
);

class PurchaseNotifier extends AsyncNotifier<PurchaseState> {
  PurchaseRepository? _repository;
  StreamSubscription<bool>? _proSubscription;
  StreamSubscription<String>? _errorSubscription;

  @override
  Future<PurchaseState> build() async {
    final preferences = await SharedPreferences.getInstance();
    final repository = PurchaseRepository(
      service: ref.read(purchaseServiceProvider),
      preferences: preferences,
      verifier: ref.read(purchaseVerifierProvider),
    );
    _repository = repository;
    ref.read(proStatusProvider.notifier).update(
          preferences.getBool(proEntitlementPreferenceKey) ?? false,
        );
    _proSubscription = repository.proStatus.listen(
      (value) => ref.read(proStatusProvider.notifier).update(value),
    );
    _errorSubscription = repository.errors.listen(_showMessage);
    ref.onDispose(() {
      unawaited(_proSubscription?.cancel());
      unawaited(_errorSubscription?.cancel());
      unawaited(repository.dispose());
    });

    await repository.initialize();
    final product = await repository.loadProduct();
    return PurchaseState(product: product);
  }

  Future<void> buyMonthly() async {
    final current = state.value;
    final repository = _repository;
    final product = current?.product;
    if (current == null || repository == null || product == null) return;
    state = AsyncData(current.copyWith(isPurchasing: true, clearMessage: true));
    try {
      await repository.purchase(product);
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return;
    }
    state = AsyncData(current.copyWith(isPurchasing: false));
  }

  Future<void> restore() async {
    final current = state.value;
    final repository = _repository;
    if (current == null || repository == null) return;
    state = AsyncData(current.copyWith(isRestoring: true, clearMessage: true));
    try {
      await repository.restore(reconcile: true);
      state = AsyncData(
        current.copyWith(
          isRestoring: false,
          message: 'Restore request completed.',
        ),
      );
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  void retry() => ref.invalidateSelf();

  void _showMessage(String message) {
    final current = state.value;
    if (current != null) state = AsyncData(current.copyWith(message: message));
  }
}
