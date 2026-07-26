import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../extensions/build_context_extensions.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 92,
              height: 76,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 5,
                    top: 8,
                    child: _IllustrationDot(
                      size: 22,
                      color: AppColors.accent.withValues(alpha: .2),
                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 4,
                    child: _IllustrationDot(
                      size: 30,
                      color: AppColors.warning.withValues(alpha: .18),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.large),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SizedBox.square(
                      dimension: 62,
                      child: Icon(
                        icon,
                        size: 32,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(title, style: context.textStyles.titleMedium),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium,
            ),
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      );
}

class _IllustrationDot extends StatelessWidget {
  const _IllustrationDot({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: SizedBox.square(dimension: size),
      );
}
