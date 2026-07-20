import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/remote_config/presentation/startup_gate.dart';
import '../features/remote_config/remote_config_repository.dart';
import '../features/settings/presentation/providers/theme_mode_provider.dart';
import 'navigation/app_router.dart';
import 'theme/app_theme.dart';

class JlptMasterApp extends ConsumerWidget {
  const JlptMasterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeControllerProvider).asData?.value ?? ThemeMode.system;
    return MaterialApp(
      title: 'JLPT Master',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: StartupGate(
        repository: ref.read(remoteConfigRepositoryProvider),
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: router,
        ),
      ),
    );
  }
}
