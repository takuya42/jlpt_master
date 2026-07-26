import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';

@immutable
class HeroIconData {
  const HeroIconData({required this.tag, required this.icon});

  final String tag;
  final IconData icon;
}

class HeroAppBarIcon extends StatelessWidget {
  const HeroAppBarIcon({super.key, required this.data});

  final HeroIconData data;

  @override
  Widget build(BuildContext context) => Hero(
        tag: data.tag,
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: SizedBox.square(
            dimension: 44,
            child: Icon(data.icon, color: AppColors.textSecondary),
          ),
        ),
      );
}
