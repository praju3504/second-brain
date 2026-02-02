import 'package:drift/drift.dart';
import 'package:second_brain/core/constants/database_constants.dart';
import 'package:second_brain/data/database/tables/entities_table.dart';

@DataClassName('TaskData')
class Tasks extends Table {
  TextColumn get entityId => text().references(Entities, #id, onDelete: KeyAction.cascade)();
  TextColumn get description => text().nullable()();
  TextColumn get status => text()();
  TextColumn get priority => text()();
  IntColumn get dueDate => integer().nullable()();
  IntColumn get reminderAt => integer().nullable()();
  TextColumn get recurrenceRule => text().nullable()();
  IntColumn get timeEstimate => integer().nullable()();
  IntColumn get timeSpent => integer().nullable()();
  IntColumn get completedAt => integer().nullable()();
  
  @override
  Set<Column> get primaryKey => {entityId};
  
  @override
  String get tableName => DatabaseConstants.tasksTable;
}
