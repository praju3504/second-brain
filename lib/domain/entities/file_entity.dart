import 'package:equatable/equatable.dart';

class FileEntity extends Equatable {
  final String id;
  final String title;
  final String mimeType;
  final int fileSize;
  final String localPath;
  final String? thumbnailPath;
  final int createdAt;
  final int updatedAt;
  
  const FileEntity({
    required this.id,
    required this.title,
    required this.mimeType,
    required this.fileSize,
    required this.localPath,
    this.thumbnailPath,
    required this.createdAt,
    required this.updatedAt,
  });
  
  FileEntity copyWith({
    String? id,
    String? title,
    String? mimeType,
    int? fileSize,
    String? localPath,
    String? thumbnailPath,
    int? createdAt,
    int? updatedAt,
  }) {
    return FileEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      localPath: localPath ?? this.localPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  List<Object?> get props => [
    id, title, mimeType, fileSize, localPath, thumbnailPath, createdAt, updatedAt
  ];
}
