import 'package:flutter/material.dart';

/// The shared action button used to open the app's memo editor.
class MemoButton extends StatelessWidget {
  const MemoButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      child: const Center(child: Text('Memo')),
    );
  }
}
