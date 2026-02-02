import 'package:equatable/equatable.dart';

/// Represents a parsed wiki-style link from content
class WikiLink extends Equatable {
  final String target;      // "Note Title"
  final String? alias;      // "Display Text" if provided
  final String? section;    // "Section" if # used
  final int startIndex;
  final int endIndex;
  final String rawText;     // "[[Note Title|Display Text]]"

  const WikiLink({
    required this.target,
    this.alias,
    this.section,
    required this.startIndex,
    required this.endIndex,
    required this.rawText,
  });

  String get displayText => alias ?? target;

  @override
  List<Object?> get props => [target, alias, section, startIndex, endIndex, rawText];
}

/// Parser for [[wiki links]] in text content
class WikiLinkParser {
  // Regex pattern: \[\[([^\]]+)\]\]
  static final RegExp _wikiLinkPattern = RegExp(r'\[\[([^\]]+)\]\]');

  /// Extract all wiki links from the given content
  static List<WikiLink> parseLinks(String content) {
    final links = <WikiLink>[];
    final matches = _wikiLinkPattern.allMatches(content);

    for (final match in matches) {
      final rawText = match.group(0)!;
      final innerText = match.group(1)!;
      
      // Parse the inner text for target, alias, and section
      String target;
      String? alias;
      String? section;

      // Check for alias: [[Target|Alias]]
      if (innerText.contains('|')) {
        final parts = innerText.split('|');
        target = parts[0].trim();
        alias = parts[1].trim();
      } else {
        target = innerText.trim();
      }

      // Check for section: [[Target#Section]]
      if (target.contains('#')) {
        final parts = target.split('#');
        target = parts[0].trim();
        section = parts[1].trim();
      }

      links.add(WikiLink(
        target: target,
        alias: alias,
        section: section,
        startIndex: match.start,
        endIndex: match.end,
        rawText: rawText,
      ));
    }

    return links;
  }

  /// Check if the given text contains any wiki links
  static bool containsLinks(String content) {
    return _wikiLinkPattern.hasMatch(content);
  }

  /// Extract just the target note titles from content
  static List<String> extractTargets(String content) {
    return parseLinks(content).map((link) => link.target).toList();
  }

  /// Get context around a wiki link (for backlink previews)
  static String getContext(String content, WikiLink link, {int contextLength = 50}) {
    final start = (link.startIndex - contextLength).clamp(0, content.length);
    final end = (link.endIndex + contextLength).clamp(0, content.length);
    
    String context = content.substring(start, end);
    
    // Add ellipsis if truncated
    if (start > 0) context = '...$context';
    if (end < content.length) context = '$context...';
    
    return context;
  }
}
