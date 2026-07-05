import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/feature_page_header.dart';

class KanjiPage extends StatelessWidget {
  const KanjiPage({super.key});

  static const _kanji = [
    _KanjiItem('日', 'にち・ひ', 'day; sun', '日本・今日'),
    _KanjiItem('学', 'がく・まなぶ', 'study', '学校・学生'),
    _KanjiItem('語', 'ご・かたる', 'language', '日本語・単語'),
    _KanjiItem('読', 'どく・よむ', 'read', '読書・読む'),
    _KanjiItem('聞', 'ぶん・きく', 'listen; ask', '新聞・聞く'),
    _KanjiItem('試', 'し・ためす', 'test; try', '試験・試す'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 900 ? 3 : width >= 600 ? 2 : 1;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: CustomScrollView(
              key: const PageStorageKey('kanji-card-grid'),
              slivers: [
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
                  sliver: SliverToBoxAdapter(
                    child: FeaturePageHeader(
                      title: 'Kanji',
                      subtitle: '読み・意味・熟語をまとめて確認できます。',
                      icon: Icons.translate_outlined,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  sliver: SliverGrid.builder(
                    itemCount: _kanji.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: columns == 1 ? 2.4 : 1.45,
                    ),
                    itemBuilder: (context, index) {
                      return _KanjiCard(item: _kanji[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KanjiCard extends StatelessWidget {
  const _KanjiCard({required this.item});

  final _KanjiItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Text(
              item.character,
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.reading,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.meaning,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(item.examples, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KanjiItem {
  const _KanjiItem(this.character, this.reading, this.meaning, this.examples);

  final String character;
  final String reading;
  final String meaning;
  final String examples;
}
