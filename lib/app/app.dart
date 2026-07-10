import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/presentation/providers/theme_mode_provider.dart';
import 'navigation/app_router.dart';
import 'theme/app_theme.dart';

class JlptMasterApp extends ConsumerWidget {
  const JlptMasterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeControllerProvider).asData?.value ?? ThemeMode.system;

    return MaterialApp.router(
      title: 'JLPT Master',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
