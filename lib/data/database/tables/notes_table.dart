import 'package:drift/drift.dart';
import 'package:second_brain/core/constants/database_constants.dart';
import 'package:second_brain/data/database/tables/entities_table.dart';

@DataClassName('NoteData')
class Notes extends Table {
  TextColumn get entityId => text().references(Entities, #id, onDelete: KeyAction.cascade)();
  TextColumn get contentJson => text()();
  TextColumn get contentPlain => text()();
  TextColumn get contentHash => text()();
  
  @override
  Set<Column> get primaryKey => {entityId};
  
  @override
  String get tableName => DatabaseConstants.notesTable;
}
