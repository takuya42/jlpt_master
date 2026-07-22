import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Displays the Vocabulary study instructions once, on top of [child].
class VocabularyOnboardingWidget extends StatefulWidget {
  const VocabularyOnboardingWidget({required this.child, super.key});

  static const preferencesKey = 'hasSeenVocabularyOnboarding';

  final Widget child;

  @override
  State<VocabularyOnboardingWidget> createState() =>
      _VocabularyOnboardingWidgetState();
}

class _VocabularyOnboardingWidgetState
    extends State<VocabularyOnboardingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _gestureController;
  bool _isVisible = false;
  int _gestureCycles = 0;

  @override
  void initState() {
    super.initState();
    _gestureController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    )..addStatusListener(_handleGestureStatus);
    _gestureController.forward();
    unawaited(_loadVisibility());
  }

  void _handleGestureStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _gestureCycles >= 2) return;
    _gestureCycles += 1;
    _gestureController.forward(from: 0);
  }

  Future<void> _loadVisibility() async {
    final preferences = await SharedPreferences.getInstance();
    final hasSeen =
        preferences.getBool(VocabularyOnboardingWidget.preferencesKey) ?? false;
    if (mounted && !hasSeen) setState(() => _isVisible = true);
  }

  Future<void> _dismiss() async {
    setState(() => _isVisible = false);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(
      VocabularyOnboardingWidget.preferencesKey,
      true,
    );
  }

  @override
  void dispose() {
    _gestureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isVisible)
          Positioned.fill(
            child: Material(
              key: const ValueKey('vocabulary-onboarding'),
              color: Colors.black.withValues(alpha: 0.76),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _OnboardingCard(
                      gestureController: _gestureController,
                      onDismiss: _dismiss,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({
    required this.gestureController,
    required this.onDismiss,
  });

  final Animation<double> gestureController;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Card(
        elevation: 16,
        color: colors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 30, 28, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school_rounded, size: 36, color: colors.primary),
              const SizedBox(height: 14),
              Text(
                'How to Study',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '☝️  Swipe right to move to the next card.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurface,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '☝️  右にスワイプすると次のカードへ進みます。',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                height: 64,
                child: AnimatedBuilder(
                  animation: gestureController,
                  builder: (context, child) {
                    final progress = Curves.easeInOut.transform(
                      gestureController.value,
                    );
                    return Transform.translate(
                      offset: Offset((progress * 90) - 45, 0),
                      child: Opacity(
                        opacity: 0.45 + (0.55 * (1 - progress)),
                        child: child,
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('☝️', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 40,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Learning'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
