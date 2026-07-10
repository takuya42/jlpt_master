import 'package:flutter/material.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  static const _features = [
    'Unlimited Vocabulary',
    'Unlimited Grammar',
    'JLPT N5〜N1',
    'Detailed Explanations',
    'Study Statistics',
    'No Ads',
    'Future Updates',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
              children: [
                Icon(
                  Icons.workspace_premium_rounded,
                  size: 92,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 18),
                Text(
                  'Unlock Your Japanese Learning',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Text(
                  'Unlimited access to all premium features.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 28),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Premium',
                                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: Text(
                                  'Popular',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '¥1,000 / month',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 22),
                        for (final feature in _features)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: colorScheme.primary, size: 22),
                                const SizedBox(width: 12),
                                Expanded(child: Text(feature, style: theme.textTheme.bodyLarge)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(58),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Start Premium\n¥1,000 / month', textAlign: TextAlign.center),
                ),
                const SizedBox(height: 18),
                TextButton(onPressed: () {}, child: const Text('Restore Purchases')),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    TextButton(onPressed: () {}, child: const Text('Terms of Use')),
                    TextButton(onPressed: () {}, child: const Text('Privacy Policy')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
