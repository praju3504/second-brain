import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:second_brain/core/extensions/date_extensions.dart';
import 'package:second_brain/core/utils/uuid_generator.dart';
import 'package:second_brain/data/repositories/file_repository_impl.dart';
import 'package:second_brain/domain/entities/file_entity.dart';
import 'package:second_brain/domain/repositories/file_repository.dart';
import 'package:second_brain/presentation/providers/database_provider.dart';

enum FileViewMode { grid, list }

final fileRepositoryProvider = Provider<FileRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return FileRepositoryImpl(database);
});

final filesProvider = StateNotifierProvider<FilesNotifier, AsyncValue<List<FileEntity>>>((ref) {
  return FilesNotifier(ref.watch(fileRepositoryProvider));
});

final fileViewModeProvider = StateProvider<FileViewMode>((ref) {
  return FileViewMode.grid;
});

class FilesNotifier extends StateNotifier<AsyncValue<List<FileEntity>>> {
  final FileRepository _repository;
  
  FilesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadFiles();
  }
  
  Future<void> loadFiles() async {
    state = const AsyncValue.loading();
    try {
      final files = await _repository.getAllFiles();
      state = AsyncValue.data(files);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> addFile({
    required String title,
    required String mimeType,
    required int fileSize,
    required String localPath,
    String? thumbnailPath,
  }) async {
    try {
      final now = DateTime.now().toTimestamp();
      final file = FileEntity(
        id: UuidGenerator.generate(),
        title: title,
        mimeType: mimeType,
        fileSize: fileSize,
        localPath: localPath,
        thumbnailPath: thumbnailPath,
        createdAt: now,
        updatedAt: now,
      );
      
      await _repository.insertFile(file);
      await loadFiles();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> deleteFile(String id) async {
    try {
      await _repository.deleteFile(id);
      await loadFiles();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
