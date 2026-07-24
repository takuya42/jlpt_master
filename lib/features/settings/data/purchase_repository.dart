import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pro_purchase_service.dart';

const proEntitlementPreferenceKey = 'store_pro_entitlement';

abstract interface class PurchaseVerifier {
  Future<bool> verify(PurchaseDetails purchase);
}

/// Validates the product and the signed store payload before granting access.
///
/// App Store and Play Store also validate the payload when restoring it. A
/// server verifier can be supplied without changing the repository or UI.
class StorePurchaseVerifier implements PurchaseVerifier {
  const StorePurchaseVerifier();

  @override
  Future<bool> verify(PurchaseDetails purchase) async {
    final verification = purchase.verificationData;
    return purchase.productID == proMonthlyProductId &&
        verification.serverVerificationData.isNotEmpty &&
        verification.localVerificationData.isNotEmpty &&
        (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored);
  }
}

class PurchaseRepository {
  PurchaseRepository({
    required PurchaseService service,
    required SharedPreferences preferences,
    PurchaseVerifier verifier = const StorePurchaseVerifier(),
  })  : _service = service,
        _preferences = preferences,
        _verifier = verifier;

  final PurchaseService _service;
  final SharedPreferences _preferences;
  final PurchaseVerifier _verifier;
  final _proController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  Timer? _restoreTimer;
  bool _isPro = false;
  bool _receivedEntitlementDuringRestore = false;
  bool _disposed = false;

  bool get isPro => _isPro;
  Stream<bool> get proStatus => _proController.stream;
  Stream<String> get errors => _errorController.stream;

  Future<void> initialize() async {
    if (_subscription != null) return;
    _isPro = _preferences.getBool(proEntitlementPreferenceKey) ?? false;
    _subscription = _service.purchaseStream.listen(
      _handlePurchases,
      onError: (Object error) => _emitError('Store update failed: $error'),
    );
    await restore(reconcile: true);
  }

  Future<ProductDetails> loadProduct() => _service.loadMonthlyProduct();

  Future<void> purchase(ProductDetails product) => _service.buy(product);

  Future<void> restore({bool reconcile = false}) async {
    _receivedEntitlementDuringRestore = false;
    _restoreTimer?.cancel();
    try {
      await _service.restore();
      if (reconcile) {
        _restoreTimer = Timer(const Duration(seconds: 3), () {
          if (!_receivedEntitlementDuringRestore) unawaited(_setPro(false));
        });
      }
    } on Object catch (error) {
      _emitError('Restore failed: $error');
      rethrow;
    }
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != proMonthlyProductId) continue;
      try {
        switch (purchase.status) {
          case PurchaseStatus.purchased:
          case PurchaseStatus.restored:
            if (await _verifier.verify(purchase)) {
              _receivedEntitlementDuringRestore = true;
              _restoreTimer?.cancel();
              await _setPro(true);
            } else {
              await _setPro(false);
              _emitError('The store receipt could not be verified.');
            }
          case PurchaseStatus.error:
            _emitError(purchase.error?.message ?? 'The purchase failed.');
          case PurchaseStatus.canceled:
            _emitError('The purchase was canceled.');
          case PurchaseStatus.pending:
            break;
        }
      } on Object catch (error) {
        _emitError('Purchase verification failed: $error');
      } finally {
        try {
          await _service.complete(purchase);
        } on Object catch (error) {
          _emitError('The transaction could not be completed: $error');
        }
      }
    }
  }

  Future<void> _setPro(bool value) async {
    if (_disposed) return;
    _isPro = value;
    await _preferences.setBool(proEntitlementPreferenceKey, value);
    if (!_disposed) _proController.add(value);
  }

  void _emitError(String message) {
    if (!_disposed) _errorController.add(message);
  }

  Future<void> dispose() async {
    _disposed = true;
    _restoreTimer?.cancel();
    await _subscription?.cancel();
    await _proController.close();
    await _errorController.close();
  }
}
