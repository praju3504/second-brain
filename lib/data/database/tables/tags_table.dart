import 'package:drift/drift.dart';
import 'package:second_brain/core/constants/database_constants.dart';

@DataClassName('TagData')
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get color => text()();
  TextColumn get parentId => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
  
  @override
  String get tableName => DatabaseConstants.tagsTable;
}
