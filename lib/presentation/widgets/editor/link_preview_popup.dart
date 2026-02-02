import 'package:flutter/material.dart';
import 'package:second_brain/core/extensions/date_extensions.dart';
import 'package:second_brain/domain/entities/note.dart';

/// Popup for previewing a linked note
class LinkPreviewPopup extends StatelessWidget {
  final Note note;
  final VoidCallback? onOpen;
  final Offset position;

  const LinkPreviewPopup({
    super.key,
    required this.note,
    required this.position,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 200),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: child,
            ),
          );
        },
        child: Material(
          elevation: 16,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 300,
            constraints: const BoxConstraints(maxHeight: 400),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.note,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              note.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created ${note.createdAt.toDateTime().toRelativeTime()}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content preview
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      note.contentPlain.isEmpty
                          ? 'No content'
                          : note.contentPlain.length > 200
                              ? '${note.contentPlain.substring(0, 200)}...'
                              : note.contentPlain,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                
                // Actions
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: onOpen,
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('Open'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show the preview popup
  static OverlayEntry show({
    required BuildContext context,
    required Note note,
    VoidCallback? onOpen,
    Offset? position,
  }) {
    final overlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Dismiss on tap outside
          Positioned.fill(
            child: GestureDetector(
              onTap: () => overlay.remove(),
              behavior: HitTestBehavior.translucent,
            ),
          ),
          LinkPreviewPopup(
            note: note,
            position: position ?? const Offset(50, 100),
            onOpen: onOpen,
          ),
        ],
      ),
    );
    
    Overlay.of(context).insert(overlay);
    return overlay;
  }
}
