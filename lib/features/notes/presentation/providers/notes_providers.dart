import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/notes_repository.dart';
import '../../domain/note.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) => NotesRepository());

final noteProvider = StreamProvider<Note>((ref) {
  return ref.watch(notesRepositoryProvider).watchNote();
});
