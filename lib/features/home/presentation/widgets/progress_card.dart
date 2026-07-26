import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/extensions/build_context_extensions.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.solvedCount,
    this.dailyGoal = 10,
  });

  final int solvedCount;
  final int dailyGoal;

  @override
  Widget build(BuildContext context) {
    final remaining = (dailyGoal - solvedCount).clamp(0, dailyGoal);
    final achieved = remaining == 0;
    final progress = dailyGoal == 0
        ? 1.0
        : (solvedCount / dailyGoal).clamp(0, 1).toDouble();

    return Row(
      children: [
        SizedBox.square(
          dimension: 84,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                  backgroundColor: AppColors.border,
                  color: achieved ? AppColors.success : AppColors.textPrimary,
                ),
              ),
              Text(
                '$solvedCount',
                style: context.textStyles.headlineSmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('今日の目標', style: context.textStyles.bodyMedium),
              const SizedBox(height: 4),
              Text(
                achieved ? '今日の目標達成！' : 'あと$remaining問',
                style: context.textStyles.titleLarge?.copyWith(
                  color: achieved ? AppColors.success : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$solvedCount / $dailyGoal 問',
                style: context.textStyles.bodyMedium?.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
