import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_master/app/constants/app_urls.dart';
import 'package:jlpt_master/features/auth/presentation/providers/auth_providers.dart';
import 'package:jlpt_master/features/settings/presentation/pages/settings_page.dart';
import 'package:jlpt_master/features/settings/presentation/providers/theme_mode_provider.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  testWidgets('Terms of Service tap launches the configured URL externally', (
    tester,
  ) async {
    Uri? launchedUrl;
    LaunchMode? launchMode;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
          currentUserProvider.overrideWith((ref) => Stream.value(null)),
          themeModeControllerProvider.overrideWith(() => _ThemeModeController()),
        ],
        child: MaterialApp(
          home: SettingsPage(
            urlLauncher: (url, {mode = LaunchMode.platformDefault}) async {
              launchedUrl = url;
              launchMode = mode;
              return true;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final termsTile = find.text('Terms of Service');
    await tester.ensureVisible(termsTile);
    await tester.tap(termsTile);
    await tester.pump();

    expect(launchedUrl, Uri.parse(AppUrls.termsOfService));
    expect(launchMode, LaunchMode.externalApplication);
  });

  testWidgets('shows an error when launchUrl returns false', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
          currentUserProvider.overrideWith((ref) => Stream.value(null)),
          themeModeControllerProvider.overrideWith(() => _ThemeModeController()),
        ],
        child: MaterialApp(
          home: SettingsPage(
            urlLauncher: (url, {mode = LaunchMode.platformDefault}) async =>
                false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final termsTile = find.text('Terms of Service');
    await tester.ensureVisible(termsTile);
    await tester.tap(termsTile);
    await tester.pump();

    expect(find.text('Unable to open Terms of Service.'), findsOneWidget);
  });
}

class _ThemeModeController extends ThemeModeController {
  @override
  Future<ThemeMode> build() async => ThemeMode.system;
}
