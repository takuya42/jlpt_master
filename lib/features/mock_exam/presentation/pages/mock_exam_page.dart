import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/coming_soon_page.dart';

class MockExamPage extends StatelessWidget {
  const MockExamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonPage(
      title: 'Mock Exam',
      icon: Icons.quiz_outlined,
    );
  }
}
