import 'package:flutter/material.dart';
import 'package:second_brain/domain/entities/note.dart';

/// Autocomplete overlay for wiki link suggestions
class LinkAutocomplete extends StatelessWidget {
  final String query;
  final List<Note> suggestions;
  final ValueChanged<Note> onSelect;
  final VoidCallback? onCreateNew;
  final Offset position;

  const LinkAutocomplete({
    super.key,
    required this.query,
    required this.suggestions,
    required this.onSelect,
    required this.position,
    this.onCreateNew,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 300,
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (suggestions.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No notes found',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                if (onCreateNew != null)
                  ListTile(
                    leading: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text('Create "$query"'),
                    onTap: onCreateNew,
                  ),
              ] else ...[
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: suggestions.length + (onCreateNew != null ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (onCreateNew != null && index == suggestions.length) {
                        return ListTile(
                          leading: Icon(
                            Icons.add,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: Text('Create "$query"'),
                          onTap: onCreateNew,
                        );
                      }
                      
                      final note = suggestions[index];
                      return ListTile(
                        leading: const Icon(Icons.note),
                        title: Text(
                          note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: note.contentPlain.isNotEmpty
                            ? Text(
                                note.contentPlain,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        onTap: () => onSelect(note),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Show autocomplete overlay
  static OverlayEntry show({
    required BuildContext context,
    required String query,
    required List<Note> suggestions,
    required ValueChanged<Note> onSelect,
    VoidCallback? onCreateNew,
    Offset? position,
  }) {
    final overlay = OverlayEntry(
      builder: (context) => LinkAutocomplete(
        query: query,
        suggestions: suggestions,
        onSelect: onSelect,
        onCreateNew: onCreateNew,
        position: position ?? const Offset(20, 100),
      ),
    );
    
    Overlay.of(context).insert(overlay);
    return overlay;
  }
}
