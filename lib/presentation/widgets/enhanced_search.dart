import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:second_brain/domain/entities/note.dart';
import 'package:second_brain/presentation/providers/notes_provider.dart';

/// Enhanced search widget with link-aware features
class EnhancedSearch extends ConsumerStatefulWidget {
  final ValueChanged<List<Note>> onResults;

  const EnhancedSearch({
    super.key,
    required this.onResults,
  });

  @override
  ConsumerState<EnhancedSearch> createState() => _EnhancedSearchState();
}

class _EnhancedSearchState extends ConsumerState<EnhancedSearch> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  SearchFilter _selectedFilter = SearchFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    setState(() => _searchQuery = query);
    
    if (query.isEmpty) {
      // Show all notes if search is empty
      final notesAsync = ref.read(notesProvider);
      notesAsync.when(
        data: (notes) => widget.onResults(notes),
        loading: () => widget.onResults([]),
        error: (_, __) => widget.onResults([]),
      );
      return;
    }
    
    // Perform search based on filter
    ref.read(notesProvider.notifier).searchNotes(query);
    
    final notesAsync = ref.read(notesProvider);
    notesAsync.when(
      data: (notes) {
        final filtered = _applyFilter(notes);
        widget.onResults(filtered);
      },
      loading: () => widget.onResults([]),
      error: (_, __) => widget.onResults([]),
    );
  }

  List<Note> _applyFilter(List<Note> notes) {
    switch (_selectedFilter) {
      case SearchFilter.all:
        return notes;
      case SearchFilter.withLinks:
        // Filter notes that contain wiki links
        return notes.where((note) => note.contentPlain.contains('[[')).toList();
      case SearchFilter.withoutLinks:
        // Filter notes that don't contain wiki links
        return notes.where((note) => !note.contentPlain.contains('[[')).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search notes, content, or links...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (_) => _performSearch(),
              ),
              
              const SizedBox(height: 8),
              
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: SearchFilter.values.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_getFilterLabel(filter)),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedFilter = filter);
                            _performSearch();
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getFilterLabel(SearchFilter filter) {
    switch (filter) {
      case SearchFilter.all:
        return 'All';
      case SearchFilter.withLinks:
        return 'Has Links';
      case SearchFilter.withoutLinks:
        return 'No Links';
    }
  }
}

enum SearchFilter {
  all,
  withLinks,
  withoutLinks,
}
