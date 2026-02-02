import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';

/// Utilities for converting between Quill Delta and Markdown
class MarkdownConverter {
  /// Convert Quill Delta JSON to Markdown string
  static String deltaToMarkdown(String deltaJson) {
    try {
      final doc = Document.fromJson(jsonDecode(deltaJson));
      final buffer = StringBuffer();
      
      for (final node in doc.root.children) {
        _nodeToMarkdown(node, buffer);
      }
      
      return buffer.toString().trim();
    } catch (e) {
      // If conversion fails, return empty string
      return '';
    }
  }

  static void _nodeToMarkdown(Node node, StringBuffer buffer) {
    if (node is Line) {
      final text = node.toPlainText();
      final style = node.style;
      
      // Handle headers
      if (style.containsKey('header')) {
        final level = style.attributes['header']?.value ?? 1;
        buffer.write('${'#' * level} $text\n\n');
        return;
      }
      
      // Handle code blocks
      if (style.containsKey('code-block')) {
        buffer.write('```\n$text\n```\n\n');
        return;
      }
      
      // Handle block quotes
      if (style.containsKey('blockquote')) {
        buffer.write('> $text\n\n');
        return;
      }
      
      // Handle lists
      if (style.containsKey('list')) {
        final listType = style.attributes['list']?.value;
        if (listType == 'bullet') {
          buffer.write('- $text\n');
        } else if (listType == 'ordered') {
          buffer.write('1. $text\n');
        } else if (listType == 'checked') {
          buffer.write('- [x] $text\n');
        } else if (listType == 'unchecked') {
          buffer.write('- [ ] $text\n');
        }
        return;
      }
      
      // Handle inline formatting
      String formattedText = text;
      for (final child in node.children) {
        if (child is Text) {
          String childText = child.toPlainText();
          
          if (child.style.containsKey('bold')) {
            childText = '**$childText**';
          }
          if (child.style.containsKey('italic')) {
            childText = '*$childText*';
          }
          if (child.style.containsKey('underline')) {
            childText = '<u>$childText</u>';
          }
          if (child.style.containsKey('strikethrough')) {
            childText = '~~$childText~~';
          }
          if (child.style.containsKey('code')) {
            childText = '`$childText`';
          }
          if (child.style.containsKey('link')) {
            final link = child.style.attributes['link']?.value ?? '';
            childText = '[$childText]($link)';
          }
          
          formattedText = childText;
        }
      }
      
      buffer.write('$formattedText\n\n');
    }
  }

  /// Convert Markdown string to Quill Delta JSON
  static String markdownToDelta(String markdown) {
    try {
      final doc = Document();
      final lines = markdown.split('\n');
      
      for (final line in lines) {
        if (line.isEmpty) continue;
        
        // Handle headers
        if (line.startsWith('#')) {
          final match = RegExp(r'^(#{1,6})\s+(.+)$').firstMatch(line);
          if (match != null) {
            final level = match.group(1)!.length;
            final text = match.group(2)!;
            doc.insert(doc.length, '$text\n');
            doc.format(doc.length - text.length - 1, text.length, 
              Style.attr({'header': level}));
            continue;
          }
        }
        
        // Handle code blocks
        if (line.startsWith('```')) {
          continue; // Skip code block markers for now
        }
        
        // Handle lists
        if (line.startsWith('- [ ]')) {
          final text = line.substring(5).trim();
          doc.insert(doc.length, '$text\n');
          doc.format(doc.length - text.length - 1, text.length,
            Style.attr({'list': 'unchecked'}));
          continue;
        }
        if (line.startsWith('- [x]')) {
          final text = line.substring(5).trim();
          doc.insert(doc.length, '$text\n');
          doc.format(doc.length - text.length - 1, text.length,
            Style.attr({'list': 'checked'}));
          continue;
        }
        if (line.startsWith('- ')) {
          final text = line.substring(2).trim();
          doc.insert(doc.length, '$text\n');
          doc.format(doc.length - text.length - 1, text.length,
            Style.attr({'list': 'bullet'}));
          continue;
        }
        if (RegExp(r'^\d+\.\s').hasMatch(line)) {
          final text = line.replaceFirst(RegExp(r'^\d+\.\s'), '').trim();
          doc.insert(doc.length, '$text\n');
          doc.format(doc.length - text.length - 1, text.length,
            Style.attr({'list': 'ordered'}));
          continue;
        }
        
        // Handle block quotes
        if (line.startsWith('> ')) {
          final text = line.substring(2);
          doc.insert(doc.length, '$text\n');
          doc.format(doc.length - text.length - 1, text.length,
            Style.attr({'blockquote': true}));
          continue;
        }
        
        // Regular text with inline formatting
        doc.insert(doc.length, '$line\n');
      }
      
      return jsonEncode(doc.toDelta().toJson());
    } catch (e) {
      // If conversion fails, return empty document
      return jsonEncode([
        {'insert': '\n'}
      ]);
    }
  }

  /// Convert plain text to Quill Delta JSON
  static String plainTextToDelta(String text) {
    final doc = Document()..insert(0, text);
    return jsonEncode(doc.toDelta().toJson());
  }

  /// Extract plain text from Quill Delta JSON
  static String deltaToPlainText(String deltaJson) {
    try {
      final doc = Document.fromJson(jsonDecode(deltaJson));
      return doc.toPlainText();
    } catch (e) {
      return '';
    }
  }
}
