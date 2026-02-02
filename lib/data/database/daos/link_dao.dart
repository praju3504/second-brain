import 'package:drift/drift.dart';
import 'package:second_brain/data/database/app_database.dart';
import 'package:second_brain/data/database/tables/links_table.dart';
import 'package:second_brain/data/database/tables/entities_table.dart';
import 'package:second_brain/domain/enums/link_type.dart';

part 'link_dao.g.dart';

@DriftAccessor(tables: [Links, Entities])
class LinkDao extends DatabaseAccessor<AppDatabase> with _$LinkDaoMixin {
  LinkDao(AppDatabase db) : super(db);

  /// Get all outgoing links from a note
  Future<List<LinkData>> getAllLinksFromNote(String noteId) async {
    return (select(links)..where((l) => l.sourceId.equals(noteId))).get();
  }

  /// Get all incoming links to a note (backlinks)
  Future<List<LinkData>> getAllLinksToNote(String noteId) async {
    return (select(links)..where((l) => l.targetId.equals(noteId))).get();
  }

  /// Insert a new link
  Future<void> insertLink(LinksCompanion link) async {
    await into(links).insert(link, mode: InsertMode.insertOrReplace);
  }

  /// Delete a specific link
  Future<void> deleteLink(String id) async {
    await (delete(links)..where((l) => l.id.equals(id))).go();
  }

  /// Delete all links from a note
  Future<void> deleteLinksFromNote(String noteId) async {
    await (delete(links)..where((l) => l.sourceId.equals(noteId))).go();
  }

  /// Search for potential link targets by query
  Future<List<EntityData>> searchLinkTargets(String query) async {
    final searchQuery = select(entities)
      ..where((e) => 
        e.title.like('%$query%') & 
        e.deletedAt.isNull())
      ..limit(10);
    
    return searchQuery.get();
  }

  /// Get link graph for a note (for future graph view)
  Future<Map<String, List<LinkData>>> getLinkGraph(String noteId, {int depth = 1}) async {
    final graph = <String, List<LinkData>>{};
    final visited = <String>{};
    
    await _buildGraphRecursive(noteId, depth, visited, graph);
    
    return graph;
  }

  Future<void> _buildGraphRecursive(
    String noteId,
    int depth,
    Set<String> visited,
    Map<String, List<LinkData>> graph,
  ) async {
    if (depth <= 0 || visited.contains(noteId)) return;
    
    visited.add(noteId);
    
    final outgoingLinks = await getAllLinksFromNote(noteId);
    graph[noteId] = outgoingLinks;
    
    if (depth > 1) {
      for (final link in outgoingLinks) {
        await _buildGraphRecursive(link.targetId, depth - 1, visited, graph);
      }
    }
  }

  /// Get count of backlinks for a note
  Future<int> getBacklinkCount(String noteId) async {
    final query = selectOnly(links)
      ..addColumns([links.id.count()])
      ..where(links.targetId.equals(noteId));
    
    final result = await query.getSingle();
    return result.read(links.id.count()) ?? 0;
  }

  /// Get count of outgoing links for a note
  Future<int> getOutgoingLinkCount(String noteId) async {
    final query = selectOnly(links)
      ..addColumns([links.id.count()])
      ..where(links.sourceId.equals(noteId));
    
    final result = await query.getSingle();
    return result.read(links.id.count()) ?? 0;
  }

  /// Batch insert links
  Future<void> insertLinks(List<LinksCompanion> linksList) async {
    await batch((batch) {
      batch.insertAll(links, linksList, mode: InsertMode.insertOrReplace);
    });
  }
}
