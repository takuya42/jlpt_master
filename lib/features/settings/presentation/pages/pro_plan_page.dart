import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/presentation/widgets/app_background.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/pro_purchase_service.dart';

class ProPlanPage extends ConsumerStatefulWidget {
  const ProPlanPage({super.key});

  @override
  ConsumerState<ProPlanPage> createState() => _ProPlanPageState();
}

class _ProPlanPageState extends ConsumerState<ProPlanPage> {
  bool _isPurchasing = false;

  Future<void> _startPurchase() async {
    setState(() => _isPurchasing = true);
    try {
      await ref.read(proPurchaseServiceProvider).purchaseMonthlyPro();
    } on ProPurchaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${error.message}\n購入処理を開始できませんでした。')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPro = ref.watch(currentUserProvider).asData?.value?.plan == 'pro';
    return Scaffold(
      appBar: AppBar(title: const Text('Pro Plan')),
      body: AppBackground(
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                constraints.maxWidth < 380 ? 16 : 24,
                20,
                constraints.maxWidth < 380 ? 16 : 24,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: _ProCard(
                    isPro: isPro,
                    isPurchasing: _isPurchasing,
                    onPurchase: _startPurchase,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProCard extends StatelessWidget {
  const _ProCard({
    required this.isPro,
    required this.isPurchasing,
    required this.onPurchase,
  });

  final bool isPro;
  final bool isPurchasing;
  final VoidCallback onPurchase;

  static const _benefits = <(String, String)>[
    ('Unlimited Vocabulary', '単語を無制限に学習'),
    ('All Grammar Levels (N5–N1)', 'すべての文法レベル（N5〜N1）が利用可能'),
    ('Unlimited Daily Practice', '1日の学習回数が無制限'),
    ('Study History', '学習履歴'),
    ('Favorites & Review', 'お気に入り・復習機能'),
    ('Future Premium Features', '今後追加されるプレミアム機能'),
    ('Remove Future Learning Limits', '無料版の学習制限をすべて解除'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.64),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withValues(alpha: 0.14),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B7CFF), Color(0xFF4EC9E8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accent.withValues(alpha: 0.35),
                  blurRadius: 28,
                ),
              ],
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              size: 54,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isPro ? 'You are a Pro member' : 'Upgrade to Pro',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Proプラン',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Unlock your full Japanese learning experience.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '日本語学習をもっと自由に、もっと効率的に。',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 30),
          ..._benefits.map(
            (benefit) => _BenefitTile(
              english: benefit.$1,
              japanese: benefit.$2,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '¥980',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 0.95,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 7, left: 6),
                child: Text('/month', style: theme.textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 26),
          _GradientButton(
            enabled: !isPro && !isPurchasing,
            isLoading: isPurchasing,
            label: isPro ? 'Pro plan active' : 'Start Pro - ¥980/month',
            onPressed: onPurchase,
          ),
          const SizedBox(height: 14),
          Text(
            'Cancel anytime.',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text('いつでもキャンセルできます。', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({required this.english, required this.japanese});

  final String english;
  final String japanese;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 17,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  english,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(japanese, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.enabled,
    required this.isLoading,
    required this.label,
    required this.onPressed,
  });

  final bool enabled;
  final bool isLoading;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.62,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7667FF), Color(0xFF35BDE2)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withValues(alpha: 0.38),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
