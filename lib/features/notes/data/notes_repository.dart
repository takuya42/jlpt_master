import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/note.dart';

class NotesRepository {
  NotesRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>>? get _notesRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('notes');
  }

  Stream<List<Note>> watchNotes() {
    final ref = _notesRef;
    if (ref == null) return Stream.value(const <Note>[]);
    return ref.orderBy('updatedAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map(Note.fromSnapshot).toList(growable: false),
        );
  }

  Future<void> saveNote(Note note) async {
    final ref = _notesRef;
    if (ref == null) return;
    final doc = note.id.isEmpty ? ref.doc() : ref.doc(note.id);
    await doc.set({
      'id': doc.id,
      'type': note.type.value,
      'itemId': note.itemId.trim().isEmpty ? doc.id : note.itemId.trim(),
      'title': note.title.trim(),
      'jlptLevel': note.jlptLevel,
      'memo': note.memo.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteNote(String noteId) async {
    final ref = _notesRef;
    if (ref == null || noteId.isEmpty) return;
    await ref.doc(noteId).delete();
  }
}
