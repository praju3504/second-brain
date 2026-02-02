import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:second_brain/core/extensions/date_extensions.dart';
import 'package:second_brain/core/utils/uuid_generator.dart';
import 'package:second_brain/data/repositories/note_repository_impl.dart';
import 'package:second_brain/domain/entities/note.dart';
import 'package:second_brain/domain/repositories/note_repository.dart';
import 'package:second_brain/presentation/providers/database_provider.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return NoteRepositoryImpl(database);
});

final notesProvider = StateNotifierProvider<NotesNotifier, AsyncValue<List<Note>>>((ref) {
  return NotesNotifier(ref.watch(noteRepositoryProvider));
});

class NotesNotifier extends StateNotifier<AsyncValue<List<Note>>> {
  final NoteRepository _repository;
  
  NotesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadNotes();
  }
  
  Future<void> loadNotes() async {
    state = const AsyncValue.loading();
    try {
      final notes = await _repository.getAllNotes();
      state = AsyncValue.data(notes);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> addNote(String title, String content) async {
    try {
      final now = DateTime.now().toTimestamp();
      final note = Note(
        id: UuidGenerator.generate(),
        title: title,
        contentJson: content,
        contentPlain: content,
        createdAt: now,
        updatedAt: now,
      );
      
      await _repository.insertNote(note);
      await loadNotes();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> updateNote(Note note) async {
    try {
      final updatedNote = note.copyWith(
        updatedAt: DateTime.now().toTimestamp(),
      );
      await _repository.updateNote(updatedNote);
      await loadNotes();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> deleteNote(String id) async {
    try {
      await _repository.deleteNote(id);
      await loadNotes();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> searchNotes(String query) async {
    state = const AsyncValue.loading();
    try {
      final notes = await _repository.searchNotes(query);
      state = AsyncValue.data(notes);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
