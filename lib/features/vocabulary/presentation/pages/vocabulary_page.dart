import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/widgets/app_state_views.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../providers/vocabulary_providers.dart';

class VocabularyPage extends ConsumerStatefulWidget {
  const VocabularyPage({super.key});

  @override
  ConsumerState<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends ConsumerState<VocabularyPage> with TickerProviderStateMixin {
  final _answerController = TextEditingController();
  late final AnimationController _cardEntranceController;
  late final AnimationController _resultController;
  late final AnimationController _shakeController;
  late final AnimationController _confettiController;
  late final AnimationController _swipeController;
  Offset _dragOffset = Offset.zero;
  bool _isSwipingAway = false;
  Animation<Offset>? _settleAnimation;

  @override
  void initState() {
    super.initState();
    _cardEntranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 720))..forward();
    _resultController = AnimationController(vsync: this, duration: const Duration(milliseconds: 780));
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
    _confettiController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _swipeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 460))
      ..addListener(() {
        final animation = _settleAnimation;
        if (animation != null && mounted) {
          setState(() => _dragOffset = animation.value);
        }
      });
  }

  @override
  void dispose() {
    _answerController.dispose();
    _cardEntranceController.dispose();
    _resultController.dispose();
    _shakeController.dispose();
    _confettiController.dispose();
    _swipeController.dispose();
    super.dispose();
  }

  void _playResultAnimation(bool isCorrect) {
    _resultController.forward(from: 0);
    if (isCorrect) {
      HapticFeedback.mediumImpact();
      _confettiController.forward(from: 0);
    } else {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0);
    }
  }

  void _handleCardDragStart(DragStartDetails details) {
    final asyncState = ref.read(vocabularyQuizProvider);
    final state = asyncState.hasValue ? asyncState.value : null;
    if (state?.isCorrect == null || _isSwipingAway) return;
    _swipeController.stop();
  }

  void _handleCardDragUpdate(DragUpdateDetails details) {
    final asyncState = ref.read(vocabularyQuizProvider);
    final state = asyncState.hasValue ? asyncState.value : null;
    if (state?.isCorrect == null || _isSwipingAway) return;
    setState(() => _dragOffset += details.delta);
  }

  void _handleCardDragEnd(DragEndDetails details) {
    final asyncState = ref.read(vocabularyQuizProvider);
    final state = asyncState.hasValue ? asyncState.value : null;
    if (state?.isCorrect == null || _isSwipingAway) return;

    final width = MediaQuery.sizeOf(context).width;
    final velocityX = details.velocity.pixelsPerSecond.dx;
    final shouldAdvance = _dragOffset.dx.abs() > width * 0.18 || velocityX.abs() > 640;

    if (shouldAdvance) {
      final direction = (_dragOffset.dx == 0 ? velocityX : _dragOffset.dx).sign == 0 ? 1.0 : (_dragOffset.dx == 0 ? velocityX : _dragOffset.dx).sign;
      final begin = _dragOffset;
      final end = Offset(direction * (width + 260), _dragOffset.dy + details.velocity.pixelsPerSecond.dy.clamp(-360.0, 360.0) * 0.18);
      _settleAnimation = Tween<Offset>(begin: begin, end: end).chain(CurveTween(curve: Curves.easeOutCubic)).animate(_swipeController);
      _isSwipingAway = true;
      _swipeController.forward(from: 0).whenComplete(() {
        if (!mounted) return;
        HapticFeedback.lightImpact();
        ref.read(vocabularyQuizProvider.notifier).nextQuestion();
      });
    } else {
      _settleAnimation = Tween<Offset>(begin: _dragOffset, end: Offset.zero).chain(CurveTween(curve: Curves.easeOutBack)).animate(_swipeController);
      _swipeController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(vocabularyQuizProvider, (previous, next) {
      VocabularyQuizState? previousState;
      if (previous != null && previous.hasValue) {
        previousState = previous.value;
      }

      VocabularyQuizState? nextState;
      if (next.hasValue) {
        nextState = next.value;
      }
      if (previousState?.word?.id != nextState?.word?.id) {
        _answerController.clear();
        _resultController.reset();
        _shakeController.reset();
        _cardEntranceController.forward(from: 0);
        _settleAnimation = null;
        _swipeController.reset();
        _dragOffset = Offset.zero;
        _isSwipingAway = false;
      }
      final wasUnanswered = previousState?.isCorrect == null;
      final isAnswered = nextState?.isCorrect != null;
      if (wasUnanswered && isAnswered) {
        _playResultAnimation(nextState!.isCorrect!);
      }
    });
    ref.listen(selectedVocabularyJlptProvider, (previous, next) {
      if (previous != next) _answerController.clear();
    });

    final quiz = ref.watch(vocabularyQuizProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [PremiumButton()],
      ),
      body: _LuxuryQuizBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _VocabularyLevelFilters(),
                    const SizedBox(height: 22),
                    quiz.when(
                      data: (state) => state.word == null
                          ? const _EmptyVocabularyQuizView()
                          : _VocabularyCardStack(
                              state: state,
                              answerController: _answerController,
                              entranceController: _cardEntranceController,
                              resultController: _resultController,
                              shakeController: _shakeController,
                              confettiController: _confettiController,
                              swipeController: _swipeController,
                              dragOffset: _dragOffset,
                              onDragStart: _handleCardDragStart,
                              onDragUpdate: _handleCardDragUpdate,
                              onDragEnd: _handleCardDragEnd,
                            ),
                      error: (error, stackTrace) => AppErrorView(
                        title: 'Could not load Vocabulary Quiz / 単語クイズを読み込めません',
                        message: error.toString(),
                        onRetry: () => ref.invalidate(vocabularyQuizProvider),
                      ),
                      loading: () => const AppLoadingView(message: 'Loading Vocabulary Quiz\n単語クイズを読み込み中'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LuxuryQuizBackground extends StatelessWidget {
  const _LuxuryQuizBackground({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF9F7FF), Color(0xFFEFF7FF), Color(0xFFFFF8EE)],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(top: -110, left: -70, child: _BlurGlow(size: 250, color: Color(0x889F7AEA))),
          const Positioned(top: 120, right: -120, child: _BlurGlow(size: 320, color: Color(0x77F6AD55))),
          const Positioned(bottom: -130, left: 40, child: _BlurGlow(size: 300, color: Color(0x6686E7D4))),
          BackdropFilter(filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18), child: child),
        ],
      ),
    );
  }
}

class _BlurGlow extends StatelessWidget {
  const _BlurGlow({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: [BoxShadow(color: color, blurRadius: 80, spreadRadius: 30)]),
      );
}

class _VocabularyLevelFilters extends ConsumerWidget {
  const _VocabularyLevelFilters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLevel = ref.watch(selectedVocabularyJlptProvider);
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.52), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.72))),
          child: Row(
            children: [
              for (final level in vocabularyJlptLevels)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: selectedLevel == level ? const LinearGradient(colors: [Color(0xFF111827), Color(0xFF475569)]) : null,
                      boxShadow: selectedLevel == level ? const [BoxShadow(color: Color(0x33111827), blurRadius: 16, offset: Offset(0, 8))] : null,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => ref.read(selectedVocabularyJlptProvider.notifier).selectLevel(level),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        child: Text(level, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, color: selectedLevel == level ? Colors.white : const Color(0xFF64748B))),
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

class _VocabularyCardStack extends StatelessWidget {
  const _VocabularyCardStack({
    required this.state,
    required this.answerController,
    required this.entranceController,
    required this.resultController,
    required this.shakeController,
    required this.confettiController,
    required this.swipeController,
    required this.dragOffset,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final VocabularyQuizState state;
  final TextEditingController answerController;
  final AnimationController entranceController;
  final AnimationController resultController;
  final AnimationController shakeController;
  final AnimationController confettiController;
  final AnimationController swipeController;
  final Offset dragOffset;
  final GestureDragStartCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final GestureDragEndCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cardHeight = width > 700 ? 570.0 : 540.0;
    return SizedBox(
      height: cardHeight + 56,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          for (var i = 3; i >= 1; i--) _BackCard(index: i, liftProgress: (dragOffset.dx.abs() / 180).clamp(0, 1).toDouble()),
          AnimatedBuilder(
            animation: Listenable.merge([entranceController, resultController, shakeController, swipeController]),
            child: _VocabularyQuizCard(state: state, answerController: answerController, dragProgress: (dragOffset.dx.abs() / 180).clamp(0, 1).toDouble()),
            builder: (context, child) {
              final entrance = Curves.easeOutBack.transform(entranceController.value);
              final pop = math.sin(resultController.value * math.pi) * 0.045;
              final lift = state.isCorrect == true ? -18.0 * Curves.easeOutCubic.transform(resultController.value) : 0.0;
              final shake = state.isCorrect == false ? math.sin(shakeController.value * math.pi * 8) * 10 * (1 - shakeController.value) : 0.0;
              final dragProgress = (dragOffset.dx.abs() / 180).clamp(0, 1).toDouble();
              final rotation = (dragOffset.dx / math.max(width, 1) * 0.28).clamp(-0.14, 0.14);
              final card = Opacity(
                opacity: entrance.clamp(0, 1).toDouble(),
                child: Transform.translate(
                  offset: Offset(44 * (1 - entrance) + shake, 34 * (1 - entrance) + lift) + dragOffset,
                  child: Transform.rotate(
                    angle: rotation,
                    child: Transform.scale(scale: 0.9 + 0.1 * entrance + pop - dragProgress * 0.015, child: child),
                  ),
                ),
              );
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragStart: state.isCorrect != null ? onDragStart : null,
                onHorizontalDragUpdate: state.isCorrect != null ? onDragUpdate : null,
                onHorizontalDragEnd: state.isCorrect != null ? onDragEnd : null,
                child: card,
              );
            },
          ),
          if (state.isCorrect != null) _ResultOverlay(isCorrect: state.isCorrect!, controller: resultController),
          _PremiumConfetti(controller: confettiController),
        ],
      ),
    );
  }
}

class _BackCard extends StatelessWidget {
  const _BackCard({required this.index, required this.liftProgress});
  final int index;
  final double liftProgress;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(index.isOdd ? -10.0 * index : 10.0 * index, (20.0 * index) - (10 * liftProgress * (4 - index))),
      child: Transform.rotate(
        angle: (index.isOdd ? -1 : 1) * index * 0.018,
        child: Transform.scale(
          scale: 1 - index * 0.045 + liftProgress * 0.025 * (4 - index),
          child: Opacity(
            opacity: 0.72 - index * 0.12,
            child: Container(
              height: 510,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(32), color: Colors.white, boxShadow: const [BoxShadow(color: Color(0x1F334155), blurRadius: 36, offset: Offset(0, 22))]),
            ),
          ),
        ),
      ),
    );
  }
}

class _VocabularyQuizCard extends ConsumerWidget {
  const _VocabularyQuizCard({required this.state, required this.answerController, required this.dragProgress});

  final VocabularyQuizState state;
  final TextEditingController answerController;
  final double dragProgress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final word = state.word!;
    final isAnswered = state.isCorrect != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      constraints: const BoxConstraints(maxWidth: 620, minHeight: 520),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Color(0xFFFFFCF8)]),
        border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.4),
        boxShadow: [
          BoxShadow(color: const Color(0x24334155).withOpacity(0.14 + dragProgress * 0.08), blurRadius: 44 + dragProgress * 18, offset: Offset(0, 28 + dragProgress * 8)),
          const BoxShadow(color: Color(0x18FFFFFF), blurRadius: 8, offset: Offset(-4, -4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Positioned(top: -60, right: -80, child: Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFFF1D6).withOpacity(0.8)))),
            Positioned(top: 0, left: 0, right: 0, height: 120, child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0)])))),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Vocabulary Quest', textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.2, color: const Color(0xFF64748B))),
                  const SizedBox(height: 30),
                  Hero(tag: 'vocabulary-${word.id}', child: Material(color: Colors.transparent, child: Text(word.word, textAlign: TextAlign.center, style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A), letterSpacing: -1.4)))),
                  if (word.reading.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(word.reading, textAlign: TextAlign.center, style: theme.textTheme.titleLarge?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w700)),
                  ],
                  const Spacer(),
                  _GlassTextField(controller: answerController, enabled: !isAnswered, onChanged: (value) => ref.read(vocabularyQuizProvider.notifier).updateAnswer(value), onSubmitted: (_) { if (!isAnswered) ref.read(vocabularyQuizProvider.notifier).checkAnswer(); }),
                  const SizedBox(height: 18),
                  PageTransitionSwitcher(
                    duration: const Duration(milliseconds: 360),
                    reverse: !isAnswered,
                    transitionBuilder: (child, animation, secondaryAnimation) => FadeScaleTransition(animation: animation, child: child),
                    child: !isAnswered
                        ? _PressScaleButton(key: const ValueKey('check'), enabled: state.answer.trim().isNotEmpty, label: 'Check Answer', icon: Icons.auto_awesome, onPressed: () => ref.read(vocabularyQuizProvider.notifier).checkAnswer())
                        : Column(
                            key: const ValueKey('result'),
                            children: [
                              Text(state.isCorrect == true ? 'Correct!' : 'Incorrect', style: theme.textTheme.titleLarge?.copyWith(color: state.isCorrect == true ? const Color(0xFF16A34A) : const Color(0xFFEF4444), fontWeight: FontWeight.w900)),
                              const SizedBox(height: 8),
                              Text('Correct Answer', style: theme.textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Text(word.meaning, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                              const SizedBox(height: 18),
                              const _SwipeForNextHint(),
                            ],
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

class _SwipeForNextHint extends StatelessWidget {
  const _SwipeForNextHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Swipe for next',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: const Color(0xFF0F172A).withOpacity(0.06),
          border: Border.all(color: Colors.white.withOpacity(0.86)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.swipe_rounded, size: 20, color: Color(0xFF475569)),
            const SizedBox(width: 8),
            Text(
              '→ Swipe for next',
              style: theme.textTheme.labelLarge?.copyWith(
                color: const Color(0xFF475569),
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 360.ms, curve: Curves.easeOutCubic)
          .slideY(begin: 0.18, end: 0, duration: 360.ms, curve: Curves.easeOutCubic),
    );
  }
}

class _GlassTextField extends StatelessWidget {
  const _GlassTextField({required this.controller, required this.enabled, required this.onChanged, required this.onSubmitted});
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        enabled: enabled,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(labelText: 'Enter English', filled: true, fillColor: const Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: Color(0xFFE2E8F0))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: Color(0xFF94A3B8), width: 1.4))),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      );
}

class _PressScaleButton extends StatefulWidget {
  const _PressScaleButton({super.key, required this.label, required this.icon, required this.onPressed, this.enabled = true});
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  State<_PressScaleButton> createState() => _PressScaleButtonState();
}

class _PressScaleButtonState extends State<_PressScaleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.96 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: widget.enabled ? (_) { setState(() => _pressed = false); widget.onPressed(); } : null,
        child: AnimatedOpacity(
          opacity: widget.enabled ? 1 : 0.45,
          duration: const Duration(milliseconds: 180),
          child: Container(
            height: 58,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: const LinearGradient(colors: [Color(0xFF111827), Color(0xFF334155)]), boxShadow: const [BoxShadow(color: Color(0x44111827), blurRadius: 22, offset: Offset(0, 12))]),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(widget.icon, color: Colors.white), const SizedBox(width: 10), Text(widget.label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900))]),
          ),
        ),
      ),
    );
  }
}

class _ResultOverlay extends StatelessWidget {
  const _ResultOverlay({required this.isCorrect, required this.controller});
  final bool isCorrect;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final value = Curves.easeOutCubic.transform(controller.value);
          return Opacity(
            opacity: value.clamp(0, 1).toDouble(),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: (isCorrect ? const Color(0xFF22C55E) : const Color(0xFFEF4444)).withOpacity(0.32 * (1 - controller.value * 0.35)), blurRadius: isCorrect ? 70 : 46, spreadRadius: isCorrect ? 14 : 3)],
              ),
              child: Center(
                child: Transform.scale(
                  scale: 0.55 + value * 0.65,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: (isCorrect ? const Color(0xFF22C55E) : const Color(0xFFEF4444)).withOpacity(0.92), boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 12))]),
                    child: Icon(isCorrect ? Icons.check_rounded : Icons.close_rounded, color: Colors.white, size: 62),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PremiumConfetti extends StatelessWidget {
  const _PremiumConfetti({required this.controller});
  final AnimationController controller;

  static const _colors = [
    Color(0xFF22C55E),
    Color(0xFFFBBF24),
    Color(0xFF60A5FA),
    Color(0xFFF472B6),
    Color(0xFFA78BFA),
  ];

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final t = Curves.easeOutCubic.transform(controller.value);
          return Opacity(
            opacity: (1 - controller.value).clamp(0, 1).toDouble(),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                for (var i = 0; i < 18; i++)
                  Transform.translate(
                    offset: Offset(
                      math.cos(i * 0.9) * (36 + i * 5) * t,
                      80 + math.sin(i * 1.7) * 18 * t + 130 * t,
                    ),
                    child: Transform.rotate(
                      angle: t * math.pi * (1 + i % 4),
                      child: Container(
                        width: i.isEven ? 8 : 6,
                        height: i.isEven ? 14 : 6,
                        decoration: BoxDecoration(
                          color: _colors[i % _colors.length],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
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
