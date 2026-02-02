import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:second_brain/core/constants/database_constants.dart';
import 'package:second_brain/data/database/daos/file_dao.dart';
import 'package:second_brain/data/database/daos/link_dao.dart';
import 'package:second_brain/data/database/daos/note_dao.dart';
import 'package:second_brain/data/database/daos/task_dao.dart';
import 'package:second_brain/data/database/tables/entities_table.dart';
import 'package:second_brain/data/database/tables/files_table.dart';
import 'package:second_brain/data/database/tables/links_table.dart';
import 'package:second_brain/data/database/tables/notes_table.dart';
import 'package:second_brain/data/database/tables/tags_table.dart';
import 'package:second_brain/data/database/tables/tasks_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Entities, Notes, Tasks, Files, Links, Tags],
  daos: [NoteDao, TaskDao, FileDao, LinkDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => DatabaseConstants.databaseVersion;

  Future<void> init() async {
    // Database initialization is handled automatically by Drift
    // This method is provided for any additional setup if needed
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle schema migrations here in future versions
        if (from < 2) {
          // Add new columns to links table if upgrading from version 1
          await m.addColumn(links, links.linkText);
          await m.addColumn(links, links.position);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, DatabaseConstants.databaseName));
    return NativeDatabase(file);
  });
}
