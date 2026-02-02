import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:second_brain/core/utils/markdown_converter.dart';

/// Rich text editor widget with Quill integration
class RichTextEditor extends StatefulWidget {
  final String? initialContent;
  final ValueChanged<String>? onChanged;
  final quill.QuillController? controller;
  final FocusNode? focusNode;
  final bool readOnly;

  const RichTextEditor({
    super.key,
    this.initialContent,
    this.onChanged,
    this.controller,
    this.focusNode,
    this.readOnly = false,
  });

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late quill.QuillController _controller;
  late FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _ownsController = true;
      _controller = _createController(widget.initialContent);
    }

    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _ownsFocusNode = true;
      _focusNode = FocusNode();
    }

    _controller.addListener(_onContentChanged);
  }

  quill.QuillController _createController(String? content) {
    if (content == null || content.isEmpty) {
      return quill.QuillController.basic();
    }

    try {
      // Try to parse as JSON (Quill Delta format)
      final delta = quill.Document.fromJson(jsonDecode(content));
      return quill.QuillController(
        document: delta,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      // If not JSON, treat as plain text
      final doc = quill.Document()..insert(0, content);
      return quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
  }

  void _onContentChanged() {
    if (widget.onChanged != null) {
      final delta = _controller.document.toDelta();
      final json = jsonEncode(delta.toJson());
      widget.onChanged!(json);
    }
  }

  @override
  void didUpdateWidget(RichTextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.controller != oldWidget.controller) {
      if (_ownsController) {
        _controller.removeListener(_onContentChanged);
        _controller.dispose();
      }
      
      if (widget.controller != null) {
        _ownsController = false;
        _controller = widget.controller!;
      } else {
        _ownsController = true;
        _controller = _createController(widget.initialContent);
      }
      
      _controller.addListener(_onContentChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onContentChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: quill.QuillEditor(
        controller: _controller,
        scrollController: ScrollController(),
        focusNode: _focusNode,
        configurations: quill.QuillEditorConfigurations(
          padding: const EdgeInsets.all(16),
          readOnly: widget.readOnly,
          placeholder: 'Start typing...',
          autoFocus: false,
          expands: false,
          scrollable: true,
        ),
      ),
    );
  }

  /// Get the current content as JSON
  String getContentJson() {
    final delta = _controller.document.toDelta();
    return jsonEncode(delta.toJson());
  }

  /// Get the current content as plain text
  String getContentPlainText() {
    return _controller.document.toPlainText();
  }

  /// Get the current content as markdown
  String getContentMarkdown() {
    return MarkdownConverter.deltaToMarkdown(getContentJson());
  }
}
