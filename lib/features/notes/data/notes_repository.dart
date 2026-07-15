import 'package:shared_preferences/shared_preferences.dart';

import '../domain/note.dart';

class NotesRepository {
  NotesRepository({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _memoKey = 'notes.memo';

  final SharedPreferencesAsync _preferences;

  Stream<Note> watchNote({String noteId = Note.defaultNoteId}) async* {
    final memo = await _preferences.getString(_memoKey) ?? '';
    yield Note.empty(id: noteId).copyWith(memo: memo);
  }

  Future<void> saveMemo(String memo, {String noteId = Note.defaultNoteId}) async {
    await _preferences.setString(_memoKey, memo);
  }
}
