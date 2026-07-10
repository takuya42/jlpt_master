import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/theme_mode_repository.dart';

final themeModeRepositoryProvider = Provider<ThemeModeRepository>((ref) => ThemeModeRepository());

final themeModeControllerProvider = AsyncNotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

class ThemeModeController extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() {
    return ref.watch(themeModeRepositoryProvider).loadThemeMode();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = AsyncData(themeMode);
    await ref.read(themeModeRepositoryProvider).saveThemeMode(themeMode);
  }
}
