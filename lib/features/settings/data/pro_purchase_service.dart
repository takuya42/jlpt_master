import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'pro_plan_price.dart';

const proMonthlyProductId = 'pro_monthly';

final proPurchaseServiceProvider = Provider<ProPurchaseService>(
  (ref) => ProPurchaseService(InAppPurchase.instance),
);

final proPlanPriceProvider = FutureProvider<ProPlanPrice>((ref) async {
  final product = await ref.watch(proPurchaseServiceProvider).monthlyProduct();
  return const ProPlanPriceFormatter().fromProduct(product);
});

class ProPurchaseService {
  const ProPurchaseService(this._store);

  final InAppPurchase _store;

  Future<ProductDetails> monthlyProduct() async {
    if (!await _store.isAvailable()) {
      throw const ProPurchaseException('The store is currently unavailable.');
    }

    final response = await _store.queryProductDetails({proMonthlyProductId});
    if (response.error != null) {
      throw ProPurchaseException(response.error!.message);
    }
    if (response.productDetails.isEmpty) {
      throw const ProPurchaseException('The Pro plan is currently unavailable.');
    }
    return response.productDetails.first;
  }

  /// Starts the existing App Store / Play Store purchase flow for Pro.
  Future<void> purchaseMonthlyPro() async {
    final purchaseParam = PurchaseParam(
      productDetails: await monthlyProduct(),
    );
    final started = await _store.buyNonConsumable(purchaseParam: purchaseParam);
    if (!started) {
      throw const ProPurchaseException('The purchase could not be started.');
    }
  }
}

class ProPurchaseException implements Exception {
  const ProPurchaseException(this.message);

  final String message;
}
