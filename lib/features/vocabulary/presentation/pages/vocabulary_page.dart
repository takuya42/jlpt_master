import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/coming_soon_page.dart';

class VocabularyPage extends StatelessWidget {
  const VocabularyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonPage(
      title: 'Vocabulary',
      icon: Icons.menu_book_outlined,
    );
  }
}
