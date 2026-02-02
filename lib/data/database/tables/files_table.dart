import 'package:drift/drift.dart';
import 'package:second_brain/core/constants/database_constants.dart';
import 'package:second_brain/data/database/tables/entities_table.dart';

@DataClassName('FileData')
class Files extends Table {
  TextColumn get entityId => text().references(Entities, #id, onDelete: KeyAction.cascade)();
  TextColumn get mimeType => text()();
  IntColumn get fileSize => integer()();
  TextColumn get localPath => text()();
  TextColumn get cloudUrl => text().nullable()();
  TextColumn get checksum => text().nullable()();
  TextColumn get thumbnailPath => text().nullable()();
  TextColumn get ocrText => text().nullable()();
  TextColumn get storageTier => text().withDefault(const Constant('local'))();
  
  @override
  Set<Column> get primaryKey => {entityId};
  
  @override
  String get tableName => DatabaseConstants.filesTable;
}
