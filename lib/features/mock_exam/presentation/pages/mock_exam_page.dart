import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/feature_page_header.dart';

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
    explanation: '学校 is read がっこう and means school.',
  );

  void _selectAnswer(int index) {
    if (_submitted) {
      return;
    }
    setState(() => _selected = index);
  }

  void _submitAnswer() {
    if (_selected == null) {
      return;
    }
    setState(() => _submitted = true);
  }

  void _resetQuestion() {
    setState(() {
      _selected = null;
      _submitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              key: const PageStorageKey('mock-exam-practice'),
              padding: const EdgeInsets.all(20),
              children: [
                const FeaturePageHeader(
                  title: 'Mock Exam',
                  subtitle: '本番形式で1問ずつ練習しましょう。',
                  icon: Icons.quiz_outlined,
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Chip(label: Text('N5 Vocabulary')),
                        const SizedBox(height: 14),
                        Text(
                          _question.prompt,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        for (var index = 0;
                            index < _question.options.length;
                            index++)
                          _AnswerOption(
                            label: _question.options[index],
                            selected: _selected == index,
                            disabled: _submitted,
                            onTap: () => _selectAnswer(index),
                          ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            FilledButton.icon(
                              onPressed: _selected == null ? null : _submitAnswer,
                              icon: const Icon(Icons.check),
                              label: const Text('Submit / 回答する'),
                            ),
                            if (_submitted)
                              OutlinedButton.icon(
                                onPressed: _resetQuestion,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Try again / もう一度'),
                              ),
                          ],
                        ),
                        if (_submitted) ...[
                          const SizedBox(height: 18),
                          _ResultBanner(
                            isCorrect: _selected == _question.answerIndex,
                            explanation: _question.explanation,
                          ),
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

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.label,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = selected
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: disabled ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
            ],
          ),
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
      child: Text('${isCorrect ? 'Correct!' : 'Review needed'}\n$explanation'),
    );
  }
}

class _ExamQuestion {
  const _ExamQuestion({
    required this.prompt,
    required this.options,
    required this.answerIndex,
    required this.explanation,
  });

  final String prompt;
  final List<String> options;
  final int answerIndex;
  final String explanation;
}
