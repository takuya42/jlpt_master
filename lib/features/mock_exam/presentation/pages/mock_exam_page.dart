import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class MockExamPage extends StatefulWidget {
  const MockExamPage({super.key});

  @override
  State<MockExamPage> createState() => _MockExamPageState();
}

class _MockExamPageState extends State<MockExamPage> {
  int? _selected;
  bool _submitted = false;
  bool _saving = false;
  String? _saveMessage;

  static const _question = _ExamQuestion(
    prompt: '「学校」の読み方はどれですか。',
    options: ['がっこう', 'がこう', 'がくこ', 'まなびや'],
    answerIndex: 0,
    explanation: '学校 is read がっこう and means school.',
  );

  Future<void> _submit() async {
    final selected = _selected;
    if (selected == null || _submitted) return;

    setState(() {
      _submitted = true;
      _saving = true;
      _saveMessage = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _saving = false;
        _saveMessage = 'ログインすると学習履歴を保存できます。';
      });
      return;
    }

    final isCorrect = selected == _question.answerIndex;
    final firestore = FirebaseFirestore.instance;
    final userRef = firestore.collection('users').doc(user.uid);

    try {
      await userRef.collection('studyHistory').add({
        'type': 'mockExam',
        'title': 'N5 Vocabulary Mock Exam',
        'correct': isCorrect,
        'answeredAt': FieldValue.serverTimestamp(),
        'studyMinutes': 5,
      });
      await userRef.set({
        'statistics': {
          'studyMinutes': FieldValue.increment(5),
          'weeklyStudyMinutes': FieldValue.increment(5),
          'completedLessons': FieldValue.increment(1),
          'correctAnswers': FieldValue.increment(isCorrect ? 1 : 0),
          'totalAnswers': FieldValue.increment(1),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveMessage = '学習履歴を保存しました。';
      });
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveMessage = error.message ?? error.code;
      });
    }
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
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Mock Exam',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text('本番形式で1問ずつ練習しましょう。', style: theme.textTheme.bodyLarge),
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
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
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
                          onPressed: _selected == null || _saving ? null : _submit,
                          icon: _saving
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.check),
                          label: const Text('Submit / 回答する'),
                        ),
                        if (_submitted) ...[
                          const SizedBox(height: 18),
                          _ResultBanner(
                            isCorrect: _selected == _question.answerIndex,
                            explanation: _question.explanation,
                          ),
                        ],
                        if (_saveMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(_saveMessage!),
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
