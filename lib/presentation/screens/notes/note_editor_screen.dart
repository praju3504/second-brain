import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:second_brain/core/extensions/date_extensions.dart';
import 'package:second_brain/presentation/providers/notes_provider.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;
  
  const NoteEditorScreen({super.key, this.noteId});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = true;
  int? _createdAt;
  int? _updatedAt;
  
  @override
  void initState() {
    super.initState();
    _loadNote();
  }
  
  Future<void> _loadNote() async {
    if (widget.noteId != null) {
      final repository = ref.read(noteRepositoryProvider);
      final note = await repository.getNoteById(widget.noteId!);
      if (note != null && mounted) {
        setState(() {
          _titleController.text = note.title;
          _contentController.text = note.contentPlain;
          _createdAt = note.createdAt;
          _updatedAt = note.updatedAt;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteId == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveNote,
          ),
          if (widget.noteId != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteNote,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: Theme.of(context).textTheme.headlineSmall,
              decoration: const InputDecoration(
                hintText: 'Note title',
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 8),
            if (_createdAt != null) ...[
              Text(
                'Created: ${_createdAt!.toDateTime().toFormattedDateTime()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (_updatedAt != null && _updatedAt != _createdAt)
                Text(
                  'Updated: ${_updatedAt!.toDateTime().toFormattedDateTime()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const Divider(height: 32),
            ],
            TextField(
              controller: _contentController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: 'Start typing...',
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    
    try {
      if (widget.noteId == null) {
        await ref.read(notesProvider.notifier).addNote(title, content);
      } else {
        final repository = ref.read(noteRepositoryProvider);
        final note = await repository.getNoteById(widget.noteId!);
        if (note != null) {
          final updatedNote = note.copyWith(
            title: title,
            contentJson: content,
            contentPlain: content,
          );
          await ref.read(notesProvider.notifier).updateNote(updatedNote);
        }
      }
      
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving note: $e')),
        );
      }
    }
  }
  
  Future<void> _deleteNote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && widget.noteId != null) {
      await ref.read(notesProvider.notifier).deleteNote(widget.noteId!);
      if (mounted) {
        context.pop();
      }
    }
  }
}
