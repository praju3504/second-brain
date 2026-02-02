import 'package:drift/drift.dart';
import 'package:second_brain/core/constants/database_constants.dart';

@DataClassName('EntityData')
class Entities extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get title => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
  TextColumn get parentId => text().nullable()();
  TextColumn get workspaceId => text().withDefault(const Constant('default'))();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  
  @override
  Set<Column> get primaryKey => {id};
  
  @override
  String get tableName => DatabaseConstants.entitiesTable;
}
