import 'dart:convert';

/// v372-compatible Collection mutations. No unrelated MediaFlow field is removed.
/// The v372 merge contract compares updatedAt and collectionTombstones.deletedAt.
/// A collection's titleIds and order must both reflect the chosen sequence.
abstract final class CollectionMutations {
  static Map<String, dynamic> create(String id, String title, {String description = '',
    String coverUrl = '', List<String> titleIds = const []}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final ids = titleIds.toSet().toList();
    return {'id': id, 'title': title.trim(), 'description': description,
      'coverUrl': coverUrl.trim(), 'titleIds': ids, 'order': List<String>.from(ids),
      'autoBackground': true, 'createdAt': now, 'updatedAt': now,
      'lastViewedAt': 0};
  }

  static Map<String, dynamic> revise(Map<String, dynamic> old, {
    String? title, String? description, String? coverUrl, List<String>? titleIds,
  }) {
    final updated = Map<String, dynamic>.from(old);
    if (title != null) updated['title'] = title.trim();
    if (description != null) updated['description'] = description;
    if (coverUrl != null) updated['coverUrl'] = coverUrl.trim();
    if (titleIds != null) {
      final ids = titleIds.where((id) => id.isNotEmpty).toSet().toList();
      updated['titleIds'] = ids;
      updated['order'] = List<String>.from(ids);
    }
    updated['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
    return updated;
  }

  /// Applies one proposed change on the complete snapshot (without throwing
  /// away unknown user fields or unrelated Collections). A null value deletes.
  static void apply(Map<String, dynamic> state, String id,
      Map<String, dynamic>? change) {
    final collections = state['collections'];
    if (collections is! List) throw StateError('Collections are unavailable');
    final at = collections.indexWhere((c) => c is Map && c['id'].toString() == id);
    if (change == null) {
      if (at >= 0) collections.removeAt(at);
      final existing = state['collectionTombstones'];
      final tombstones = existing is List ? existing : <dynamic>[];
      final deletedAt = DateTime.now().millisecondsSinceEpoch;
      final index = tombstones.indexWhere((t) => t is Map && t['id'].toString() == id);
      if (index >= 0) {
        final prior = tombstones[index] is Map ? tombstones[index] as Map : {};
        final timestamp = prior['deletedAt'] is num ? prior['deletedAt'] as num : 0;
        tombstones[index] = {'id': id, 'deletedAt': deletedAt > timestamp ? deletedAt : timestamp};
      } else {
        tombstones.add({'id': id, 'deletedAt': deletedAt});
      }
      state['collectionTombstones'] = tombstones;
    } else if (at >= 0) {
      collections[at] = Map<String, dynamic>.from(change);
    } else {
      collections.add(Map<String, dynamic>.from(change));
    }
  }

  static Map<String, dynamic>? collectionById(Map<String, dynamic> state, String id) {
    final collections = state['collections'];
    if (collections is! List) return null;
    for (final raw in collections) {
      if (raw is Map && raw['id'].toString() == id) {
        return Map<String, dynamic>.from(raw);
      }
    }
    return null;
  }

  /// Null baseline means a newly created collection. For existing Collections
  /// the entire object must match the original snapshot before a cloud upload.
  /// Rejecting instead of silently merging prevents lost order/membership edits.
  static void verifyBaseline(Map<String, dynamic> remote, String id,
      Map<String, dynamic>? baseline) {
    final current = collectionById(remote, id);
    if (baseline == null) {
      if (current != null) throw StateError('A Collection with this ID now exists in the cloud. Upload stopped.');
      final tomb = remote['collectionTombstones'];
      if (tomb is List && tomb.any((v) => v is Map && v['id'].toString() == id)) {
        throw StateError('This Collection was deleted remotely. Upload stopped.');
      }
    } else if (jsonEncode(current) != jsonEncode(baseline)) {
      throw StateError('Collection was changed on the website or another device. Upload stopped.');
    }
  }
}
