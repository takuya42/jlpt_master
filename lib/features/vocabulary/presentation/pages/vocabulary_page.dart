import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/widgets/app_state_views.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../providers/vocabulary_providers.dart';

class VocabularyPage extends ConsumerStatefulWidget {
  const VocabularyPage({super.key});

  @override
  ConsumerState<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends ConsumerState<VocabularyPage> {
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(vocabularyQuizProvider, (previous, next) {
      final previousWordId = previous?.value?.word?.id;
      final nextWordId = next.value?.word?.id;
      if (previousWordId != nextWordId) {
        _answerController.clear();
      }
    });

    final quiz = ref.watch(vocabularyQuizProvider);

    return Scaffold(
      appBar: AppBar(actions: const [PremiumButton()]),
      body: SafeArea(
        child: quiz.when(
          data: (state) => state.word == null
              ? const _EmptyVocabularyQuizView()
              : _VocabularyQuizCard(
                  state: state,
                  answerController: _answerController,
                ),
          error: (error, stackTrace) => AppErrorView(
            title: 'Could not load Vocabulary Quiz / 単語クイズを読み込めません',
            message: error.toString(),
            onRetry: () => ref.invalidate(vocabularyQuizProvider),
          ),
          loading: () => const AppLoadingView(message: 'Loading Vocabulary Quiz\n単語クイズを読み込み中'),
        ),
      ),
    );
  }
}

class _VocabularyQuizCard extends ConsumerWidget {
  const _VocabularyQuizCard({required this.state, required this.answerController});

  final VocabularyQuizState state;
  final TextEditingController answerController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final word = state.word!;
    final isAnswered = state.isCorrect != null;
    final resultColor = state.isCorrect == true ? Colors.green : colorScheme.error;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Vocabulary\n単語',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    word.word,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  if (word.reading.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      word.reading,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                  const SizedBox(height: 28),
                  TextField(
                    controller: answerController,
                    enabled: !isAnswered,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Enter English',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => ref.read(vocabularyQuizProvider.notifier).updateAnswer(value),
                    onSubmitted: (_) {
                      if (!isAnswered) {
                        ref.read(vocabularyQuizProvider.notifier).checkAnswer();
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  if (!isAnswered)
                    FilledButton(
                      onPressed: state.answer.trim().isEmpty ? null : () => ref.read(vocabularyQuizProvider.notifier).checkAnswer(),
                      child: const Text('Check'),
                    )
                  else ...[
                    Text(
                      state.isCorrect == true ? 'Correct!' : 'Incorrect',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(color: resultColor, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Correct Answer',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      word.meaning,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: () => ref.read(vocabularyQuizProvider.notifier).nextQuestion(),
                      child: const Text('Next'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyVocabularyQuizView extends StatelessWidget {
  const _EmptyVocabularyQuizView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No vocabulary found / 単語が見つかりません'));
  }
}
