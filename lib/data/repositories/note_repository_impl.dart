import 'package:second_brain/data/database/app_database.dart';
import 'package:second_brain/domain/entities/note.dart';
import 'package:second_brain/domain/repositories/note_repository.dart';

class NoteRepositoryImpl implements NoteRepository {
  final AppDatabase _database;
  
  NoteRepositoryImpl(this._database);
  
  @override
  Future<List<Note>> getAllNotes() {
    return _database.noteDao.getAllNotes();
  }
  
  @override
  Future<Note?> getNoteById(String id) {
    return _database.noteDao.getNoteById(id);
  }
  
  @override
  Future<List<Note>> searchNotes(String query) {
    return _database.noteDao.searchNotes(query);
  }
  
  @override
  Future<void> insertNote(Note note) {
    return _database.noteDao.insertNote(note);
  }
  
  @override
  Future<void> updateNote(Note note) {
    return _database.noteDao.updateNote(note);
  }
  
  @override
  Future<void> deleteNote(String id) {
    return _database.noteDao.deleteNote(id);
  }
}
