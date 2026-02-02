import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:second_brain/core/extensions/date_extensions.dart';
import 'package:second_brain/presentation/providers/notes_provider.dart';
import 'package:second_brain/presentation/widgets/empty_state.dart';

class RecentNotesWidget extends ConsumerWidget {
  const RecentNotesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesState = ref.watch(notesProvider);
    
    return notesState.when(
      data: (notes) {
        if (notes.isEmpty) {
          return const SizedBox(
            height: 120,
            child: EmptyState(
              icon: Icons.note_outlined,
              title: 'No notes yet',
              subtitle: 'Create your first note',
            ),
          );
        }
        
        final recentNotes = notes.take(5).toList();
        
        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recentNotes.length,
            itemBuilder: (context, index) {
              final note = recentNotes[index];
              return GestureDetector(
                onTap: () => context.push('/notes/${note.id}'),
                child: Card(
                  margin: const EdgeInsets.only(right: 12),
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Text(
                          note.updatedAt.toDateTime().toRelativeTime(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => SizedBox(
        height: 120,
        child: Center(child: Text('Error: $error')),
      ),
    );
  }
}
