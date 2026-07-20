import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final remoteConfigRepositoryProvider = Provider<RemoteConfigRepository>((ref) {
  return RemoteConfigRepository();
});

class RemoteConfigRepository {
  RemoteConfigRepository({FirebaseRemoteConfig? remoteConfig})
    : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  static const Map<String, Object> defaults = {
    'minimum_version': '1.0.0',
    'maintenance_mode': false,
    'premium_enabled': true,
    'announcement_message': '',
    'review_enabled': true,
  };

  final FirebaseRemoteConfig _remoteConfig;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 30),
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : const Duration(hours: 1),
        ),
      );
      await _remoteConfig.setDefaults(defaults);
      await _remoteConfig.fetchAndActivate();
    } on Exception catch (error) {
      // Remote Config must never prevent the app from starting. Values already
      // activated (or the defaults above) remain available after a fetch error.
      debugPrint('Remote Config initialization failed: $error');
    }
  }

  String get minimumVersion => _remoteConfig.getString('minimum_version');
  bool get maintenanceMode => _remoteConfig.getBool('maintenance_mode');
  bool get premiumEnabled => _remoteConfig.getBool('premium_enabled');
  String get announcementMessage =>
      _remoteConfig.getString('announcement_message');
  bool get reviewEnabled => _remoteConfig.getBool('review_enabled');
}

final premiumEnabledProvider = Provider<bool>((ref) {
  try {
    return ref.watch(remoteConfigRepositoryProvider).premiumEnabled;
  } catch (_) {
    return RemoteConfigRepository.defaults['premium_enabled']! as bool;
  }
});

final announcementMessageProvider = Provider<String>((ref) {
  try {
    return ref.watch(remoteConfigRepositoryProvider).announcementMessage;
  } catch (_) {
    return RemoteConfigRepository.defaults['announcement_message']! as String;
  }
});

final reviewEnabledProvider = Provider<bool>((ref) {
  try {
    return ref.watch(remoteConfigRepositoryProvider).reviewEnabled;
  } catch (_) {
    return RemoteConfigRepository.defaults['review_enabled']! as bool;
  }
});
