import 'package:second_brain/domain/entities/file_entity.dart';

abstract class FileRepository {
  Future<List<FileEntity>> getAllFiles();
  Future<FileEntity?> getFileById(String id);
  Future<void> insertFile(FileEntity file);
  Future<void> deleteFile(String id);
}
