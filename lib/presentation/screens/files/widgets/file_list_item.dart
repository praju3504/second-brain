import 'package:flutter/material.dart';
import 'package:second_brain/core/extensions/date_extensions.dart';
import 'package:second_brain/domain/entities/file_entity.dart';

class FileListItem extends StatelessWidget {
  final FileEntity file;
  final VoidCallback onDelete;
  
  const FileListItem({
    super.key,
    required this.file,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getFileIcon(file.mimeType),
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(file.title),
        subtitle: Text(
          '${_formatFileSize(file.fileSize)} • ${file.createdAt.toDateTime().toFormattedDate()}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete File'),
                content: const Text('Are you sure you want to delete this file?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onDelete();
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          },
        ),
        onTap: () {
          // TODO: Open file viewer
        },
      ),
    );
  }
  
  IconData _getFileIcon(String mimeType) {
    if (mimeType.startsWith('image/')) return Icons.image;
    if (mimeType.startsWith('video/')) return Icons.video_file;
    if (mimeType.startsWith('audio/')) return Icons.audio_file;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf;
    if (mimeType.contains('word') || mimeType.contains('document')) return Icons.description;
    if (mimeType.contains('excel') || mimeType.contains('spreadsheet')) return Icons.table_chart;
    if (mimeType.contains('powerpoint') || mimeType.contains('presentation')) return Icons.slideshow;
    if (mimeType.contains('zip') || mimeType.contains('compressed')) return Icons.folder_zip;
    return Icons.insert_drive_file;
  }
  
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
