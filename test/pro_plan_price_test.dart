import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:jlpt_master/features/settings/data/pro_plan_price.dart';

void main() {
  test('fallback price is formatted for overseas customers', () {
    const price = ProPlanPriceFormatter.fallback;

    expect(price.priceWithPeriod, r'US$6.99 / month');
    expect(price.referencePrice, '≈ ¥980 / month');
    expect(price.purchaseLabel, r'Start Pro – US$6.99/month');
  });

  test('store product replaces the fallback with its localized price', () {
    final product = ProductDetails(
      id: 'pro_monthly',
      title: 'Pro Monthly',
      description: 'Monthly Pro plan',
      price: '€6.49',
      rawPrice: 6.49,
      currencyCode: 'EUR',
      currencySymbol: '€',
    );

    final price = const ProPlanPriceFormatter().fromProduct(product);

    expect(price.priceWithPeriod, '€6.49 / month');
    expect(price.purchaseLabel, 'Start Pro – €6.49/month');
    expect(price.referencePrice, '≈ ¥980 / month');
  });
}
