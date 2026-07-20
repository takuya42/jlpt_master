import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/navigation/app_route.dart';
import '../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../features/remote_config/remote_config_repository.dart';

class PremiumButton extends ConsumerWidget {
  const PremiumButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    if (!ref.watch(premiumEnabledProvider)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 12),
      child: FilledButton.tonalIcon(
        onPressed: () => context.go(AppRoute.premium.path),
        icon: const Icon(Icons.workspace_premium_outlined, size: 20),
        label: Text(isPremium ? 'Premium' : 'Premium'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      ),
    );
  }
}
