import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:second_brain/presentation/providers/notes_provider.dart';
import 'package:second_brain/presentation/screens/notes/widgets/note_card.dart';
import 'package:second_brain/presentation/widgets/app_bottom_nav.dart';
import 'package:second_brain/presentation/widgets/custom_search_bar.dart';
import 'package:second_brain/presentation/widgets/empty_state.dart';
import 'package:second_brain/presentation/widgets/loading_indicator.dart';

class NotesListScreen extends ConsumerStatefulWidget {
  const NotesListScreen({super.key});

  @override
  ConsumerState<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends ConsumerState<NotesListScreen> {
  bool _isSearching = false;
  
  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  ref.read(notesProvider.notifier).loadNotes();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomSearchBar(
                hintText: 'Search notes...',
                onSearch: (query) {
                  if (query.isNotEmpty) {
                    ref.read(notesProvider.notifier).searchNotes(query);
                  } else {
                    ref.read(notesProvider.notifier).loadNotes();
                  }
                },
              ),
            ),
          Expanded(
            child: notesState.when(
              data: (notes) {
                if (notes.isEmpty) {
                  return const EmptyState(
                    icon: Icons.note_outlined,
                    title: 'No notes yet',
                    subtitle: 'Tap + to create your first note',
                  );
                }
                
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    return NoteCard(note: notes[index]);
                  },
                );
              },
              loading: () => const LoadingIndicator(),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              break;
            case 2:
              context.go('/tasks');
              break;
            case 3:
              context.go('/files');
              break;
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/notes/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
