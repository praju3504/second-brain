import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/vs2015.dart';

/// Widget for displaying code blocks with syntax highlighting
class CodeBlockWidget extends StatefulWidget {
  final String code;
  final String language;
  final bool showLineNumbers;
  final bool isEditable;
  final ValueChanged<String>? onCodeChanged;
  final ValueChanged<String>? onLanguageChanged;

  const CodeBlockWidget({
    super.key,
    required this.code,
    this.language = 'text',
    this.showLineNumbers = false,
    this.isEditable = false,
    this.onCodeChanged,
    this.onLanguageChanged,
  });

  @override
  State<CodeBlockWidget> createState() => _CodeBlockWidgetState();
}

class _CodeBlockWidgetState extends State<CodeBlockWidget> {
  static const List<String> _supportedLanguages = [
    'text',
    'dart',
    'python',
    'javascript',
    'typescript',
    'java',
    'kotlin',
    'swift',
    'rust',
    'go',
    'cpp',
    'c',
    'csharp',
    'php',
    'ruby',
    'sql',
    'json',
    'yaml',
    'xml',
    'html',
    'css',
    'markdown',
    'bash',
    'shell',
  ];

  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.language;
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = isDarkMode ? vs2015Theme : githubTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with language selector and copy button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                if (widget.isEditable)
                  DropdownButton<String>(
                    value: _selectedLanguage,
                    isDense: true,
                    underline: const SizedBox(),
                    items: _supportedLanguages.map((lang) {
                      return DropdownMenuItem(
                        value: lang,
                        child: Text(lang),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedLanguage = value);
                        widget.onLanguageChanged?.call(value);
                      }
                    },
                  )
                else
                  Text(
                    _selectedLanguage,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: 'Copy code',
                  onPressed: _copyToClipboard,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          
          // Code content
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: widget.showLineNumbers
                      ? _buildCodeWithLineNumbers(theme)
                      : HighlightView(
                          widget.code,
                          language: _selectedLanguage,
                          theme: theme,
                          padding: EdgeInsets.zero,
                          textStyle: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeWithLineNumbers(Map<String, TextStyle> theme) {
    final lines = widget.code.split('\n');
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line numbers
        Container(
          padding: const EdgeInsets.only(right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(lines.length, (index) {
              return Text(
                '${index + 1}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
              );
            }),
          ),
        ),
        
        // Code
        HighlightView(
          widget.code,
          language: _selectedLanguage,
          theme: theme,
          padding: EdgeInsets.zero,
          textStyle: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
