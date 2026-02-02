import 'package:drift/drift.dart';
import 'package:second_brain/data/database/app_database.dart';
import 'package:second_brain/data/database/tables/entities_table.dart';
import 'package:second_brain/data/database/tables/notes_table.dart';
import 'package:second_brain/domain/entities/note.dart';
import 'package:second_brain/domain/enums/entity_type.dart';

part 'note_dao.g.dart';

@DriftAccessor(tables: [Entities, Notes])
class NoteDao extends DatabaseAccessor<AppDatabase> with _$NoteDaoMixin {
  NoteDao(AppDatabase db) : super(db);
  
  Future<List<Note>> getAllNotes() async {
    final query = select(entities).join([
      innerJoin(notes, notes.entityId.equalsExp(entities.id)),
    ])..where(entities.entityType.equals(EntityType.note.name) & entities.deletedAt.isNull());
    
    final results = await query.get();
    return results.map((row) => _mapToNote(row)).toList();
  }
  
  Future<Note?> getNoteById(String id) async {
    final query = select(entities).join([
      innerJoin(notes, notes.entityId.equalsExp(entities.id)),
    ])..where(entities.id.equals(id) & entities.deletedAt.isNull());
    
    final results = await query.get();
    if (results.isEmpty) return null;
    return _mapToNote(results.first);
  }
  
  Future<List<Note>> searchNotes(String query) async {
    final searchQuery = select(entities).join([
      innerJoin(notes, notes.entityId.equalsExp(entities.id)),
    ])..where(
      (entities.entityType.equals(EntityType.note.name) & entities.deletedAt.isNull()) &
      (entities.title.like('%$query%') | notes.contentPlain.like('%$query%'))
    );
    
    final results = await searchQuery.get();
    return results.map((row) => _mapToNote(row)).toList();
  }
  
  Future<void> insertNote(Note note) async {
    await into(entities).insert(
      EntitiesCompanion.insert(
        id: note.id,
        entityType: EntityType.note.name,
        title: note.title,
        createdAt: note.createdAt,
        updatedAt: note.updatedAt,
        parentId: Value(note.parentId),
      ),
    );
    
    await into(notes).insert(
      NotesCompanion.insert(
        entityId: note.id,
        contentJson: note.contentJson,
        contentPlain: note.contentPlain,
        contentHash: note.contentPlain.hashCode.toString(),
      ),
    );
  }
  
  Future<void> updateNote(Note note) async {
    await (update(entities)..where((t) => t.id.equals(note.id))).write(
      EntitiesCompanion(
        title: Value(note.title),
        updatedAt: Value(note.updatedAt),
        parentId: Value(note.parentId),
      ),
    );
    
    await (update(notes)..where((t) => t.entityId.equals(note.id))).write(
      NotesCompanion(
        contentJson: Value(note.contentJson),
        contentPlain: Value(note.contentPlain),
        contentHash: Value(note.contentPlain.hashCode.toString()),
      ),
    );
  }
  
  Future<void> deleteNote(String id) async {
    await (update(entities)..where((t) => t.id.equals(id))).write(
      EntitiesCompanion(
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      ),
    );
  }
  
  Note _mapToNote(TypedResult row) {
    final entity = row.readTable(entities);
    final noteData = row.readTable(notes);
    
    return Note(
      id: entity.id,
      title: entity.title,
      contentJson: noteData.contentJson,
      contentPlain: noteData.contentPlain,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      parentId: entity.parentId,
    );
  }
}
