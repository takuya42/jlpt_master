import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/app_route.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  static const _features = [
    _PremiumFeature('Unlimited Vocabulary', '単語学習が無制限'),
    _PremiumFeature('Unlimited Grammar', '文法学習が無制限'),
    _PremiumFeature('JLPT N5〜N1', 'N5〜N1すべて学習可能'),
    _PremiumFeature('Detailed Explanations', '詳しい解説'),
    _PremiumFeature('Study Statistics', '学習記録'),
    _PremiumFeature('No Ads', '広告なし'),
    _PremiumFeature('Future Updates', '今後のアップデート'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const SizedBox.shrink(),
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoute.home.path);
            }
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
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
                _BilingualText(
                  english: 'Unlock Your Japanese Learning',
                  japanese: '日本語学習をもっと自由に',
                  textAlign: TextAlign.center,
                  englishStyle: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                  japaneseStyle: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                _BilingualText(
                  english: 'Unlimited access to all premium features.',
                  japanese: 'すべてのプレミアム機能が利用できます。',
                  textAlign: TextAlign.center,
                  englishStyle: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  japaneseStyle: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
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
                              child: _BilingualText(
                                english: 'Premium',
                                japanese: 'プレミアム',
                                englishStyle: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                                japaneseStyle: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                              ),
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: _BilingualText(
                                  english: 'Popular',
                                  japanese: '人気',
                                  textAlign: TextAlign.center,
                                  englishStyle: theme.textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  japaneseStyle: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _BilingualText(
                          english: '¥1,000 / month',
                          japanese: '月額 ¥1,000',
                          englishStyle: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w900,
                          ),
                          japaneseStyle: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.primary),
                        ),
                        const SizedBox(height: 22),
                        for (final feature in _features)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Icon(Icons.check_circle_rounded, color: colorScheme.primary, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _BilingualText(
                                    english: feature.english,
                                    japanese: feature.japanese,
                                    englishStyle: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
                                    japaneseStyle: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                                  ),
                                ),
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
                    minimumSize: const Size.fromHeight(64),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: _BilingualText(
                    english: 'Start Premium\n¥1,000 / month',
                    japanese: 'プレミアムを開始する\n月額 ¥1,000',
                    textAlign: TextAlign.center,
                    englishStyle: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                    japaneseStyle: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary),
                  ),
                ),
                const SizedBox(height: 18),
                TextButton(
                  onPressed: () {},
                  child: const _BilingualText(
                    english: 'Restore Purchases',
                    japanese: '購入を復元',
                    textAlign: TextAlign.center,
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const _BilingualText(
                        english: 'Terms of Use',
                        japanese: '利用規約',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const _BilingualText(
                        english: 'Privacy Policy',
                        japanese: 'プライバシーポリシー',
                        textAlign: TextAlign.center,
                      ),
                    ),
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

class _BilingualText extends StatelessWidget {
  const _BilingualText({
    required this.english,
    required this.japanese,
    this.textAlign,
    this.englishStyle,
    this.japaneseStyle,
  });

  final String english;
  final String japanese;
  final TextAlign? textAlign;
  final TextStyle? englishStyle;
  final TextStyle? japaneseStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: _crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          english,
          textAlign: textAlign,
          style: englishStyle ?? theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          japanese,
          textAlign: textAlign,
          style: japaneseStyle ?? theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  CrossAxisAlignment get _crossAxisAlignment {
    if (textAlign == TextAlign.center) {
      return CrossAxisAlignment.center;
    }
    if (textAlign == TextAlign.right || textAlign == TextAlign.end) {
      return CrossAxisAlignment.end;
    }
    return CrossAxisAlignment.start;
  }
}

class _PremiumFeature {
  const _PremiumFeature(this.english, this.japanese);

  final String english;
  final String japanese;
}
