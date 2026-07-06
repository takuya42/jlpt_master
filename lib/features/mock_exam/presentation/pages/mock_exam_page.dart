import 'package:flutter/material.dart';

class MockExamPage extends StatefulWidget {
  const MockExamPage({super.key});

  @override
  State<MockExamPage> createState() => _MockExamPageState();
}

class _MockExamPageState extends State<MockExamPage> {
  int? _selected;
  bool _submitted = false;

  static const _question = _ExamQuestion(
    prompt: '「学校」の読み方はどれですか。',
    options: ['がっこう', 'がこう', 'がくこ', 'まなびや'],
    answerIndex: 0,
    explanation: '学校 is read がっこう and means school（学校）です。',
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('Mock Exam（模擬試験）', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text('本番形式で1問ずつ練習しましょう。', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Mock Exam（模擬試験を開始）'),
                ),
                const SizedBox(height: 14),
                const Row(
                  children: [
                    Expanded(child: _ScoreCard(label: 'Current score（現在の成績）', value: '82%')),
                    SizedBox(width: 10),
                    Expanded(child: _ScoreCard(label: 'Best score（最高点）', value: '94%')),
                    SizedBox(width: 10),
                    Expanded(child: _ScoreCard(label: 'Average correct rate（平均正答率）', value: '78%')),
                  ],
                ),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Chip(label: Text('N5 Vocabulary（単語）')),
                        const SizedBox(height: 14),
                        Text(_question.prompt, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 16),
                        for (var i = 0; i < _question.options.length; i++)
                          RadioListTile<int>(
                            value: i,
                            groupValue: _selected,
                            onChanged: _submitted ? null : (value) => setState(() => _selected = value),
                            title: Text(_question.options[i]),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _selected == null ? null : () => setState(() => _submitted = true),
                          icon: const Icon(Icons.check),
                          label: const Text('Submit（回答する）'),
                        ),
                        if (_submitted) ...[
                          const SizedBox(height: 18),
                          _ResultBanner(isCorrect: _selected == _question.answerIndex, explanation: _question.explanation),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.isCorrect, required this.explanation});

  final bool isCorrect;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? colorScheme.primaryContainer : colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text('${isCorrect ? 'Correct!（正解）' : 'Review needed（復習しましょう）'}\n$explanation'),
    );
  }
}

class _ExamQuestion {
  const _ExamQuestion({required this.prompt, required this.options, required this.answerIndex, required this.explanation});

  final String prompt;
  final List<String> options;
  final int answerIndex;
  final String explanation;
}
