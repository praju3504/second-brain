import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:second_brain/presentation/providers/files_provider.dart';
import 'package:second_brain/presentation/screens/files/widgets/file_grid_item.dart';
import 'package:second_brain/presentation/screens/files/widgets/file_list_item.dart';
import 'package:second_brain/presentation/widgets/app_bottom_nav.dart';
import 'package:second_brain/presentation/widgets/empty_state.dart';
import 'package:second_brain/presentation/widgets/loading_indicator.dart';

class FilesScreen extends ConsumerWidget {
  const FilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filesState = ref.watch(filesProvider);
    final viewMode = ref.watch(fileViewModeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Files'),
        actions: [
          IconButton(
            icon: Icon(
              viewMode == FileViewMode.grid 
                  ? Icons.view_list 
                  : Icons.grid_view,
            ),
            onPressed: () {
              ref.read(fileViewModeProvider.notifier).state = 
                  viewMode == FileViewMode.grid 
                      ? FileViewMode.list 
                      : FileViewMode.grid;
            },
          ),
        ],
      ),
      body: filesState.when(
        data: (files) {
          if (files.isEmpty) {
            return const EmptyState(
              icon: Icons.folder_outlined,
              title: 'No files yet',
              subtitle: 'Tap + to import your first file',
            );
          }
          
          if (viewMode == FileViewMode.grid) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: files.length,
              itemBuilder: (context, index) {
                return FileGridItem(file: files[index]);
              },
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: files.length,
              itemBuilder: (context, index) {
                return FileListItem(
                  file: files[index],
                  onDelete: () {
                    ref.read(filesProvider.notifier).deleteFile(files[index].id);
                  },
                );
              },
            );
          }
        },
        loading: () => const LoadingIndicator(),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/notes');
              break;
            case 2:
              context.go('/tasks');
              break;
            case 3:
              break;
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _importFile(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Future<void> _importFile(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles();
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          final fileObj = File(file.path!);
          final fileSize = await fileObj.length();
          final mimeType = lookupMimeType(file.path!) ?? 'application/octet-stream';
          
          await ref.read(filesProvider.notifier).addFile(
            title: file.name,
            mimeType: mimeType,
            fileSize: fileSize,
            localPath: file.path!,
          );
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File imported successfully')),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing file: $e')),
        );
      }
    }
  }
}
