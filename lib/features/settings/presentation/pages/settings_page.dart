import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/coming_soon_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonPage(
      title: 'Settings',
      icon: Icons.settings_outlined,
    );
  }
}
