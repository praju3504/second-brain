import 'package:drift/drift.dart';
import 'package:second_brain/core/constants/database_constants.dart';

@DataClassName('LinkData')
class Links extends Table {
  TextColumn get id => text()();
  TextColumn get sourceId => text()();
  TextColumn get targetId => text()();
  TextColumn get linkType => text()();
  TextColumn get linkText => text().nullable()();
  TextColumn get context => text().nullable()();
  IntColumn get position => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  
  @override
  Set<Column> get primaryKey => {id};
  
  @override
  String get tableName => DatabaseConstants.linksTable;
}
