import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/firebase/firebase_initializer.dart';
import 'features/remote_config/remote_config_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.initialize();
  final remoteConfigRepository = RemoteConfigRepository();
  await remoteConfigRepository.initialize();
  runApp(
    ProviderScope(
      overrides: [
        remoteConfigRepositoryProvider.overrideWithValue(
          remoteConfigRepository,
        ),
      ],
      child: const JlptMasterApp(),
    ),
  );
}
