import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// Widget for rendering LaTeX math expressions
class LaTeXBlock extends StatefulWidget {
  final String latex;
  final bool isInline;
  final bool isEditable;
  final ValueChanged<String>? onChanged;

  const LaTeXBlock({
    super.key,
    required this.latex,
    this.isInline = false,
    this.isEditable = false,
    this.onChanged,
  });

  @override
  State<LaTeXBlock> createState() => _LaTeXBlockState();
}

class _LaTeXBlockState extends State<LaTeXBlock> {
  bool _isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.latex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing && widget.isEditable) {
      return _buildEditMode();
    }
    return _buildViewMode();
  }

  Widget _buildViewMode() {
    Widget mathWidget;
    
    try {
      mathWidget = Math.tex(
        widget.latex,
        textStyle: widget.isInline 
          ? Theme.of(context).textTheme.bodyMedium
          : Theme.of(context).textTheme.bodyLarge,
      );
    } catch (e) {
      // Display error if LaTeX is invalid
      mathWidget = Text(
        'Invalid LaTeX: ${widget.latex}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontFamily: 'monospace',
        ),
      );
    }

    if (widget.isEditable) {
      mathWidget = InkWell(
        onTap: () => setState(() => _isEditing = true),
        child: mathWidget,
      );
    }

    return widget.isInline
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: mathWidget,
          )
        : Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: mathWidget),
          );
  }

  Widget _buildEditMode() {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.primary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'LaTeX Expression',
              border: OutlineInputBorder(),
              hintText: r'e.g., x^2 + y^2 = r^2',
            ),
            maxLines: widget.isInline ? 1 : 3,
          ),
          const SizedBox(height: 8),
          // Preview
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _buildPreview(),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _controller.text = widget.latex;
                    _isEditing = false;
                  });
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  widget.onChanged?.call(_controller.text);
                  setState(() => _isEditing = false);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    try {
      return Math.tex(
        _controller.text,
        textStyle: Theme.of(context).textTheme.bodyMedium,
      );
    } catch (e) {
      return Text(
        'Preview: Invalid LaTeX',
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontStyle: FontStyle.italic,
        ),
      );
    }
  }
}
