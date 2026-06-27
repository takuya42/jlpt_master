import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/coming_soon_page.dart';

class GrammarPage extends StatelessWidget {
  const GrammarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonPage(
      title: 'Grammar',
      icon: Icons.subject_outlined,
    );
  }
}
