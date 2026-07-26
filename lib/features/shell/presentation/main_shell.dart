import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/navigation/app_route.dart';
import '../../../shared/presentation/widgets/animated_bottom_navigation.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  static const _routes = [AppRoute.home, AppRoute.vocabulary, AppRoute.grammar, AppRoute.notes, AppRoute.settings];
  static const _items = [
    AnimatedNavigationItem(icon: Icons.home_rounded, label: 'ホーム'),
    AnimatedNavigationItem(icon: Icons.menu_book_rounded, label: '問題'),
    AnimatedNavigationItem(icon: Icons.school_rounded, label: '学習'),
    AnimatedNavigationItem(icon: Icons.edit_note_rounded, label: 'メモ'),
    AnimatedNavigationItem(icon: Icons.person_rounded, label: '設定'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = _routes.indexWhere((route) => route == AppRoute.home ? location == '/' : location.startsWith(route.path));
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: AnimatedBottomNavigation(
        items: _items,
        selectedIndex: index < 0 ? 0 : index,
        onSelected: (value) => context.go(_routes[value].path),
      ),
    );
  }
}
