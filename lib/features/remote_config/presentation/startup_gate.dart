import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../remote_config_repository.dart';

enum StartupDestination { app, maintenance, forceUpdate }

Future<StartupDestination> resolveStartupDestination(
  RemoteConfigRepository repository,
) async {
  if (repository.maintenanceMode) return StartupDestination.maintenance;

  final packageInfo = await PackageInfo.fromPlatform();
  if (isNewerVersion(repository.minimumVersion, packageInfo.version)) {
    return StartupDestination.forceUpdate;
  }
  return StartupDestination.app;
}

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

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('現在メンテナンス中です')),
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
