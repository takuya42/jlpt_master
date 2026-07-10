import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/user_learning_repository.dart';
import '../providers/learning_providers.dart';

class LearningGoalPage extends ConsumerWidget {
  const LearningGoalPage({super.key});

  static const _goals = [
    LearningGoal(type: LearningGoalType.questions, value: 10),
    LearningGoal(type: LearningGoalType.questions, value: 20),
    LearningGoal(type: LearningGoalType.questions, value: 30),
    LearningGoal(type: LearningGoalType.minutes, value: 60),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(learningGoalProvider).asData?.value ?? LearningGoal.defaultGoal();
    return Scaffold(
      appBar: AppBar(title: const Text('Learning Goal / 学習目標')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
              children: [
                Text('Daily Goal\n毎日の学習目標', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                Text('Choose a daily target.\n毎日の目標を選択してください。', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 20),
                for (final goal in _goals)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: RadioListTile<LearningGoal>(
                        value: goal,
                        groupValue: _goals.firstWhere((item) => item.type == selected.type && item.value == selected.value, orElse: () => selected),
                        onChanged: (value) async {
                          if (value == null) return;
                          await ref.read(userLearningRepositoryProvider).saveLearningGoal(value);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved: ${value.label} / ${value.japaneseLabel}')));
                          }
                        },
                        title: Text(goal.label, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                        subtitle: Text(goal.japaneseLabel),
                        secondary: Icon(goal.type == LearningGoalType.minutes ? Icons.timer_outlined : Icons.quiz_outlined),
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
