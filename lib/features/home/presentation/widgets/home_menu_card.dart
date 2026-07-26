import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../shared/extensions/build_context_extensions.dart';

class HomeMenuCard extends StatefulWidget {
  const HomeMenuCard({
    super.key,
    required this.heroTag,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String heroTag;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<HomeMenuCard> createState() => _HomeMenuCardState();
}

class _HomeMenuCardState extends State<HomeMenuCard> {
  static const _duration = Duration(milliseconds: 200);
  var _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) => AnimatedScale(
        scale: _pressed ? .96 : 1,
        duration: _duration,
        curve: Curves.easeOutCubic,
        child: Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.extraLarge),
            splashColor: AppColors.primary.withValues(alpha: .06),
            highlightColor: AppColors.surface,
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onTap();
            },
            onTapDown: (_) => _setPressed(true),
            onTapCancel: () => _setPressed(false),
            onTapUp: (_) => _setPressed(false),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: widget.heroTag,
                    child: Material(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      child: SizedBox.square(
                        dimension: 48,
                        child: Icon(
                          widget.icon,
                          size: 27,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              maxLines: 1,
                              style: context.textStyles.titleMedium,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textStyles.bodyMedium?.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 19,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
