import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/navigation/app_route.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static final _items = [
    _NavigationItem(AppRoute.home, Icons.home_outlined, Icons.home),
    _NavigationItem(AppRoute.login, Icons.person_outline, Icons.person),
    _NavigationItem(AppRoute.vocabulary, Icons.menu_book_outlined, Icons.menu_book),
    _NavigationItem(AppRoute.grammar, Icons.subject_outlined, Icons.subject),
    _NavigationItem(AppRoute.kanji, Icons.translate_outlined, Icons.translate),
    _NavigationItem(AppRoute.mockExam, Icons.quiz_outlined, Icons.quiz),
    _NavigationItem(AppRoute.statistics, Icons.bar_chart_outlined, Icons.bar_chart),
    _NavigationItem(AppRoute.settings, Icons.settings_outlined, Icons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => context.go(_items[index].route.path),
        destinations: [
          for (final item in _items)
            NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: item.route.label,
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

class _NavigationItem {
  const _NavigationItem(this.route, this.icon, this.selectedIcon);

  final AppRoute route;
  final IconData icon;
  final IconData selectedIcon;
}
