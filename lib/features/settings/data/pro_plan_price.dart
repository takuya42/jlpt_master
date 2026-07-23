import 'package:in_app_purchase/in_app_purchase.dart';

/// Display-ready pricing for the monthly Pro product.
///
/// The fallback keeps the plan useful before the store responds. Once a
/// [ProductDetails] is available, the store's localized price is used instead.
class ProPlanPrice {
  const ProPlanPrice({
    required this.price,
    required this.period,
    this.referencePrice,
  });

  final String price;
  final String period;
  final String? referencePrice;

  String get priceWithPeriod => '$price / $period';
  String get purchaseLabel => 'Start Pro – $price/$period';
}

class ProPlanPriceFormatter {
  const ProPlanPriceFormatter();

  static const fallback = ProPlanPrice(
    price: r'US$6.99',
    period: 'month',
    referencePrice: '≈ ¥980 / month',
  );

  ProPlanPrice fromProduct(ProductDetails product) => ProPlanPrice(
        price: product.price,
        period: 'month',
        referencePrice: fallback.referencePrice,
      );
}
