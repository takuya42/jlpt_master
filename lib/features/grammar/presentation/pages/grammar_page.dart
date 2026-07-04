import 'package:flutter/material.dart';

class GrammarPage extends StatelessWidget {
  const GrammarPage({super.key});

  static const _patterns = [
    _GrammarPattern('〜てください', 'Please do...', '名前を書いてください。', 'Please write your name.', 'N5'),
    _GrammarPattern('〜なければならない', 'Must do...', '薬を飲まなければなりません。', 'I must take medicine.', 'N4'),
    _GrammarPattern('〜ことにする', 'Decide to do...', '毎朝走ることにしました。', 'I decided to run every morning.', 'N3'),
    _GrammarPattern('〜わけではない', 'It does not mean that...', '嫌いなわけではありません。', 'It does not mean I dislike it.', 'N2'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              itemCount: _patterns.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _PageHeader(
                    title: 'Grammar',
                    subtitle: '文型を例文と一緒に確認しましょう。',
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(label: Text(pattern.level)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    pattern.expression,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(pattern.meaning, style: theme.textTheme.titleMedium),
            const Divider(height: 28),
            Text(pattern.exampleJa, style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(pattern.exampleEn, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
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
        child: Row(
          children: [
            Icon(icon, size: 42),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrammarPattern {
  const _GrammarPattern(this.expression, this.meaning, this.exampleJa, this.exampleEn, this.level);

  final String expression;
  final String meaning;
  final String exampleJa;
  final String exampleEn;
  final String level;
}
