import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/theme/vocabulary_card_theme.dart';

const _tutorialSwipeDistance = 52.0;
const _tutorialSwipeRotation = 0.3141592653589793; // 18 degrees.

/// Shows the study guide used by onboarding.
Future<bool> showVocabularyStudyDialog(BuildContext context) async {
  final dismissedWithButton = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    builder: (context) => const VocabularyStudyDialog(),
  );
  return dismissedWithButton ?? false;
}

/// Material 3 study instructions for onboarding.
class VocabularyStudyDialog extends StatefulWidget {
  const VocabularyStudyDialog({super.key});

  @override
  State<VocabularyStudyDialog> createState() => _VocabularyStudyDialogState();
}

class _VocabularyStudyDialogState extends State<VocabularyStudyDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _gestureController;
  late final Animation<double> _swipeProgress;

  @override
  void initState() {
    super.initState();
    _gestureController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _swipeProgress = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 20,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 10),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 20,
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 50),
    ]).animate(_gestureController);
    _gestureController.repeat();
  }

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
                    child: Center(
                      // Exclude the whole animated branch, rather than only
                      // the card below the transforms. RenderTransform updates
                      // semantic geometry when its matrix changes, so leaving
                      // the transforms in the semantics tree dirties semantic
                      // parent data on every animation tick.
                      child: ExcludeSemantics(
                        child: AnimatedBuilder(
                          animation: _swipeProgress,
                          // The static card is built once by AnimatedBuilder.
                          // Only the two transform widgets change per tick.
                          child: const _PreviewCard(),
                          builder: (context, child) {
                            final progress = _swipeProgress.value;
                            return Transform.translate(
                              offset: Offset(
                                _tutorialSwipeDistance * progress,
                                0,
                              ),
                              child: Transform.rotate(
                                angle: _tutorialSwipeRotation * progress,
                                child: child,
                              ),
                            );
                          },
                        ),
                      ),
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
          // The builder's context belongs to the navigator selected by
          // showDialog, so this always removes the route that owns the modal
          // barrier, including when the page is inside a nested Navigator.
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Start Learning'),
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = theme.extension<VocabularyCardTheme>() ??
        VocabularyCardTheme.forBrightness(theme.brightness);

    return Card(
      key: const ValueKey('tutorial-vocabulary-card'),
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: cardTheme.cardGradient,
            stops: const [0, .48, 1],
          ),
          border: Border.all(color: cardTheme.borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: cardTheme.shadowColor.withValues(alpha: .24),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: cardTheme.highlightColor,
              blurRadius: 4,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: 168,
          height: 142,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 18,
                  color: cardTheme.secondaryTextColor,
                ),
                const Spacer(),
                Text(
                  '勉強',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: cardTheme.primaryTextColor,
                    fontWeight: FontWeight.w700,
                    shadows: cardTheme.textShadow,
                  ),
                ),
                Text(
                  'study',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cardTheme.secondaryTextColor,
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
  Widget build(BuildContext context) {
    return widget.child;
  }
}
