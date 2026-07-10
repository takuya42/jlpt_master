import 'package:flutter/material.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  static const _features = [
    _PremiumFeature('Unlimited Vocabulary', Icons.menu_book_rounded),
    _PremiumFeature('Unlimited Grammar', Icons.translate_rounded),
    _PremiumFeature('JLPT N5〜N1', Icons.school_rounded),
    _PremiumFeature('Detailed Explanations', Icons.tips_and_updates_rounded),
    _PremiumFeature('Study Statistics', Icons.analytics_rounded),
    _PremiumFeature('No Ads', Icons.block_rounded),
    _PremiumFeature('Future Updates', Icons.update_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Start Premium  •  ¥1,000 / month'),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 132),
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
                const _PremiumPlanCard(),
                const SizedBox(height: 24),
                Text(
                  'いつでも解約できます。\nCancel anytime.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.5),
                ),
                const SizedBox(height: 18),
                _LinkButton(onPressed: () {}, label: 'Restore Purchases'),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    _LinkButton(onPressed: () {}, label: 'Terms of Use'),
                    _LinkButton(onPressed: () {}, label: 'Privacy Policy'),
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

class _PremiumPlanCard extends StatelessWidget {
  const _PremiumPlanCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF4C2), Color(0xFFFFC857), Color(0xFFD99A18)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD99A18).withValues(alpha: 0.30),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withValues(alpha: 0.34), Colors.white.withValues(alpha: 0.02)],
                  stops: const [0.0, 0.48],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.emoji_events_rounded, color: Color(0xFF9A6400), size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Premium',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF5C3B00),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const _PopularBadge(),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '¥1,000 / month',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF5C3B00),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '月額1,000円',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF6F4800),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                for (final feature in PremiumPage._features) _FeatureTile(feature: feature),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PopularBadge extends StatelessWidget {
  const _PopularBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF5C3B00),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(
          'Popular',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.feature});

  final _PremiumFeature feature;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.46)),
      ),
      child: Row(
        children: [
          Icon(feature.icon, color: const Color(0xFF7A5000), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature.label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF4D3100),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: Color(0xFF7A5000), size: 22),
        ],
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({required this.onPressed, required this.label});

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(foregroundColor: color),
      child: Text(
        label,
        style: TextStyle(
          decoration: TextDecoration.underline,
          decorationColor: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PremiumFeature {
  const _PremiumFeature(this.label, this.icon);

  final String label;
  final IconData icon;
}
