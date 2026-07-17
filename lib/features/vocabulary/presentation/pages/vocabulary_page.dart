import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/vocabulary_card_theme.dart';
import '../../../../shared/presentation/widgets/app_background.dart';
import '../../../../shared/presentation/widgets/app_state_views.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../../domain/vocabulary_word.dart';
import '../providers/vocabulary_providers.dart';
import '../../../study_stats/presentation/providers/study_stats_provider.dart';

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
  late final DateTime _studyStartedAt;
  Animation<Offset>? _settleAnimation;

  @override
  void initState() {
    super.initState();
    _studyStartedAt = DateTime.now();
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
    unawaited(ref.read(studyStatsProvider.notifier).addStudyTime(DateTime.now().difference(_studyStartedAt)));
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
    if (state?.word == null || state?.nextWord == null || _isSwipingAway) return;
    _swipeController.stop();
  }

  void _handleCardDragUpdate(DragUpdateDetails details) {
    final asyncState = ref.read(vocabularyQuizProvider);
    final state = asyncState.hasValue ? asyncState.value : null;
    if (state?.word == null || state?.nextWord == null || _isSwipingAway) return;
    final nextDx = math.max(0.0, _dragOffset.dx + details.delta.dx);
    setState(() => _dragOffset = Offset(nextDx, _dragOffset.dy + details.delta.dy * 0.35));
  }

  void _handleCardDragEnd(DragEndDetails details) {
    final asyncState = ref.read(vocabularyQuizProvider);
    final state = asyncState.hasValue ? asyncState.value : null;
    if (state?.word == null || state?.nextWord == null || _isSwipingAway) return;

    final width = MediaQuery.sizeOf(context).width;
    final velocityX = details.velocity.pixelsPerSecond.dx;
    final shouldAdvance = _dragOffset.dx > width * 0.18 || velocityX > 640;

    if (shouldAdvance) {
      final begin = _dragOffset;
      final end = Offset(width + 260, _dragOffset.dy + details.velocity.pixelsPerSecond.dy.clamp(-360.0, 360.0) * 0.18);
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
    ref.listen(quizDirectionProvider, (previous, next) {
      if (previous == next) return;
      _answerController.clear();
      ref.read(vocabularyQuizProvider.notifier).resetAnswer();
    });

    final quiz = ref.watch(vocabularyQuizProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [PremiumButton()],
      ),
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _VocabularyLevelFilters(),
                    const SizedBox(height: 14),
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
                      loading: () => const SizedBox(height: 500),
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

class _VocabularyLevelFilters extends ConsumerWidget {
  const _VocabularyLevelFilters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLevel = ref.watch(selectedVocabularyJlptProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
                        child: Text(
                          level,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: selectedLevel == level ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                              ),
                        ),
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

class _VocabularyCardStack extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final cardHeight = width > 700 ? 428.0 : 408.0;
    final direction = ref.watch(quizDirectionProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: _DirectionToggleButton(direction: direction),
          ),
          const SizedBox(height: 10),
          SizedBox(
          height: cardHeight + 64,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                for (var i = 2; i >= 1; i--) _BackCard(index: i, height: cardHeight, liftProgress: (dragOffset.dx / 180).clamp(0, 1).toDouble()),
                AnimatedBuilder(
                  animation: Listenable.merge([entranceController, resultController, shakeController, swipeController]),
                  child: _VocabularyQuizCard(
                    state: state,
                    answerController: answerController,
                    dragProgress: (dragOffset.dx / 180).clamp(0, 1).toDouble(),
                  ),
                  builder: (context, child) {
                    final entrance = Curves.easeOutBack.transform(entranceController.value);
                    final pop = math.sin(resultController.value * math.pi) * 0.045;
                    final lift = state.isCorrect == true ? -18.0 * Curves.easeOutCubic.transform(resultController.value) : 0.0;
                    final shake = state.isCorrect == false ? math.sin(shakeController.value * math.pi * 8) * 10 * (1 - shakeController.value) : 0.0;
                    final dragProgress = (dragOffset.dx / 180).clamp(0, 1).toDouble();
                    final rotation = (dragOffset.dx / math.max(width, 1) * 0.28).clamp(-0.14, 0.14);
                    final card = Opacity(
                      opacity: entrance.clamp(0, 1).toDouble(),
                      child: Transform.translate(
                        offset: Offset(44 * (1 - entrance) + shake, 34 * (1 - entrance) + lift) + dragOffset,
                        child: Transform.rotate(
                          angle: rotation,
                          child: Transform.scale(scale: 0.9 + 0.1 * entrance + pop + dragProgress * 0.025, child: child),
                        ),
                      ),
                    );
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragStart: onDragStart,
                      onHorizontalDragUpdate: onDragUpdate,
                      onHorizontalDragEnd: onDragEnd,
                      child: card,
                    );
                  },
                ),
                if (state.isCorrect != null) _ResultOverlay(isCorrect: state.isCorrect!, controller: resultController),
                _PremiumConfetti(controller: confettiController),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackCard extends StatelessWidget {
  const _BackCard({required this.index, required this.height, required this.liftProgress});
  final int index;
  final double height;
  final double liftProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = theme.extension<VocabularyCardTheme>() ??
        VocabularyCardTheme.forBrightness(theme.brightness);
    final baseOffset = Offset(24.0 * index, 24.0 * index);
    final promotedOffset = index == 1 ? const Offset(8, 8) : const Offset(24, 24);
    final baseScale = index == 1 ? 0.96 : 0.92;
    final promotedScale = index == 1 ? 0.985 : 0.955;
    final t = Curves.easeOutCubic.transform(liftProgress);
    final offset = Offset.lerp(baseOffset, promotedOffset, t)!;
    final scale = lerpDouble(baseScale, promotedScale, t)!;
    final opacity = lerpDouble(index == 1 ? 0.66 : 0.46, index == 1 ? 0.84 : 0.66, t)!;
    return Transform.translate(
      offset: offset,
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: Container(
          height: height,
            margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: cardTheme.backCardGradient,
              ),
              boxShadow: [BoxShadow(color: cardTheme.shadowColor.withValues(alpha: index == 1 ? .20 : .12), blurRadius: index == 1 ? 30 : 22, offset: Offset(0, index == 1 ? 18 : 14))],
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
    // The explicit brightness fallback keeps standalone cards correct even
    // when embedded in an app that has not registered the extension yet.
    final cardTheme = theme.extension<VocabularyCardTheme>() ??
        VocabularyCardTheme.forBrightness(theme.brightness);
    final word = state.word!;
    final direction = ref.watch(quizDirectionProvider);
    final isAnswered = state.isCorrect != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      constraints: const BoxConstraints(maxWidth: 620, minHeight: 408, maxHeight: 428),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: cardTheme.cardGradient,
          stops: [0, .48, 1],
        ),
        border: Border.all(color: cardTheme.borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(color: cardTheme.shadowColor.withValues(alpha: 0.18 + dragProgress * 0.08), blurRadius: 44 + dragProgress * 18, offset: Offset(0, 28 + dragProgress * 8)),
          BoxShadow(color: cardTheme.highlightColor, blurRadius: 6, offset: const Offset(-3, -3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Stack(
          children: [
            Positioned(
              top: -36,
              right: -46,
              child: Container(
                width: 128,
              height: 128,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cardTheme.decorationColor,
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
            height: 108,
              child: DecoratedBox(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cardTheme.highlightColor,
                      cardTheme.highlightColor.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.menu_book_rounded, size: 22, color: cardTheme.secondaryTextColor),
                      const SizedBox(width: 8),
                      Text(
                        'Vocabulary Quest',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: cardTheme.secondaryTextColor,
                          shadows: cardTheme.textShadow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                    child: _VocabularyPrompt(
                      key: ValueKey('${word.id}-${direction.name}'),
                      word: word,
                      direction: direction,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _GlassTextField(
                      controller: answerController,
                      enabled: !isAnswered,
                      labelText: direction.inputLabel,
                      onChanged: (value) => ref.read(vocabularyQuizProvider.notifier).updateAnswer(value),
                      onSubmitted: (_) {
                        if (!isAnswered) ref.read(vocabularyQuizProvider.notifier).checkAnswer();
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
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
                              Text('Correct Answer', style: theme.textTheme.labelLarge?.copyWith(color: cardTheme.secondaryTextColor, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Text(direction.correctAnswerFor(word), textAlign: TextAlign.center, style: theme.textTheme.headlineSmall?.copyWith(color: cardTheme.primaryTextColor, fontWeight: FontWeight.w900, shadows: cardTheme.textShadow)),
                              const SizedBox(height: 10),
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


class _DirectionToggleButton extends ConsumerWidget {
  const _DirectionToggleButton({required this.direction});

  final QuizDirection direction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final nextDirection = direction == QuizDirection.japaneseToEnglish
        ? QuizDirection.englishToJapanese
        : QuizDirection.japaneseToEnglish;
    return Semantics(
      button: true,
      label: 'Switch quiz direction',
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () =>
            ref.read(quizDirectionProvider.notifier).setDirection(nextDirection),
        child: SizedBox(
          width: 80,
          height: 34,
          child: DecoratedBox(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: colorScheme.onSurface.withValues(alpha: 0.06),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Center(
              child: Text(
                direction.toggleLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VocabularyPrompt extends StatelessWidget {
  const _VocabularyPrompt({super.key, required this.word, required this.direction});

  final VocabularyWord word;
  final QuizDirection direction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = theme.extension<VocabularyCardTheme>() ??
        VocabularyCardTheme.forBrightness(theme.brightness);
    return Column(
      children: [
        Text(
          direction.prompt,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: cardTheme.secondaryTextColor,
            shadows: cardTheme.textShadow,
          ),
        ),
        const SizedBox(height: 8),
        if (direction == QuizDirection.japaneseToEnglish) ...[
          Hero(
            tag: 'vocabulary-${word.id}',
            child: Material(
              color: Colors.transparent,
              child: Text(
                word.word,
                textAlign: TextAlign.center,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontSize: 50,
                  fontWeight: FontWeight.w900,
                  color: cardTheme.primaryTextColor,
                  letterSpacing: -1.4,
                  shadows: cardTheme.textShadow,
                ),
              ),
            ),
          ),
          if (word.reading.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              word.reading,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 22,
                color: cardTheme.secondaryTextColor,
                fontWeight: FontWeight.w800,
                shadows: cardTheme.textShadow,
              ),
            ),
          ],
        ] else
          Text(
            direction.englishFor(word),
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall?.copyWith(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: cardTheme.primaryTextColor,
              letterSpacing: -1.1,
              shadows: cardTheme.textShadow,
            ),
          ),
      ],
    );
  }
}

class _SwipeForNextHint extends StatelessWidget {
  const _SwipeForNextHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Semantics(
      label: 'Swipe for next',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: colorScheme.onSurface.withValues(alpha: 0.06),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swipe_rounded, size: 20, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              '→ Swipe for next',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
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
  const _GlassTextField({required this.controller, required this.enabled, required this.labelText, required this.onChanged, required this.onSubmitted});
  final TextEditingController controller;
  final bool enabled;
  final String labelText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardTheme = theme.extension<VocabularyCardTheme>() ??
        VocabularyCardTheme.forBrightness(theme.brightness);

    return TextField(
      controller: controller,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: cardTheme.primaryTextColor,
        fontWeight: FontWeight.w700,
      ),
      enabled: enabled,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
          labelText: labelText,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: cardTheme.secondaryTextColor,
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: cardTheme.inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: cardTheme.inputBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
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
    final theme = Theme.of(context);
    final cardTheme = theme.extension<VocabularyCardTheme>() ??
        VocabularyCardTheme.forBrightness(theme.brightness);
    return AnimatedScale(
      scale: _pressed ? 0.965 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: widget.enabled ? (_) { setState(() => _pressed = false); widget.onPressed(); } : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          curve: Curves.easeOutCubic,
          height: 46,
          transform: Matrix4.translationValues(0, _pressed ? 3 : 0, 0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.enabled
                    ? cardTheme.buttonGradient
                    : cardTheme.disabledButtonGradient,
              ),
              boxShadow: [
                BoxShadow(
                  color: cardTheme.shadowColor.withValues(alpha: widget.enabled ? (_pressed ? 0.18 : 0.32) : 0.18),
                  blurRadius: _pressed ? 10 : 24,
                  offset: Offset(0, _pressed ? 5 : 14),
                ),
              ],
            ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: cardTheme.buttonForegroundColor),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  color: cardTheme.buttonForegroundColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
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
