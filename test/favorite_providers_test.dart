import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_master/features/favorites/presentation/providers/favorite_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('vocabulary favorites toggle immediately and survive provider reload',
      () async {
    SharedPreferences.setMockInitialValues({});
    var container = ProviderContainer();
    await container.read(favoriteVocabularyProvider.future);

    await container
        .read(favoriteVocabularyProvider.notifier)
        .toggle('word-1');
    expect(container.read(favoriteVocabularyProvider).requireValue,
        contains('word-1'));

    container.dispose();
    container = ProviderContainer();
    expect(await container.read(favoriteVocabularyProvider.future),
        contains('word-1'));
    container.dispose();
  });

  test('grammar favorites can be added and removed persistently', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(favoriteGrammarProvider.future);

    await container.read(favoriteGrammarProvider.notifier).add('grammar-1');
    expect(container.read(favoriteGrammarProvider.notifier)
        .isFavorite('grammar-1'), isTrue);
    await container
        .read(favoriteGrammarProvider.notifier)
        .remove('grammar-1');
    expect(container.read(favoriteGrammarProvider).requireValue, isEmpty);
  });
}
