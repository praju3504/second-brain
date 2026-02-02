import 'package:second_brain/data/database/app_database.dart';
import 'package:second_brain/domain/entities/file_entity.dart';
import 'package:second_brain/domain/repositories/file_repository.dart';

class FileRepositoryImpl implements FileRepository {
  final AppDatabase _database;
  
  FileRepositoryImpl(this._database);
  
  @override
  Future<List<FileEntity>> getAllFiles() {
    return _database.fileDao.getAllFiles();
  }
  
  @override
  Future<FileEntity?> getFileById(String id) {
    return _database.fileDao.getFileById(id);
  }
  
  @override
  Future<void> insertFile(FileEntity file) {
    return _database.fileDao.insertFile(file);
  }
  
  @override
  Future<void> deleteFile(String id) {
    return _database.fileDao.deleteFile(id);
  }
}
