import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

/// Custom toolbar for the rich text editor
class EditorToolbar extends StatelessWidget {
  final quill.QuillController controller;
  final VoidCallback? onLaTeXInsert;
  final VoidCallback? onLinkInsert;

  const EditorToolbar({
    super.key,
    required this.controller,
    this.onLaTeXInsert,
    this.onLinkInsert,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Undo/Redo
            quill.QuillToolbarHistoryButton(
              controller: controller,
              isUndo: true,
              options: const quill.QuillToolbarHistoryButtonOptions(),
            ),
            quill.QuillToolbarHistoryButton(
              controller: controller,
              isUndo: false,
              options: const quill.QuillToolbarHistoryButtonOptions(),
            ),
            
            _buildDivider(context),
            
            // Text formatting
            quill.QuillToolbarToggleStyleButton(
              attribute: quill.Attribute.bold,
              controller: controller,
              options: const quill.QuillToolbarToggleStyleButtonOptions(),
            ),
            quill.QuillToolbarToggleStyleButton(
              attribute: quill.Attribute.italic,
              controller: controller,
              options: const quill.QuillToolbarToggleStyleButtonOptions(),
            ),
            quill.QuillToolbarToggleStyleButton(
              attribute: quill.Attribute.underline,
              controller: controller,
              options: const quill.QuillToolbarToggleStyleButtonOptions(),
            ),
            quill.QuillToolbarToggleStyleButton(
              attribute: quill.Attribute.strikeThrough,
              controller: controller,
              options: const quill.QuillToolbarToggleStyleButtonOptions(),
            ),
            
            _buildDivider(context),
            
            // Headers
            quill.QuillToolbarSelectHeaderStyleButtons(
              controller: controller,
              options: const quill.QuillToolbarSelectHeaderStyleButtonsOptions(),
            ),
            
            _buildDivider(context),
            
            // Lists
            quill.QuillToolbarToggleStyleButton(
              attribute: quill.Attribute.ul,
              controller: controller,
              options: const quill.QuillToolbarToggleStyleButtonOptions(),
            ),
            quill.QuillToolbarToggleStyleButton(
              attribute: quill.Attribute.ol,
              controller: controller,
              options: const quill.QuillToolbarToggleStyleButtonOptions(),
            ),
            quill.QuillToolbarToggleCheckListButton(
              controller: controller,
              options: const quill.QuillToolbarToggleCheckListButtonOptions(),
            ),
            
            _buildDivider(context),
            
            // Code and quote
            quill.QuillToolbarToggleStyleButton(
              attribute: quill.Attribute.codeBlock,
              controller: controller,
              options: const quill.QuillToolbarToggleStyleButtonOptions(),
            ),
            quill.QuillToolbarToggleStyleButton(
              attribute: quill.Attribute.blockQuote,
              controller: controller,
              options: const quill.QuillToolbarToggleStyleButtonOptions(),
            ),
            
            _buildDivider(context),
            
            // Custom buttons
            if (onLinkInsert != null)
              IconButton(
                icon: const Icon(Icons.link),
                tooltip: 'Insert Link',
                onPressed: onLinkInsert,
                iconSize: 18,
              ),
            
            if (onLaTeXInsert != null)
              IconButton(
                icon: const Icon(Icons.functions),
                tooltip: 'Insert LaTeX',
                onPressed: onLaTeXInsert,
                iconSize: 18,
              ),
            
            _buildDivider(context),
            
            // Clear formatting
            quill.QuillToolbarClearFormatButton(
              controller: controller,
              options: const quill.QuillToolbarClearFormatButtonOptions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Theme.of(context).dividerColor,
    );
  }
}
