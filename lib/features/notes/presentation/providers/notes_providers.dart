import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/notes_repository.dart';
import '../../domain/note.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) => NotesRepository());

final notesProvider = StreamProvider<List<Note>>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(notesRepositoryProvider).watchNotes();
});
