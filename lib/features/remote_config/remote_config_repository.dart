import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final remoteConfigRepositoryProvider = Provider<RemoteConfigRepository>((ref) {
  return RemoteConfigRepository();
});

class RemoteConfigRepository {
  RemoteConfigRepository({FirebaseRemoteConfig? remoteConfig})
    : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  static const String defaultMinimumVersion = '1.0.0';

  final FirebaseRemoteConfig _remoteConfig;

  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 30),
        minimumFetchInterval: kDebugMode
            ? Duration.zero
            : const Duration(hours: 1),
      ),
    );
    await _remoteConfig.setDefaults({
      'minimum_version': defaultMinimumVersion,
    });
  }

  Future<bool> fetchAndActivate() => _remoteConfig.fetchAndActivate();

  String get minimumVersion => _remoteConfig.getString('minimum_version');
}
