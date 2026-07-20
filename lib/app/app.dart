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
    RemoteConfigRepository? repository;
    try {
      repository = ref.read(remoteConfigRepositoryProvider);
    } catch (_) {
      // Widget tests and unsupported platforms can run without Firebase. The
      // normal app remains available in that case, as it does after fetch errors.
    }

    if (repository == null) {
      return MaterialApp.router(
        title: 'JLPT Master',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        routerConfig: router,
      );
    }

    return MaterialApp(
      title: 'JLPT Master',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: FutureBuilder<StartupDestination>(
        future: resolveStartupDestination(repository),
        builder: (context, snapshot) {
          final destination = snapshot.data;
          if (destination == StartupDestination.maintenance) {
            return const MaintenancePage();
          }
          if (destination == StartupDestination.forceUpdate) {
            return const ForceUpdatePage();
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
