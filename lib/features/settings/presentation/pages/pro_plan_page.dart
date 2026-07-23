import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/widgets/app_background.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class ProPlanPage extends ConsumerWidget {
  const ProPlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(currentUserProvider).asData?.value?.plan == 'pro';
    return Scaffold(
      appBar: AppBar(title: const Text('Pro Plan')),
      body: AppBackground(
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.workspace_premium_rounded, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    isPro ? 'You are a Pro member' : 'Upgrade to Pro',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Unlimited Vocabulary\nAll Grammar Levels (N5–N1)\nFuture Premium Features',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
