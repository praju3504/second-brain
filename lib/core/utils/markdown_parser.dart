import 'package:markdown/markdown.dart' as md;
import 'package:second_brain/core/utils/wiki_link_parser.dart';

/// Custom markdown parser that handles wiki links and LaTeX
class MarkdownParser {
  /// Parse markdown with wiki link support
  static String parseMarkdown(String markdown) {
    // First, handle wiki links
    final processedMarkdown = _processWikiLinks(markdown);
    
    // Then parse as regular markdown
    return md.markdownToHtml(processedMarkdown, extensionSet: md.ExtensionSet.gitHubFlavored);
  }

  /// Process wiki links to HTML
  static String _processWikiLinks(String markdown) {
    final links = WikiLinkParser.parseLinks(markdown);
    
    // Replace wiki links with HTML anchors
    String result = markdown;
    for (final link in links.reversed) {
      final replacement = '<a href="/notes/${Uri.encodeComponent(link.target)}" class="wiki-link">${link.displayText}</a>';
      result = result.replaceRange(link.startIndex, link.endIndex, replacement);
    }
    
    return result;
  }

  /// Extract LaTeX blocks from markdown
  static List<LaTeXBlock> extractLaTeXBlocks(String markdown) {
    final blocks = <LaTeXBlock>[];
    
    // Find block math: $$...$$
    final blockPattern = RegExp(r'\$\$([^\$]+)\$\$');
    for (final match in blockPattern.allMatches(markdown)) {
      blocks.add(LaTeXBlock(
        content: match.group(1)!.trim(),
        isInline: false,
        startIndex: match.start,
        endIndex: match.end,
      ));
    }
    
    // Find inline math: $...$
    final inlinePattern = RegExp(r'\$([^\$]+)\$');
    for (final match in inlinePattern.allMatches(markdown)) {
      // Skip if it's part of a block math
      if (blocks.any((b) => match.start >= b.startIndex && match.end <= b.endIndex)) {
        continue;
      }
      blocks.add(LaTeXBlock(
        content: match.group(1)!.trim(),
        isInline: true,
        startIndex: match.start,
        endIndex: match.end,
      ));
    }
    
    return blocks;
  }

  /// Parse markdown with LaTeX rendering
  static String parseWithLaTeX(String markdown) {
    String result = markdown;
    final latexBlocks = extractLaTeXBlocks(markdown);
    
    // Replace LaTeX blocks with placeholders for rendering
    for (final block in latexBlocks.reversed) {
      final placeholder = block.isInline
          ? '<span class="latex-inline">${block.content}</span>'
          : '<div class="latex-block">${block.content}</div>';
      result = result.replaceRange(block.startIndex, block.endIndex, placeholder);
    }
    
    return parseMarkdown(result);
  }

  /// Check if markdown contains LaTeX
  static bool containsLaTeX(String markdown) {
    return markdown.contains(RegExp(r'\$.*?\$'));
  }

  /// Check if markdown contains code blocks
  static bool containsCodeBlocks(String markdown) {
    return markdown.contains(RegExp(r'```'));
  }

  /// Extract code blocks with language
  static List<CodeBlock> extractCodeBlocks(String markdown) {
    final blocks = <CodeBlock>[];
    final pattern = RegExp(r'```(\w+)?\n([\s\S]*?)```');
    
    for (final match in pattern.allMatches(markdown)) {
      blocks.add(CodeBlock(
        language: match.group(1) ?? 'text',
        code: match.group(2)!.trim(),
        startIndex: match.start,
        endIndex: match.end,
      ));
    }
    
    return blocks;
  }
}

/// Represents a LaTeX block in markdown
class LaTeXBlock {
  final String content;
  final bool isInline;
  final int startIndex;
  final int endIndex;

  const LaTeXBlock({
    required this.content,
    required this.isInline,
    required this.startIndex,
    required this.endIndex,
  });
}

/// Represents a code block in markdown
class CodeBlock {
  final String language;
  final String code;
  final int startIndex;
  final int endIndex;

  const CodeBlock({
    required this.language,
    required this.code,
    required this.startIndex,
    required this.endIndex,
  });
}
