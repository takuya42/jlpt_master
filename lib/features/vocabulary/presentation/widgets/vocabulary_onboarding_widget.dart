import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'vocabulary_swipe_motion.dart';

/// Shows the same study guide used by onboarding and the AppBar help action.
Future<bool> showVocabularyStudyDialog(BuildContext context) async {
  final dismissedWithButton = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    builder: (context) => const VocabularyStudyDialog(),
  );
  return dismissedWithButton ?? false;
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
    duration: const Duration(milliseconds: 1800),
  )..repeat();

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
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      backgroundColor: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Text(
        'How to Study',
        style: theme.textTheme.headlineSmall?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 280;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Swipe right to go to the next card.',
                    key: const ValueKey('study-guide-english'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: compact ? 13 : 15,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '右にスワイプすると次のカードへ進みます。',
                    key: const ValueKey('study-guide-japanese'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: compact ? 13 : 14,
                      height: 1.5,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 178,
                    child: AnimatedBuilder(
                      animation: _gestureController,
                      builder: (context, child) {
                        final progress = TweenSequence<double>([
                          TweenSequenceItem(
                            tween: Tween(begin: 0.0, end: 1.0).chain(
                              CurveTween(curve: Curves.easeOutCubic),
                            ),
                            weight: 42,
                          ),
                          TweenSequenceItem(
                            tween: ConstantTween(1.0),
                            weight: 16,
                          ),
                          TweenSequenceItem(
                            tween: Tween(begin: 1.0, end: 0.0).chain(
                              CurveTween(curve: Curves.easeOutBack),
                            ),
                            weight: 42,
                          ),
                        ]).transform(_gestureController.value);
                        return Transform.translate(
                          offset: Offset(52 * progress, 0),
                          child: Transform.rotate(
                            angle: vocabularySwipeRotation * progress,
                            child: child,
                          ),
                        );
                      },
                      child: const _MiniVocabularyCard(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(
            context,
            rootNavigator: true,
          ).pop(true),
          child: const Text('Close / 閉じる'),
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
    );
  }
}

class _MiniVocabularyCard extends StatelessWidget {
  const _MiniVocabularyCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Center(
      child: Container(
        key: const ValueKey('tutorial-vocabulary-card'),
        width: 168,
        height: 142,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.surfaceContainerHighest, colors.surfaceContainer],
          ),
          border: Border.all(color: colors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: .28),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -22,
              top: -28,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primaryContainer.withValues(alpha: .45),
                ),
                child: const SizedBox.square(dimension: 78),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 18,
                    color: colors.onSurfaceVariant,
                  ),
                  const Spacer(),
                  Text(
                    '勉強',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'study',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays the Vocabulary study dialog once, on top of [child].
class VocabularyOnboardingWidget extends StatefulWidget {
  const VocabularyOnboardingWidget({
    required this.child,
    this.forceShow = forceShowForDebugging,
    super.key,
  });

  static const preferencesKey = 'hasSeenVocabularyOnboarding';

  /// Pass `--dart-define=SHOW_VOCABULARY_ONBOARDING=true` in a debug run to
  /// display the guide on every visit without clearing app data.
  static const forceShowForDebugging = bool.fromEnvironment(
    'SHOW_VOCABULARY_ONBOARDING',
  );

  final Widget child;
  final bool forceShow;

  @override
  State<VocabularyOnboardingWidget> createState() =>
      _VocabularyOnboardingWidgetState();
}

class _VocabularyOnboardingWidgetState
    extends State<VocabularyOnboardingWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_showOnboardingIfNeeded());
    });
  }

  Future<void> _showOnboardingIfNeeded() async {
    final preferences = await SharedPreferences.getInstance();
    final hasSeen =
        preferences.getBool(VocabularyOnboardingWidget.preferencesKey) ?? false;
    final forceShow = kDebugMode && widget.forceShow;
    if (!mounted || (hasSeen && !forceShow)) return;

    final dismissedWithButton = await showVocabularyStudyDialog(context);
    if (dismissedWithButton && !forceShow) {
      await preferences.setBool(
        VocabularyOnboardingWidget.preferencesKey,
        true,
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
