import 'package:shared_preferences/shared_preferences.dart';

abstract interface class AccountDeletionService {
  Future<void> deleteAccount();
}

/// Permanently removes the remote account before erasing this installation's
/// local data. Remote deletion is intentionally first so a network/auth error
/// does not make the UI look like deletion succeeded while the account exists.
class FirebaseAccountDeletionService implements AccountDeletionService {
  FirebaseAccountDeletionService({
    required Future<void> Function() deleteRemoteAccount,
    SharedPreferencesAsync? preferences,
  }) : _deleteRemoteAccount = deleteRemoteAccount,
       _preferences = preferences ?? SharedPreferencesAsync();

  final Future<void> Function() _deleteRemoteAccount;
  final SharedPreferencesAsync _preferences;

  @override
  Future<void> deleteAccount() async {
    await _deleteRemoteAccount();
    await _preferences.clear();
  }
}
