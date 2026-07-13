import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/grammar_pattern.dart';
import '../providers/grammar_providers.dart';

class GrammarStudiedToggle extends ConsumerWidget {
  const GrammarStudiedToggle({super.key, required this.pattern});

  final GrammarPattern pattern;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isStudied = (ref.watch(studiedGrammarIdsProvider).asData?.value ?? <String>{}).contains(pattern.id);
    final color = Colors.green.shade700;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => toggleGrammarStudied(ref, pattern),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axis: Axis.horizontal,
              child: child,
            ),
          ),
          child: Row(
            key: ValueKey(isStudied),
            mainAxisSize: MainAxisSize.min,
            children: isStudied
                ? [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Studied',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ]
                : const [SizedBox.shrink()],
          ),
        ),
      ),
    );
  }
}
