import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class Note {
  const Note({
    required this.id,
    required this.type,
    required this.itemId,
    required this.title,
    required this.jlptLevel,
    required this.memo,
    required this.updatedAt,
  });

  factory Note.empty({NoteType type = NoteType.vocabulary}) => Note(
        id: '',
        type: type,
        itemId: '',
        title: '',
        jlptLevel: 'N5',
        memo: '',
        updatedAt: DateTime.now(),
      );

  factory Note.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Note(
      id: snapshot.id,
      type: NoteTypeX.fromValue(data['type'] as String?),
      itemId: data['itemId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      jlptLevel: data['jlptLevel'] as String? ?? 'N5',
      memo: data['memo'] as String? ?? '',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final String id;
  final NoteType type;
  final String itemId;
  final String title;
  final String jlptLevel;
  final String memo;
  final DateTime updatedAt;

  Note copyWith({
    String? id,
    NoteType? type,
    String? itemId,
    String? title,
    String? jlptLevel,
    String? memo,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      type: type ?? this.type,
      itemId: itemId ?? this.itemId,
      title: title ?? this.title,
      jlptLevel: jlptLevel ?? this.jlptLevel,
      memo: memo ?? this.memo,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum NoteType { vocabulary, grammar }

extension NoteTypeX on NoteType {
  String get value => switch (this) {
        NoteType.vocabulary => 'vocabulary',
        NoteType.grammar => 'grammar',
      };

  String get label => switch (this) {
        NoteType.vocabulary => 'Vocabulary',
        NoteType.grammar => 'Grammar',
      };

  static NoteType fromValue(String? value) => switch (value) {
        'grammar' => NoteType.grammar,
        _ => NoteType.vocabulary,
      };
}