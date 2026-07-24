import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

const proMonthlyProductId = 'jlpt_master_pro_monthly';

class PurchaseService {
  PurchaseService([InAppPurchase? store])
      : _store = store ?? InAppPurchase.instance;

  final InAppPurchase _store;

  Stream<List<PurchaseDetails>> get purchaseStream => _store.purchaseStream;

  Future<ProductDetails> loadMonthlyProduct() async {
    if (!await _store.isAvailable()) {
      throw const PurchaseException(
        'The App Store / Google Play is unavailable.',
      );
    }
    final response = await _store.queryProductDetails({proMonthlyProductId});
    if (response.error case final error?) {
      throw PurchaseException(error.message);
    }
    if (response.notFoundIDs.contains(proMonthlyProductId) ||
        response.productDetails.isEmpty) {
      throw const PurchaseException(
        'Pro Monthly is not available in the store for this account or region.',
      );
    }
    return response.productDetails.firstWhere(
      (product) => product.id == proMonthlyProductId,
      orElse: () => throw const PurchaseException(
        'The store returned an unexpected product.',
      ),
    );
  }

  Future<void> buy(ProductDetails product) async {
    final started = await _store.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
    if (!started) {
      throw const PurchaseException('The purchase could not be started.');
    }
  }

  Future<void> restore() => _store.restorePurchases();

  Future<void> complete(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _store.completePurchase(purchase);
    }
  }
}

class PurchaseException implements Exception {
  const PurchaseException(this.message);

  final String message;

  @override
  String toString() => message;
}
