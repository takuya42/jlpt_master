import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/vocabulary_repository.dart';
import '../../domain/vocabulary_word.dart';

const jlptLevels = ['N5', 'N4', 'N3', 'N2', 'N1'];

final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  return const BundledVocabularyRepository();
});

final vocabularyWordsProvider = FutureProvider<List<VocabularyWord>>((ref) async {
  return ref.watch(vocabularyRepositoryProvider).fetchWords();
});

final vocabularyWordProvider = FutureProvider.family<VocabularyWord?, String>((ref, id) async {
  final word = await ref.watch(vocabularyRepositoryProvider).fetchWordById(id);
  final favoriteIds = ref.watch(favoriteVocabularyIdsProvider).valueOrNull ?? const <String>{};

  if (word == null) return null;

  return word.copyWith(isFavorite: favoriteIds.contains(word.id));
});

final vocabularySearchQueryProvider = NotifierProvider<VocabularySearchQueryNotifier, String>(
  VocabularySearchQueryNotifier.new,
);

class VocabularySearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

final selectedJlptLevelProvider = NotifierProvider<SelectedJlptLevelNotifier, String>(
  SelectedJlptLevelNotifier.new,
);

class SelectedJlptLevelNotifier extends Notifier<String> {
  @override
  String build() => 'N5';

  void selectLevel(String level) {
    if (jlptLevels.contains(level)) state = level;
  }
}

final favoriteVocabularyIdsProvider = StreamProvider<Set<String>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(const <String>{});

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('favorites')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
});

final filteredVocabularyWordsProvider = Provider<AsyncValue<List<VocabularyWord>>>((ref) {
  final selectedLevel = ref.watch(selectedJlptLevelProvider);
  final query = ref.watch(vocabularySearchQueryProvider).trim().toLowerCase();
  final favoriteIds = ref.watch(favoriteVocabularyIdsProvider).valueOrNull ?? const <String>{};
  final words = ref.watch(vocabularyWordsProvider);

  return words.whenData((items) {
    return items
        .where((word) => word.jlptLevel == selectedLevel)
        .where((word) {
          if (query.isEmpty) return true;
          return word.word.toLowerCase().contains(query) ||
              word.reading.toLowerCase().contains(query) ||
              word.meaning.toLowerCase().contains(query) ||
              word.partOfSpeech.toLowerCase().contains(query);
        })
        .map((word) => word.copyWith(isFavorite: favoriteIds.contains(word.id)))
        .toList(growable: false);
  });
});

Future<void> toggleFavorite(WidgetRef ref, VocabularyWord word) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final firestore = FirebaseFirestore.instance;
  final favoriteRef = firestore.collection('users').doc(user.uid).collection('favorites').doc(word.id);
  final userRef = firestore.collection('users').doc(user.uid);
  final snapshot = await favoriteRef.get();

  if (snapshot.exists) {
    await favoriteRef.delete();
    await userRef.set({
      'statistics': {'favoriteCount': FieldValue.increment(-1)},
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  } else {
    await favoriteRef.set({
      'word': word.word,
      'reading': word.reading,
      'meaning': word.meaning,
      'jlptLevel': word.jlptLevel,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await userRef.set({
      'statistics': {'favoriteCount': FieldValue.increment(1)},
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
