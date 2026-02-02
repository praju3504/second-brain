import 'package:drift/drift.dart';
import 'package:second_brain/data/database/app_database.dart';
import 'package:second_brain/data/database/tables/entities_table.dart';
import 'package:second_brain/data/database/tables/files_table.dart';
import 'package:second_brain/domain/entities/file_entity.dart';
import 'package:second_brain/domain/enums/entity_type.dart';

part 'file_dao.g.dart';

@DriftAccessor(tables: [Entities, Files])
class FileDao extends DatabaseAccessor<AppDatabase> with _$FileDaoMixin {
  FileDao(AppDatabase db) : super(db);
  
  Future<List<FileEntity>> getAllFiles() async {
    final query = select(entities).join([
      innerJoin(files, files.entityId.equalsExp(entities.id)),
    ])..where(entities.entityType.equals(EntityType.file.name) & entities.deletedAt.isNull())
      ..orderBy([OrderingTerm.desc(entities.createdAt)]);
    
    final results = await query.get();
    return results.map((row) => _mapToFile(row)).toList();
  }
  
  Future<FileEntity?> getFileById(String id) async {
    final query = select(entities).join([
      innerJoin(files, files.entityId.equalsExp(entities.id)),
    ])..where(entities.id.equals(id) & entities.deletedAt.isNull());
    
    final results = await query.get();
    if (results.isEmpty) return null;
    return _mapToFile(results.first);
  }
  
  Future<void> insertFile(FileEntity file) async {
    await into(entities).insert(
      EntitiesCompanion.insert(
        id: file.id,
        entityType: EntityType.file.name,
        title: file.title,
        createdAt: file.createdAt,
        updatedAt: file.updatedAt,
      ),
    );
    
    await into(files).insert(
      FilesCompanion.insert(
        entityId: file.id,
        mimeType: file.mimeType,
        fileSize: file.fileSize,
        localPath: file.localPath,
        thumbnailPath: Value(file.thumbnailPath),
      ),
    );
  }
  
  Future<void> deleteFile(String id) async {
    await (update(entities)..where((t) => t.id.equals(id))).write(
      EntitiesCompanion(
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      ),
    );
  }
  
  FileEntity _mapToFile(TypedResult row) {
    final entity = row.readTable(entities);
    final fileData = row.readTable(files);
    
    return FileEntity(
      id: entity.id,
      title: entity.title,
      mimeType: fileData.mimeType,
      fileSize: fileData.fileSize,
      localPath: fileData.localPath,
      thumbnailPath: fileData.thumbnailPath,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
