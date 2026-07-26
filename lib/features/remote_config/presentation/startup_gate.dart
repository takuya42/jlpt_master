import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_radius.dart';
import '../../../shared/extensions/build_context_extensions.dart';
import '../remote_config_repository.dart';

bool isNewerVersion(String requiredVersion, String currentVersion) {
  List<int> parts(String value) => value
      .split(RegExp(r'[^0-9]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => int.tryParse(part) ?? 0)
      .toList();

  final required = parts(requiredVersion);
  final current = parts(currentVersion);
  final length = required.length > current.length
      ? required.length
      : current.length;
  for (var index = 0; index < length; index++) {
    final requiredPart = index < required.length ? required[index] : 0;
    final currentPart = index < current.length ? current[index] : 0;
    if (requiredPart != currentPart) return requiredPart > currentPart;
  }
  return false;
}

class StartupGate extends StatefulWidget {
  const StartupGate({required this.repository, required this.child, super.key});

  final RemoteConfigRepository repository;
  final Widget child;

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  late final Future<bool> _requiresUpdate = _checkForUpdate();

  Future<bool> _checkForUpdate() async {
    try {
      await widget.repository.initialize();
      await widget.repository.fetchAndActivate();
      final packageInfo = await PackageInfo.fromPlatform();
      return isNewerVersion(
        widget.repository.minimumVersion,
        packageInfo.version,
      );
    } on Exception catch (error) {
      debugPrint('Remote Config startup check failed: $error');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: _requiresUpdate,
    builder: (context, snapshot) {
      if (snapshot.data ?? false) return const ForceUpdatePage();
      if (snapshot.connectionState != ConnectionState.done) {
        return const _SplashPage();
      }
      return widget.child;
    },
  );
}

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.scale(scale: value, child: child),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B7FFF),
                    borderRadius: BorderRadius.circular(AppRadius.extraLarge),
                  ),
                  child: const Icon(
                    Icons.spa_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 22),
                Text('はりきゅうラボ', style: context.textStyles.headlineMedium),
              ],
            ),
          ),
        ),
      );
}

class ForceUpdatePage extends StatelessWidget {
  const ForceUpdatePage({super.key});

  static final Uri _appStoreUrl = Uri.parse(
    'itms-apps://itunes.apple.com/search?term=JLPT%20Master&entity=software',
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FilledButton(
            onPressed: () => launchUrl(
              _appStoreUrl,
              mode: LaunchMode.externalApplication,
            ),
            child: const Text('更新'),
          ),
        ),
      ),
    ),
  );
}
