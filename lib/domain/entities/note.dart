import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String title;
  final String contentJson;
  final String contentPlain;
  final int createdAt;
  final int updatedAt;
  final String? parentId;
  
  const Note({
    required this.id,
    required this.title,
    required this.contentJson,
    required this.contentPlain,
    required this.createdAt,
    required this.updatedAt,
    this.parentId,
  });
  
  Note copyWith({
    String? id,
    String? title,
    String? contentJson,
    String? contentPlain,
    int? createdAt,
    int? updatedAt,
    String? parentId,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      contentJson: contentJson ?? this.contentJson,
      contentPlain: contentPlain ?? this.contentPlain,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parentId: parentId ?? this.parentId,
    );
  }
  
  @override
  List<Object?> get props => [id, title, contentJson, contentPlain, createdAt, updatedAt, parentId];
}
