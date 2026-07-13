import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class Note {
  const Note({
    required this.id,
    required this.memo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.empty({String id = defaultNoteId}) => Note(
        id: id,
        memo: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  factory Note.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return Note(
      id: data['id'] as String? ?? snapshot.id,
      memo: data['memo'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static const defaultNoteId = 'main';

  final String id;
  final String memo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note copyWith({
    String? id,
    String? memo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
