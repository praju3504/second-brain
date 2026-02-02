import 'package:drift/drift.dart';
import 'package:second_brain/core/extensions/date_extensions.dart';
import 'package:second_brain/core/utils/uuid_generator.dart';
import 'package:second_brain/core/utils/wiki_link_parser.dart';
import 'package:second_brain/data/database/app_database.dart';
import 'package:second_brain/data/database/daos/link_dao.dart';
import 'package:second_brain/domain/entities/note.dart';
import 'package:second_brain/domain/enums/link_type.dart';

/// Information about a backlink
class BacklinkInfo {
  final Note sourceNote;
  final String context;
  final int mentionCount;

  const BacklinkInfo({
    required this.sourceNote,
    required this.context,
    this.mentionCount = 1,
  });
}

/// Service for managing links between notes
class LinkService {
  final LinkDao _linkDao;

  LinkService(this._linkDao);

  /// Extract links from content and return list of WikiLinks
  List<WikiLink> extractLinksFromContent(String content) {
    return WikiLinkParser.parseLinks(content);
  }

  /// Sync links for a note - parse content and save to database
  Future<void> syncLinksForNote(String noteId, String content, List<Note> allNotes) async {
    // Delete existing links from this note
    await _linkDao.deleteLinksFromNote(noteId);

    // Extract new links
    final wikiLinks = extractLinksFromContent(content);
    if (wikiLinks.isEmpty) return;

    // Create link entries
    final linksToInsert = <LinksCompanion>[];
    
    for (final wikiLink in wikiLinks) {
      // Try to resolve the target note
      final targetNote = _resolveTargetNote(wikiLink.target, allNotes);
      
      if (targetNote != null) {
        final context = WikiLinkParser.getContext(content, wikiLink);
        
        linksToInsert.add(LinksCompanion.insert(
          id: UuidGenerator.generate(),
          sourceId: noteId,
          targetId: targetNote.id,
          linkType: LinkType.reference.name,
          linkText: Value(wikiLink.displayText),
          context: Value(context),
          position: wikiLink.startIndex,
          createdAt: DateTime.now().toTimestamp(),
        ));
      }
    }

    // Batch insert links
    if (linksToInsert.isNotEmpty) {
      await _linkDao.insertLinks(linksToInsert);
    }
  }

  /// Resolve a link target to a note
  Note? _resolveTargetNote(String linkTarget, List<Note> allNotes) {
    // Try exact match first
    final exactMatch = allNotes.where((n) => 
      n.title.toLowerCase() == linkTarget.toLowerCase()
    ).firstOrNull;
    
    if (exactMatch != null) return exactMatch;

    // Try partial match
    return allNotes.where((n) => 
      n.title.toLowerCase().contains(linkTarget.toLowerCase())
    ).firstOrNull;
  }

  /// Resolve link target by title
  Future<Note?> resolveLink(String linkTarget, List<Note> allNotes) async {
    return _resolveTargetNote(linkTarget, allNotes);
  }

  /// Get backlinks for a note with context
  Future<List<BacklinkInfo>> getBacklinks(String noteId, List<Note> allNotes) async {
    final linkDataList = await _linkDao.getAllLinksToNote(noteId);
    
    final backlinks = <BacklinkInfo>[];
    
    // Group by source note
    final groupedBySource = <String, List<LinkData>>{};
    for (final linkData in linkDataList) {
      groupedBySource.putIfAbsent(linkData.sourceId, () => []).add(linkData);
    }

    // Create BacklinkInfo for each source note
    for (final entry in groupedBySource.entries) {
      final sourceNote = allNotes.where((n) => n.id == entry.key).firstOrNull;
      if (sourceNote == null) continue;

      final mentions = entry.value;
      final context = mentions.first.context ?? '';

      backlinks.add(BacklinkInfo(
        sourceNote: sourceNote,
        context: context,
        mentionCount: mentions.length,
      ));
    }

    return backlinks;
  }

  /// Get suggestions for autocomplete
  Future<List<Note>> getSuggestionsForQuery(String query, List<Note> allNotes) async {
    if (query.isEmpty) return allNotes.take(10).toList();

    return allNotes
        .where((n) => n.title.toLowerCase().contains(query.toLowerCase()))
        .take(10)
        .toList();
  }

  /// Create a new note from a link target
  Future<Note> createNoteFromLink(String linkTarget) async {
    final now = DateTime.now().toTimestamp();
    return Note(
      id: UuidGenerator.generate(),
      title: linkTarget,
      contentJson: '',
      contentPlain: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Get backlink count for a note
  Future<int> getBacklinkCount(String noteId) async {
    return await _linkDao.getBacklinkCount(noteId);
  }

  /// Get outgoing link count for a note
  Future<int> getOutgoingLinkCount(String noteId) async {
    return await _linkDao.getOutgoingLinkCount(noteId);
  }
}
