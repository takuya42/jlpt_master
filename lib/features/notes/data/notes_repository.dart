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

  Stream<Note> watchNote({String noteId = Note.defaultNoteId}) {
    final ref = _notesRef;
    if (ref == null) return Stream.value(Note.empty(id: noteId));
    return ref.doc(noteId).snapshots().map((snapshot) {
      if (!snapshot.exists) return Note.empty(id: noteId);
      return Note.fromSnapshot(snapshot);
    });
  }

  Future<void> saveMemo(String memo, {String noteId = Note.defaultNoteId}) async {
    final ref = _notesRef;
    if (ref == null) return;
    final doc = ref.doc(noteId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(doc);
      transaction.set(doc, {
        'id': doc.id,
        'memo': memo,
        if (!snapshot.exists) 'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }
}
