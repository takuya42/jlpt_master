import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('JLPT Master')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Start learning Japanese', style: textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Build your JLPT skills step by step from N5 to N1.',
                    style: textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Today\'s focus', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          const _FocusTile(
            icon: Icons.menu_book_outlined,
            title: 'Vocabulary',
            subtitle: 'Learn essential words by JLPT level.',
          ),
          const _FocusTile(
            icon: Icons.subject_outlined,
            title: 'Grammar',
            subtitle: 'Review sentence patterns with examples.',
          ),
          const _FocusTile(
            icon: Icons.translate_outlined,
            title: 'Kanji',
            subtitle: 'Practice readings, meanings, and usage.',
          ),
        ],
      ),
    );
  }
}

class _FocusTile extends StatelessWidget {
  const _FocusTile({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
