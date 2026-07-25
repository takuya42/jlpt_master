import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../learning/presentation/providers/learning_providers.dart';

const _favoriteVocabularyKey = 'favoriteVocabulary';
const _favoriteGrammarKey = 'favoriteGrammar';

/// Owns the persisted vocabulary favorites and updates the UI optimistically.
class FavoriteVocabularyProvider extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final uid = ref.watch(activeUserIdProvider);
    if (uid == null) return <String>{};
    final ids = await ref
        .watch(userLearningRepositoryProvider)
        .watchFavoriteIds(uid, 'vocabulary')
        .first;
    await _save(_userKey(uid, _favoriteVocabularyKey), ids);
    return ids;
  }

  bool isFavorite(String id) => state.asData?.value.contains(id) ?? false;

  Future<void> add(String id) => _set(id, true);
  Future<void> remove(String id) => _set(id, false);
  Future<void> toggle(String id) => _set(id, !isFavorite(id));

  Future<void> _set(String id, bool favorite) async {
    final uid = ref.read(activeUserIdProvider);
    if (uid == null) return;
    final updated = {...state.asData?.value ?? await future};
    if (favorite) {
      updated.add(id);
    } else {
      updated.remove(id);
    }
    state = AsyncData(updated);
    await _save(_userKey(uid, _favoriteVocabularyKey), updated);
    await ref.read(userLearningRepositoryProvider).setFavorite(
          type: 'vocabulary',
          itemId: id,
          isFavorite: favorite,
        );
  }
}

/// Owns the persisted grammar favorites and updates the UI optimistically.
class FavoriteGrammarProvider extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final uid = ref.watch(activeUserIdProvider);
    if (uid == null) return <String>{};
    final ids = await ref
        .watch(userLearningRepositoryProvider)
        .watchFavoriteIds(uid, 'grammar')
        .first;
    await _save(_userKey(uid, _favoriteGrammarKey), ids);
    return ids;
  }

  bool isFavorite(String id) => state.asData?.value.contains(id) ?? false;

  Future<void> add(String id) => _set(id, true);
  Future<void> remove(String id) => _set(id, false);
  Future<void> toggle(String id) => _set(id, !isFavorite(id));

  Future<void> _set(String id, bool favorite) async {
    final uid = ref.read(activeUserIdProvider);
    if (uid == null) return;
    final updated = {...state.asData?.value ?? await future};
    if (favorite) {
      updated.add(id);
    } else {
      updated.remove(id);
    }
    state = AsyncData(updated);
    await _save(_userKey(uid, _favoriteGrammarKey), updated);
    await ref.read(userLearningRepositoryProvider).setFavorite(
          type: 'grammar',
          itemId: id,
          isFavorite: favorite,
        );
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

Future<void> _save(String key, Set<String> ids) async {
  final preferences = await SharedPreferences.getInstance();
  final sortedIds = ids.toList()..sort();
  await preferences.setStringList(key, sortedIds);
}

String _userKey(String uid, String key) => 'user.$uid.$key';

/// Removes keys written by versions which stored user data without a uid.
Future<void> clearLegacyFavoriteCache() async {
  final preferences = await SharedPreferences.getInstance();
  await preferences.remove(_favoriteVocabularyKey);
  await preferences.remove(_favoriteGrammarKey);
}

Future<void> clearUserFavoriteCache(String uid) async {
  final preferences = await SharedPreferences.getInstance();
  await preferences.remove(_userKey(uid, _favoriteVocabularyKey));
  await preferences.remove(_userKey(uid, _favoriteGrammarKey));
  await clearLegacyFavoriteCache();
}
