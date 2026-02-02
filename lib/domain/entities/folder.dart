import 'package:equatable/equatable.dart';

class Folder extends Equatable {
  final String id;
  final String title;
  final String? parentId;
  final int createdAt;
  final int updatedAt;
  
  const Folder({
    required this.id,
    required this.title,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
  });
  
  Folder copyWith({
    String? id,
    String? title,
    String? parentId,
    int? createdAt,
    int? updatedAt,
  }) {
    return Folder(
      id: id ?? this.id,
      title: title ?? this.title,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  List<Object?> get props => [id, title, parentId, createdAt, updatedAt];
}
