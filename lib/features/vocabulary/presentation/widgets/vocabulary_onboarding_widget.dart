import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shows the same study guide used by onboarding and the AppBar help action.
Future<void> showVocabularyStudyDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => const VocabularyStudyDialog(),
  );
}

/// Material 3 study instructions shared by onboarding and on-demand help.
class VocabularyStudyDialog extends StatefulWidget {
  const VocabularyStudyDialog({super.key});

  @override
  State<VocabularyStudyDialog> createState() => _VocabularyStudyDialogState();
}

class _VocabularyStudyDialogState extends State<VocabularyStudyDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _gestureController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _gestureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AlertDialog(
      key: const ValueKey('vocabulary-study-dialog'),
      backgroundColor: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Text(
        '🎓 How to Study',
        style: theme.textTheme.headlineSmall?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Swipe right to move to the next card.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
              ),
              const SizedBox(height: 8),
              Text(
                '右にスワイプすると次のカードへ進みます。',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '・右へスワイプ → 次の単語\n'
                '・左へスワイプ → 前の単語（対応している場合）\n'
                '・入力して「Check Answer」で答え合わせ\n'
                '・♡ボタンでお気に入り登録',
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 56,
                child: AnimatedBuilder(
                  animation: _gestureController,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(
                      Curves.easeInOut.transform(_gestureController.value) *
                              64 -
                          32,
                      0,
                    ),
                    child: child,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 44,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it'),
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
    );
  }
}

/// Displays the Vocabulary study dialog once, on top of [child].
class VocabularyOnboardingWidget extends StatefulWidget {
  const VocabularyOnboardingWidget({required this.child, super.key});

  static const preferencesKey = 'hasSeenVocabularyOnboarding';

  final Widget child;

  @override
  State<VocabularyOnboardingWidget> createState() =>
      _VocabularyOnboardingWidgetState();
}

class _VocabularyOnboardingWidgetState
    extends State<VocabularyOnboardingWidget> {
  @override
  void initState() {
    super.initState();
    unawaited(_showOnboardingIfNeeded());
  }

  Future<void> _showOnboardingIfNeeded() async {
    final preferences = await SharedPreferences.getInstance();
    final hasSeen =
        preferences.getBool(VocabularyOnboardingWidget.preferencesKey) ?? false;
    if (!mounted || hasSeen) return;

    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    await showVocabularyStudyDialog(context);
    await preferences.setBool(VocabularyOnboardingWidget.preferencesKey, true);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
