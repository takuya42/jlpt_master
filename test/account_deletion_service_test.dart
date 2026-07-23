import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_master/features/settings/data/account_deletion_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('deletes the remote account before clearing all local data', () async {
    SharedPreferences.setMockInitialValues({
      'favoriteVocabulary': <String>['word-1'],
      'notes.memo': 'memo',
      'studyStats.totalStudySeconds': 120,
      'vocabulary.onboarding.seen': true,
    });
    final events = <String>[];
    final preferences = SharedPreferencesAsync();
    final service = FirebaseAccountDeletionService(
      deleteRemoteAccount: () async => events.add('remote'),
      preferences: preferences,
    );

    await service.deleteAccount();
    events.add('local');

    expect(events, ['remote', 'local']);
    expect(await preferences.getKeys(), isEmpty);
  });

  test('keeps local data when remote account deletion fails', () async {
    SharedPreferences.setMockInitialValues({'notes.memo': 'keep me'});
    final preferences = SharedPreferencesAsync();
    final service = FirebaseAccountDeletionService(
      deleteRemoteAccount: () => Future<void>.error(Exception('reauth required')),
      preferences: preferences,
    );

    await expectLater(service.deleteAccount(), throwsException);

    expect(await preferences.getString('notes.memo'), 'keep me');
  });
}
