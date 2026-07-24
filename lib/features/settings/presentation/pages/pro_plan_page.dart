import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/widgets/app_background.dart';
import '../providers/purchase_providers.dart';

class ProPlanPage extends ConsumerWidget {
  const ProPlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(proStatusProvider);
    final purchase = ref.watch(purchaseProvider);
    ref.listen(purchaseProvider, (previous, next) {
      final previousMessage = previous?.value?.message;
      final message = next.value?.message;
      if (message != null && message != previousMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Pro Plan')),
      body: AppBackground(
        child: SafeArea(
          top: false,
          child: purchase.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _StoreError(
              message: error.toString(),
              onRetry: () => ref.read(purchaseProvider.notifier).retry(),
            ),
            data: (state) => ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          children: [
                            const Icon(Icons.workspace_premium_rounded, size: 72),
                            const SizedBox(height: 20),
                            Text(
                              isPro ? 'Current Plan' : 'Pro Monthly',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isPro ? 'Pro Member' : 'US\$6.99 / month',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            if (!isPro && state.product != null &&
                                state.product!.price != r'US$6.99') ...[
                              const SizedBox(height: 6),
                              Text('Store price: ${state.product!.price} / month'),
                            ],
                            const SizedBox(height: 26),
                            const _Benefit(text: 'No ads'),
                            const _Benefit(text: 'All questions and JLPT levels'),
                            const _Benefit(text: 'Unlimited learning'),
                            const SizedBox(height: 26),
                            FilledButton(
                              onPressed: isPro || state.isPurchasing
                                  ? null
                                  : () => ref.read(purchaseProvider.notifier).buyMonthly(),
                              child: state.isPurchasing
                                  ? const SizedBox.square(
                                      dimension: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Text(isPro ? 'Pro Member' : 'Upgrade to Pro'),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: state.isRestoring
                                  ? null
                                  : () => ref.read(purchaseProvider.notifier).restore(),
                              child: state.isRestoring
                                  ? const SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Restore Purchases'),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'The final price is shown by the App Store or Google Play. '
                              'Subscriptions renew automatically and can be canceled in store settings.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.check_circle, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      );
}

class _StoreError extends StatelessWidget {
  const _StoreError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.storefront_outlined, size: 56),
              const SizedBox(height: 12),
              const Text('Pro Monthly is unavailable.'),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Try Again')),
            ],
          ),
        ),
      );
}
