import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/app_route.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  static const _features = [
    _PremiumFeature('Unlimited Vocabulary', '単語学習が無制限', Icons.menu_book_rounded),
    _PremiumFeature('Unlimited Grammar', '文法学習が無制限', Icons.translate_rounded),
    _PremiumFeature('JLPT N5〜N1', 'N5〜N1すべて学習可能', Icons.school_rounded),
    _PremiumFeature('Detailed Explanations', '詳しい解説', Icons.tips_and_updates_rounded),
    _PremiumFeature('Study Statistics', '学習記録', Icons.analytics_rounded),
    _PremiumFeature('Future Updates', '今後のアップデート', Icons.update_rounded),
  ];

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoute.home.path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const SizedBox.shrink(),
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => _handleBack(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      bottomNavigationBar: const _PremiumBottomBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 176),
              children: [
                Icon(
                  Icons.workspace_premium_rounded,
                  size: 88,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 18),
                Text(
                  'Unlock Your Japanese Learning',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                Text(
                  'Unlimited access to all premium features.\nすべてのプレミアム機能をご利用いただけます。',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 30),
                const _PremiumPlanCard(),
                const SizedBox(height: 24),
                const _PremiumLinks(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumBottomBar extends StatelessWidget {
  const _PremiumBottomBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.55)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    ),
                    child: const Text('Start Premium\nプレミアムを開始する', textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '¥1,000 / month\n月額1,000円',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.35),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cancel anytime.\nいつでも解約できます。',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.35),
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

class _PremiumPlanCard extends StatelessWidget {
  const _PremiumPlanCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF7CF), Color(0xFFFFD86B), Color(0xFFD99A18)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD99A18).withValues(alpha: 0.32),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withValues(alpha: 0.42), Colors.white.withValues(alpha: 0.03)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.76),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFF9A6400), size: 34),
                    ),
                    const SizedBox(width: 16),
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
                const SizedBox(height: 26),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.50)),
      ),
      child: Row(
        children: [
          Icon(feature.icon, color: const Color(0xFF7A5000), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.englishLabel,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF4D3100),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  feature.japaneseLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6F4800),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: Color(0xFF7A5000), size: 22),
        ],
      ),
    );
  }
}

class _PremiumLinks extends StatelessWidget {
  const _PremiumLinks();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LinkButton(onPressed: () {}, englishLabel: 'Restore Purchases', japaneseLabel: '購入を復元'),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            _LinkButton(onPressed: () {}, englishLabel: 'Terms of Use', japaneseLabel: '利用規約'),
            _LinkButton(onPressed: () {}, englishLabel: 'Privacy Policy', japaneseLabel: 'プライバシーポリシー'),
          ],
        ),
      ],
    );
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({required this.onPressed, required this.englishLabel, required this.japaneseLabel});

  final VoidCallback onPressed;
  final String englishLabel;
  final String japaneseLabel;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text('$englishLabel\n$japaneseLabel', textAlign: TextAlign.center),
    );
  }
}

class _PremiumFeature {
  const _PremiumFeature(this.englishLabel, this.japaneseLabel, this.icon);

  final String englishLabel;
  final String japaneseLabel;
  final IconData icon;
}
