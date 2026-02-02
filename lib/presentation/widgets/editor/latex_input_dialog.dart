import 'package:flutter/material.dart';
import 'package:second_brain/presentation/widgets/editor/latex_block.dart';

/// Dialog for inserting LaTeX expressions
class LaTeXInputDialog extends StatefulWidget {
  final String? initialLatex;
  final bool isInline;

  const LaTeXInputDialog({
    super.key,
    this.initialLatex,
    this.isInline = false,
  });

  @override
  State<LaTeXInputDialog> createState() => _LaTeXInputDialogState();
}

class _LaTeXInputDialogState extends State<LaTeXInputDialog> {
  late TextEditingController _controller;
  String _previewLatex = '';

  // Common LaTeX symbols
  static const List<Map<String, String>> _commonSymbols = [
    {'label': '√', 'latex': r'\sqrt{}'},
    {'label': '∫', 'latex': r'\int'},
    {'label': '∑', 'latex': r'\sum'},
    {'label': '∞', 'latex': r'\infty'},
    {'label': 'α', 'latex': r'\alpha'},
    {'label': 'β', 'latex': r'\beta'},
    {'label': '≤', 'latex': r'\leq'},
    {'label': '≥', 'latex': r'\geq'},
    {'label': '≠', 'latex': r'\neq'},
    {'label': '±', 'latex': r'\pm'},
    {'label': 'π', 'latex': r'\pi'},
    {'label': 'θ', 'latex': r'\theta'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialLatex ?? '');
    _previewLatex = widget.initialLatex ?? '';
    _controller.addListener(() {
      setState(() {
        _previewLatex = _controller.text;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _insertSymbol(String latex) {
    final currentText = _controller.text;
    final selection = _controller.selection;
    final newText = currentText.replaceRange(
      selection.start,
      selection.end,
      latex,
    );
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(
      offset: selection.start + latex.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isInline ? 'Insert Inline Math' : 'Insert Block Math'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'LaTeX Expression',
                hintText: widget.isInline 
                  ? r'e.g., x^2 + y^2' 
                  : r'e.g., \frac{a}{b} = c',
                border: const OutlineInputBorder(),
              ),
              maxLines: widget.isInline ? 1 : 4,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            
            // Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(minHeight: 80),
              child: _previewLatex.isEmpty
                  ? Center(
                      child: Text(
                        'Preview will appear here',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    )
                  : LaTeXBlock(
                      latex: _previewLatex,
                      isInline: widget.isInline,
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // Common symbols
            Text(
              'Common Symbols',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonSymbols.map((symbol) {
                return InkWell(
                  onTap: () => _insertSymbol(symbol['latex']!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      symbol['label']!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              Navigator.of(context).pop(_controller.text);
            }
          },
          child: const Text('Insert'),
        ),
      ],
    );
  }

  /// Show the dialog and return the entered LaTeX
  static Future<String?> show(
    BuildContext context, {
    String? initialLatex,
    bool isInline = false,
  }) async {
    return showDialog<String>(
      context: context,
      builder: (context) => LaTeXInputDialog(
        initialLatex: initialLatex,
        isInline: isInline,
      ),
    );
  }
}
