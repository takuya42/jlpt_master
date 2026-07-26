import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';

class AnimatedNavigationItem {
  const AnimatedNavigationItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class AnimatedBottomNavigation extends StatelessWidget {
  const AnimatedBottomNavigation({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<AnimatedNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _duration = Duration(milliseconds: 220);
  static const _curve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.extraLarge),
            boxShadow: const [
              BoxShadow(
                color: Color(0x180F172A),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.extraLarge),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .88),
                  borderRadius: BorderRadius.circular(AppRadius.extraLarge),
                  border: Border.all(color: Colors.white.withValues(alpha: .8)),
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    height: 68,
                    child: Row(
                      children: [
                        for (var index = 0; index < items.length; index++)
                          Expanded(
                            child: _NavigationButton(
                              item: items[index],
                              selected: selectedIndex == index,
                              onTap: () => onSelected(index),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AnimatedNavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        selected: selected,
        button: true,
        label: item.label,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          overlayColor: WidgetStatePropertyAll(
            AppColors.primary.withValues(alpha: .08),
          ),
          child: Center(
            child: AnimatedContainer(
              duration: AnimatedBottomNavigation._duration,
              curve: AnimatedBottomNavigation._curve,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: .11)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.large),
              ),
              child: AnimatedScale(
                duration: AnimatedBottomNavigation._duration,
                curve: AnimatedBottomNavigation._curve,
                scale: selected ? 1.08 : 1,
                child: Icon(
                  item.icon,
                  size: 25,
                  color: selected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      );
