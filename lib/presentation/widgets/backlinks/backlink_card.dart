import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:second_brain/core/extensions/date_extensions.dart';
import 'package:second_brain/core/services/link_service.dart';

/// Card displaying a single backlink
class BacklinkCard extends StatelessWidget {
  final BacklinkInfo backlink;

  const BacklinkCard({
    super.key,
    required this.backlink,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/notes/${backlink.sourceNote.id}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    backlink.sourceNote.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (backlink.mentionCount > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${backlink.mentionCount}x',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Context preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Text(
                backlink.context,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Date
            Text(
              backlink.sourceNote.updatedAt.toDateTime().toRelativeTime(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
