import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_master/features/favorites/presentation/providers/favorite_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('signed-out favorites are always empty and cannot be mutated', () async {
    SharedPreferences.setMockInitialValues({
      'favoriteVocabulary': <String>['legacy-word'],
      'favoriteGrammar': <String>['legacy-grammar'],
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(await container.read(favoriteVocabularyProvider.future), isEmpty);
    expect(await container.read(favoriteGrammarProvider.future), isEmpty);

    await container.read(favoriteVocabularyProvider.notifier).toggle('word-1');
    await container.read(favoriteGrammarProvider.notifier).add('grammar-1');
    expect(container.read(favoriteVocabularyProvider).requireValue, isEmpty);
    expect(container.read(favoriteGrammarProvider).requireValue, isEmpty);
  });

  test('legacy non-user-scoped favorite caches are completely removed', () async {
    SharedPreferences.setMockInitialValues({
      'favoriteVocabulary': <String>['word-1'],
      'favoriteGrammar': <String>['grammar-1'],
    });

    await clearLegacyFavoriteCache();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.containsKey('favoriteVocabulary'), isFalse);
    expect(preferences.containsKey('favoriteGrammar'), isFalse);
  });
}
