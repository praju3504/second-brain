import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:go_router/go_router.dart';
import 'package:second_brain/core/extensions/date_extensions.dart';
import 'package:second_brain/core/services/auto_save_service.dart';
import 'package:second_brain/core/utils/markdown_converter.dart';
import 'package:second_brain/presentation/providers/links_provider.dart';
import 'package:second_brain/presentation/providers/notes_provider.dart';
import 'package:second_brain/presentation/widgets/backlinks/backlinks_panel.dart';
import 'package:second_brain/presentation/widgets/editor/editor_toolbar.dart';
import 'package:second_brain/presentation/widgets/editor/latex_input_dialog.dart';
import 'package:second_brain/presentation/widgets/editor/rich_text_editor.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;
  
  const NoteEditorScreen({super.key, this.noteId});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _titleController = TextEditingController();
  late quill.QuillController _quillController;
  final _focusNode = FocusNode();
  
  bool _isLoading = true;
  bool _isPreviewMode = false;
  int? _createdAt;
  int? _updatedAt;
  
  AutoSaveService? _autoSaveService;
  
  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();
    _loadNote();
  }
  
  Future<void> _loadNote() async {
    if (widget.noteId != null) {
      final repository = ref.read(noteRepositoryProvider);
      final note = await repository.getNoteById(widget.noteId!);
      if (note != null && mounted) {
        setState(() {
          _titleController.text = note.title;
          _createdAt = note.createdAt;
          _updatedAt = note.updatedAt;
          
          // Load content into Quill controller
          try {
            final doc = quill.Document.fromJson(jsonDecode(note.contentJson));
            _quillController = quill.QuillController(
              document: doc,
              selection: const TextSelection.collapsed(offset: 0),
            );
          } catch (e) {
            // If not valid JSON, treat as plain text
            final doc = quill.Document()..insert(0, note.contentPlain);
            _quillController = quill.QuillController(
              document: doc,
              selection: const TextSelection.collapsed(offset: 0),
            );
          }
          
          _isLoading = false;
        });
        
        // Setup auto-save
        _setupAutoSave();
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      _setupAutoSave();
    }
  }
  
  void _setupAutoSave() {
    _autoSaveService = AutoSaveService(
      onSave: (content) async {
        await _saveNote(showSnackbar: false);
      },
      debounceDuration: const Duration(seconds: 2),
    );
    
    _quillController.addListener(() {
      final content = jsonEncode(_quillController.document.toDelta().toJson());
      _autoSaveService?.updateContent(content);
    });
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _focusNode.dispose();
    _autoSaveService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final backlinksAsync = widget.noteId != null 
      ? ref.watch(backlinksProvider(widget.noteId!))
      : null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteId == null ? 'New Note' : 'Edit Note'),
        actions: [
          // Preview toggle
          IconButton(
            icon: Icon(_isPreviewMode ? Icons.edit : Icons.preview),
            onPressed: () => setState(() => _isPreviewMode = !_isPreviewMode),
            tooltip: _isPreviewMode ? 'Edit' : 'Preview',
          ),
          
          // Save button
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => _saveNote(showSnackbar: true, andClose: true),
          ),
          
          // Delete button
          if (widget.noteId != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteNote,
            ),
        ],
      ),
      body: Column(
        children: [
          // Toolbar
          if (!_isPreviewMode)
            EditorToolbar(
              controller: _quillController,
              onLaTeXInsert: _insertLaTeX,
              onLinkInsert: _insertLink,
            ),
          
          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title field
                  TextField(
                    controller: _titleController,
                    style: Theme.of(context).textTheme.headlineSmall,
                    decoration: const InputDecoration(
                      hintText: 'Note title',
                      border: InputBorder.none,
                    ),
                    readOnly: _isPreviewMode,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Metadata
                  if (_createdAt != null) ...[
                    Row(
                      children: [
                        Text(
                          'Created: ${_createdAt!.toDateTime().toFormattedDateTime()}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        if (_autoSaveService != null)
                          Text(
                            _autoSaveService!.statusText,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                    if (_updatedAt != null && _updatedAt != _createdAt)
                      Text(
                        'Updated: ${_updatedAt!.toDateTime().toFormattedDateTime()}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    const Divider(height: 32),
                  ],
                  
                  // Editor
                  if (_isPreviewMode)
                    _buildPreview()
                  else
                    Container(
                      constraints: const BoxConstraints(minHeight: 300),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: quill.QuillEditor(
                        controller: _quillController,
                        scrollController: ScrollController(),
                        focusNode: _focusNode,
                        configurations: const quill.QuillEditorConfigurations(
                          padding: EdgeInsets.all(16),
                          placeholder: 'Start typing...',
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Word count
                  _buildWordCount(),
                  
                  // Backlinks panel
                  if (widget.noteId != null && backlinksAsync != null)
                    backlinksAsync.when(
                      data: (backlinks) => BacklinksPanel(
                        backlinks: backlinks,
                        onRefresh: () {
                          ref.invalidate(backlinksProvider(widget.noteId!));
                        },
                      ),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPreview() {
    final markdown = MarkdownConverter.deltaToMarkdown(
      jsonEncode(_quillController.document.toDelta().toJson())
    );
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(markdown),
    );
  }
  
  Widget _buildWordCount() {
    final text = _quillController.document.toPlainText();
    final wordCount = text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final charCount = text.length;
    
    return Text(
      '$wordCount words • $charCount characters',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }
  
  Future<void> _insertLaTeX() async {
    final latex = await LaTeXInputDialog.show(context);
    if (latex != null) {
      _quillController.document.insert(
        _quillController.selection.baseOffset,
        '\$\$$latex\$\$ ',
      );
    }
  }
  
  Future<void> _insertLink() async {
    // For now, insert placeholder - full autocomplete would need more integration
    _quillController.document.insert(
      _quillController.selection.baseOffset,
      '[[]]',
    );
    _quillController.updateSelection(
      TextSelection.collapsed(offset: _quillController.selection.baseOffset + 2),
      quill.ChangeSource.local,
    );
  }
  
  Future<void> _saveNote({bool showSnackbar = false, bool andClose = false}) async {
    final title = _titleController.text.trim();
    final contentJson = jsonEncode(_quillController.document.toDelta().toJson());
    final contentPlain = _quillController.document.toPlainText();
    
    if (title.isEmpty) {
      if (showSnackbar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a title')),
        );
      }
      return;
    }
    
    try {
      if (widget.noteId == null) {
        await ref.read(notesProvider.notifier).addNote(title, contentJson);
      } else {
        final repository = ref.read(noteRepositoryProvider);
        final note = await repository.getNoteById(widget.noteId!);
        if (note != null) {
          final updatedNote = note.copyWith(
            title: title,
            contentJson: contentJson,
            contentPlain: contentPlain,
          );
          await ref.read(notesProvider.notifier).updateNote(updatedNote);
          
          // Sync links
          await ref.read(linksNotifierProvider.notifier).syncLinks(
            widget.noteId!,
            contentPlain,
          );
          
          setState(() {
            _updatedAt = updatedNote.updatedAt;
          });
        }
      }
      
      if (showSnackbar && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note saved')),
        );
      }
      
      if (andClose && mounted) {
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
