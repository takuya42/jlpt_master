import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({super.key, this.title, this.actions = const []});

  final String? title;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) => AppBar(
        toolbarHeight: preferredSize.height,
        title: title == null ? null : Text(title!, style: Theme.of(context).textTheme.titleLarge),
        actions: actions,
      );
}
