import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/navigation/app_route.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static final _items = [
    _NavigationItem(AppRoute.home, Icons.home_outlined, Icons.home, 'Home\nホーム'),
    _NavigationItem(AppRoute.vocabulary, Icons.menu_book_outlined, Icons.menu_book, 'Vocabulary\n単語'),
    _NavigationItem(AppRoute.grammar, Icons.subject_outlined, Icons.subject, 'Grammar\n文法'),
    _NavigationItem(AppRoute.statistics, Icons.bar_chart_outlined, Icons.bar_chart, 'Statistics\n学習記録'),
    _NavigationItem(AppRoute.settings, Icons.settings_outlined, Icons.settings, 'Settings\n設定'),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        height: 82,
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => context.go(_items[index].route.path),
        destinations: [
          for (final item in _items)
            NavigationDestination(
              icon: _NavigationDestinationContent(icon: item.icon, label: item.label),
              selectedIcon: _NavigationDestinationContent(icon: item.selectedIcon, label: item.label),
              label: '',
            ),
        ],
      ),
    );
  }

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = _items.indexWhere((item) {
      if (item.route == AppRoute.home) {
        return item.route.path == location;
      }
      return location.startsWith(item.route.path);
    });
    return index < 0 ? 0 : index;
  }
}

class _NavigationDestinationContent extends StatelessWidget {
  const _NavigationDestinationContent({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final labels = label.split('\n');

    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(height: 3),
          for (final text in labels)
            Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: iconTheme.color,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                height: 1.08,
              ),
            ),
        ],
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem(this.route, this.icon, this.selectedIcon, this.label);

  final AppRoute route;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
