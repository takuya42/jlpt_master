import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _favoriteVocabularyKey = 'favoriteVocabulary';
const _favoriteGrammarKey = 'favoriteGrammar';

/// Owns the persisted vocabulary favorites and updates the UI optimistically.
class FavoriteVocabularyProvider extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() => _load(_favoriteVocabularyKey);

  bool isFavorite(String id) => state.asData?.value.contains(id) ?? false;

  Future<void> add(String id) => _set(id, true);
  Future<void> remove(String id) => _set(id, false);
  Future<void> toggle(String id) => _set(id, !isFavorite(id));

  Future<void> _set(String id, bool favorite) async {
    final updated = {...state.asData?.value ?? await future};
    if (favorite) {
      updated.add(id);
    } else {
      updated.remove(id);
    }
    state = AsyncData(updated);
    await _save(_favoriteVocabularyKey, updated);
  }
}

/// Owns the persisted grammar favorites and updates the UI optimistically.
class FavoriteGrammarProvider extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() => _load(_favoriteGrammarKey);

  bool isFavorite(String id) => state.asData?.value.contains(id) ?? false;

  Future<void> add(String id) => _set(id, true);
  Future<void> remove(String id) => _set(id, false);
  Future<void> toggle(String id) => _set(id, !isFavorite(id));

  Future<void> _set(String id, bool favorite) async {
    final updated = {...state.asData?.value ?? await future};
    if (favorite) {
      updated.add(id);
    } else {
      updated.remove(id);
    }
    state = AsyncData(updated);
    await _save(_favoriteGrammarKey, updated);
  }
}

final favoriteVocabularyProvider =
    AsyncNotifierProvider<FavoriteVocabularyProvider, Set<String>>(
  FavoriteVocabularyProvider.new,
);

final favoriteGrammarProvider =
    AsyncNotifierProvider<FavoriteGrammarProvider, Set<String>>(
  FavoriteGrammarProvider.new,
);

Future<Set<String>> _load(String key) async {
  final preferences = await SharedPreferences.getInstance();
  return preferences.getStringList(key)?.toSet() ?? <String>{};
}

Future<void> _save(String key, Set<String> ids) async {
  final preferences = await SharedPreferences.getInstance();
  final sortedIds = ids.toList()..sort();
  await preferences.setStringList(key, sortedIds);
}
