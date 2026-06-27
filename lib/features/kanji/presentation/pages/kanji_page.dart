import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/coming_soon_page.dart';

class KanjiPage extends StatelessWidget {
  const KanjiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonPage(
      title: 'Kanji',
      icon: Icons.translate_outlined,
    );
  }
}
