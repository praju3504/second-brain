import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:second_brain/core/services/link_service.dart';
import 'package:second_brain/core/utils/wiki_link_parser.dart';
import 'package:second_brain/data/database/daos/link_dao.dart';
import 'package:second_brain/domain/entities/note.dart';
import 'package:second_brain/presentation/providers/database_provider.dart';
import 'package:second_brain/presentation/providers/notes_provider.dart';

/// Provider for link service
final linkServiceProvider = Provider<LinkService>((ref) {
  final database = ref.watch(databaseProvider);
  final linkDao = LinkDao(database);
  return LinkService(linkDao);
});

/// Provider for outgoing links from a note
final noteLinksProvider = FutureProvider.family<List<WikiLink>, String>((ref, noteId) async {
  final repository = ref.watch(noteRepositoryProvider);
  final note = await repository.getNoteById(noteId);
  
  if (note == null) return [];
  
  final linkService = ref.watch(linkServiceProvider);
  return linkService.extractLinksFromContent(note.contentPlain);
});

/// Provider for backlinks to a note
final backlinksProvider = FutureProvider.family<List<BacklinkInfo>, String>((ref, noteId) async {
  final linkService = ref.watch(linkServiceProvider);
  final notesAsync = ref.watch(notesProvider);
  
  final notes = notesAsync.when(
    data: (data) => data,
    loading: () => <Note>[],
    error: (_, __) => <Note>[],
  );
  
  return await linkService.getBacklinks(noteId, notes);
});

/// Provider for link suggestions (autocomplete)
final linkSuggestionsProvider = FutureProvider.family<List<Note>, String>((ref, query) async {
  final linkService = ref.watch(linkServiceProvider);
  final notesAsync = ref.watch(notesProvider);
  
  final notes = notesAsync.when(
    data: (data) => data,
    loading: () => <Note>[],
    error: (_, __) => <Note>[],
  );
  
  return await linkService.getSuggestionsForQuery(query, notes);
});

/// Provider for backlink count
final backlinkCountProvider = FutureProvider.family<int, String>((ref, noteId) async {
  final linkService = ref.watch(linkServiceProvider);
  return await linkService.getBacklinkCount(noteId);
});

/// Provider for outgoing link count
final outgoingLinkCountProvider = FutureProvider.family<int, String>((ref, noteId) async {
  final linkService = ref.watch(linkServiceProvider);
  return await linkService.getOutgoingLinkCount(noteId);
});

/// State for managing link operations
class LinksState {
  final bool isLoading;
  final String? error;
  
  const LinksState({
    this.isLoading = false,
    this.error,
  });

  LinksState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return LinksState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// StateNotifier for managing link operations
class LinksNotifier extends StateNotifier<LinksState> {
  final LinkService _linkService;
  final Ref _ref;

  LinksNotifier(this._linkService, this._ref) : super(const LinksState());

  /// Sync links for a note
  Future<void> syncLinks(String noteId, String content) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final notesAsync = _ref.read(notesProvider);
      final notes = notesAsync.when(
        data: (data) => data,
        loading: () => <Note>[],
        error: (_, __) => <Note>[],
      );
      
      await _linkService.syncLinksForNote(noteId, content, notes);
      
      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refresh all link-related providers for a note
  void refreshLinksForNote(String noteId) {
    _ref.invalidate(noteLinksProvider(noteId));
    _ref.invalidate(backlinksProvider(noteId));
    _ref.invalidate(backlinkCountProvider(noteId));
    _ref.invalidate(outgoingLinkCountProvider(noteId));
  }
}

/// Provider for links notifier
final linksNotifierProvider = StateNotifierProvider<LinksNotifier, LinksState>((ref) {
  final linkService = ref.watch(linkServiceProvider);
  return LinksNotifier(linkService, ref);
});
