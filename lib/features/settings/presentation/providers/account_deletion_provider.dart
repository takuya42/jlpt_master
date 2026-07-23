import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/account_deletion_service.dart';

final accountDeletionServiceProvider = Provider<AccountDeletionService>((ref) {
  return FirebaseAccountDeletionService(
    deleteRemoteAccount: ref
        .watch(authRepositoryProvider)
        .deleteCurrentUserAccount,
  );
});
