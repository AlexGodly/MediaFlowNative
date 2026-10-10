import 'dart:convert';

/// Browser v372 stores Personal Order directly under snapshot.orderPlan.
/// Preserve all unknown properties (including collectionAssignments and
/// categoryQueues) when changing the direct-title sequence.
abstract final class OrderMutations {
  static Map<String, dynamic> changeDirectTitles(
    Map<String, dynamic> previous, List<String> ids, Set<String> validIds, {
    int? modifiedAt,
  }) {
    final seen = <String>{};
    final cleaned = <String>[];
    for (final id in ids) {
      if (id.isEmpty || !validIds.contains(id)) {
        throw StateError('Cannot order a missing Library title: $id');
      }
      if (seen.add(id)) cleaned.add(id);
    }
    final next = Map<String, dynamic>.from(previous);
    next['titleIds'] = cleaned;
    next['modifiedAt'] = modifiedAt ?? DateTime.now().millisecondsSinceEpoch;
    return next;
  }

  static void validateRemote(Map<String, dynamic> remote,
      Map<String, dynamic> original) {
    final current = remote['orderPlan'];
    if (current is! Map || jsonEncode(current) != jsonEncode(original)) {
      throw StateError('Personal Order changed on the website or another device. Nothing was uploaded. Refresh and reconcile your changes.');
    }
  }

  static void apply(Map<String, dynamic> target, Map<String, dynamic> next) {
    if (target['library'] is! List) {
      throw StateError('Library is unavailable: Personal Order cannot be updated');
    }
    final validIds = (target['library'] as List)
        .whereType<Map>()
        .map((entry) => entry['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
    final ids = next['titleIds'];
    if (ids is! List) throw StateError('Personal Order titleIds missing');
    final updated = changeDirectTitles(
      next,
      ids.map((value) => value.toString()).toList(),
      validIds,
      modifiedAt: next['modifiedAt'] is num
          ? (next['modifiedAt'] as num).toInt()
          : DateTime.now().millisecondsSinceEpoch,
    );
    target['orderPlan'] = updated;
  }
}
