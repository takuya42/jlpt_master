import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/navigation/app_route.dart';

Future<void> showUpgradeDialog(BuildContext context) async {
  final shouldUpgrade = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Upgrade to Pro'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Unlock unlimited Japanese learning.'),
          SizedBox(height: 16),
          Text('Benefits', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('・Unlimited Vocabulary'),
          Text('・All Grammar Levels (N5–N1)'),
          Text('・Future Premium Features'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Maybe Later'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Upgrade to Pro'),
        ),
      ],
    ),
  );
  if (shouldUpgrade == true && context.mounted) {
    context.go(AppRoute.proPlan.path);
  }
}
