import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';

class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class LoadingSkeletonBox extends StatefulWidget {
  const LoadingSkeletonBox({
    super.key,
    this.width = 28,
    this.height = 12,
  });

  final double width;
  final double height;

  @override
  State<LoadingSkeletonBox> createState() => _LoadingSkeletonBoxState();
}

class _LoadingSkeletonBoxState extends State<LoadingSkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  )..repeat();
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            gradient: LinearGradient(
              begin: Alignment(-2 + _animation.value * 4, 0),
              end: Alignment(-1 + _animation.value * 4, 0),
              colors: const [
                Color(0xFFE4E8EF),
                Color(0xFFF8FAFC),
                Color(0xFFE4E8EF),
              ],
            ),
          ),
          child: child,
        ),
        child: SizedBox(width: widget.width, height: widget.height),
      );
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  )..repeat();
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
        label: '読み込み中',
        child: ExcludeSemantics(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) => ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment(-1.8 + _animation.value * 3.6, 0),
                end: Alignment(-.8 + _animation.value * 3.6, 0),
                colors: const [
                  Color(0xFFE8ECF2),
                  Color(0xFFF8FAFC),
                  Color(0xFFE8ECF2),
                ],
                stops: const [0, .5, 1],
              ).createShader(bounds),
              child: child,
            ),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              itemCount: widget.itemCount,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 16),
              itemBuilder: (context, index) => DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.extraLarge),
                ),
                child: SizedBox(height: index == 0 ? 148 : 108),
              ),
            ),
          ),
        ),
      );
}
