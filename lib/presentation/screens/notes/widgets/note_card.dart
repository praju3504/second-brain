import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:second_brain/core/extensions/date_extensions.dart';
import 'package:second_brain/domain/entities/note.dart';
import 'package:second_brain/presentation/providers/links_provider.dart';

class NoteCard extends ConsumerWidget {
  final Note note;
  
  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backlinkCountAsync = ref.watch(backlinkCountProvider(note.id));
    
    return Card(
      child: InkWell(
        onTap: () => context.push('/notes/${note.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Link badges
                  if (note.hasOutgoingLinks) ...[
                    const SizedBox(width: 8),
                    _buildLinkBadge(
                      context,
                      Icons.link,
                      note.outgoingLinks.length,
                      'Outgoing links',
                    ),
                  ],
                  backlinkCountAsync.when(
                    data: (count) {
                      if (count > 0) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _buildLinkBadge(
                            context,
                            Icons.arrow_back,
                            count,
                            'Backlinks',
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  note.contentPlain,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                note.updatedAt.toDateTime().toRelativeTime(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkBadge(BuildContext context, IconData icon, int count, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
