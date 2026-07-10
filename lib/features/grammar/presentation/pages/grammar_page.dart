import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/premium_button.dart';

class GrammarPage extends StatelessWidget {
  const GrammarPage({super.key});

  static const _patterns = [
    _GrammarPattern('〜てください', 'Please do...', '〜してください', '名前を書いてください。', 'Please write your name.', '名前を書いてください。', 'N5'),
    _GrammarPattern('〜なければならない', 'Must do...', '〜しなければならない', '薬を飲まなければなりません。', 'I must take medicine.', '薬を飲まなければなりません。', 'N4'),
    _GrammarPattern('〜ことにする', 'Decide to do...', '〜することに決める', '毎朝走ることにしました。', 'I decided to run every morning.', '毎朝走ることにしました。', 'N3'),
    _GrammarPattern('〜わけではない', 'It does not mean that...', '〜というわけではない', '嫌いなわけではありません。', 'It does not mean I dislike it.', '嫌いなわけではありません。', 'N2'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(actions: const [PremiumButton()]),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
              itemCount: _patterns.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _PageHeader(
                    title: 'Grammar\n文法',
                    subtitle: 'Study each pattern with English and Japanese example sentences.\n文型を英語訳・日本語訳つきの例文で確認しましょう。',
                    icon: Icons.subject_outlined,
                    color: theme.colorScheme.tertiaryContainer,
                  );
                }
                return _GrammarCard(pattern: _patterns[index - 1]);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _GrammarCard extends StatelessWidget {
  const _GrammarCard({required this.pattern});
  final _GrammarPattern pattern;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Chip(label: Text(pattern.level)),
            const SizedBox(width: 10),
            Expanded(child: Text(pattern.expression, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900))),
          ]),
          const SizedBox(height: 12),
          Text(pattern.meaningEn, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          Text(pattern.meaningJa, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const Divider(height: 30),
          Text('Example / 例文', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
          const SizedBox(height: 8),
          Text(pattern.example, style: theme.textTheme.titleLarge),
          const SizedBox(height: 10),
          Text('English: ${pattern.translationEn}', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 4),
          Text('日本語: ${pattern.translationJa}', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ]),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.subtitle, required this.icon, required this.color});
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(children: [
          Icon(icon, size: 42),
          const SizedBox(width: 18),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(subtitle, style: theme.textTheme.bodyLarge),
          ])),
        ]),
      ),
    );
  }
}

class _GrammarPattern {
  const _GrammarPattern(this.expression, this.meaningEn, this.meaningJa, this.example, this.translationEn, this.translationJa, this.level);
  final String expression;
  final String meaningEn;
  final String meaningJa;
  final String example;
  final String translationEn;
  final String translationJa;
  final String level;
}
