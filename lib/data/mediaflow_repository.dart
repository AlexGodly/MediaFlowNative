import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'mediaflow_snapshot.dart';
import 'models.dart';
import 'collection_mutations.dart';
import 'order_mutations.dart';

Map<String, dynamic> _unpack(dynamic input) =>
    MediaFlowSnapshotCodec.decodeCloud(input);
List<int> _packLocal(Map<String, dynamic> input) =>
    MediaFlowSnapshotCodec.encodeLocal(input);
Map<String, dynamic> _unpackLocal(List<int> input) =>
    MediaFlowSnapshotCodec.decodeLocal(input);
Map<String, dynamic> _packCloud(Map<String, dynamic> input) =>
    MediaFlowSnapshotCodec.encodeCloud(input);

/// Native app adapter for the v372 Supabase snapshot. IMPORTANT:
/// Cloud saves use a conditional PostgREST update against updated_at and only
/// apply explicitly edited metadata fields onto a fresh server-side snapshot.
/// This protects web-only fields and prevents overwriting a newer saved row.
/// It does NOT port MediaFlow's XP/logging/collection mutation logic.
class MediaFlowRepository extends ChangeNotifier {
  final SupabaseClient client;
  MediaFlowRepository(this.client);

  Map<String, dynamic> _state = {};
  MediaWorkspace? _viewCache;
  Map<String, Map<String, dynamic>> _pendingMetadata = {};
  Map<String, Map<String, dynamic>> _originalFields = {};
  final Map<String, Map<String, dynamic>?> _pendingCollections = {};
  final Map<String, Map<String, dynamic>?> _originalCollections = {};
  int get pendingCollectionCount => _pendingCollections.length;
  Map<String, dynamic>? _pendingOrderPlan;
  Map<String, dynamic>? _originalOrderPlan;
  bool get pendingOrderChanges => _pendingOrderPlan != null;

  bool busy = false;
  bool cached = false;
  bool cloudConnected = false;
  bool hasCloudRow = false;
  String? updatedAt;
  String? error;
  String? _ownerId;

  MediaWorkspace get workspace => _viewCache ??= MediaWorkspace(_state);
  int get pendingCount => _pendingMetadata.length + _pendingCollections.length + (_pendingOrderPlan != null ? 1 : 0);
  bool get hasData => _state.isNotEmpty;

  String get ownerId => _ownerId ?? client.auth.currentUser?.id ?? '';

  Future<Directory> get _cacheFolder async {
    final dir = await getApplicationSupportDirectory();
    final folder = Directory('${dir.path}${Platform.pathSeparator}mediaflow-native');
    await folder.create(recursive: true);
    return folder;
  }

  Future<File> _snapshotFile(String uid) async {
    final folder = await _cacheFolder;
    return File('${folder.path}${Platform.pathSeparator}snapshot-$uid.json.gz');
  }

  Future<File> _pendingFile(String uid) async {
    final folder = await _cacheFolder;
    return File('${folder.path}${Platform.pathSeparator}metadata-$uid.json');
  }

  Future<void> initialize(String uid) async {
    _ownerId = uid;
    _state = {};
    _viewCache = null;
    _pendingMetadata = {};
    _originalFields = {};
    _pendingCollections.clear();
    _originalCollections.clear();
    _pendingOrderPlan = null;
    _originalOrderPlan = null;
    error = null;
    cloudConnected = false;
    cached = false;
    hasCloudRow = false;
    updatedAt = null;
    notifyListeners();
    try {
      final file = await _snapshotFile(uid);
      if (await file.exists()) {
        _state = await compute(_unpackLocal, await file.readAsBytes());
        _viewCache = null;
        cached = true;
      }
      final staged = await _pendingFile(uid);
      if (await staged.exists()) {
        final value = jsonDecode(await staged.readAsString());
        if (value is Map) {
          final edits = value['edits'] is Map ? value['edits'] as Map : value;
          final baselines = value['baselines'];
          for (final entry in edits.entries) {
            if (entry.value is Map) {
              _pendingMetadata[entry.key.toString()] =
                  Map<String, dynamic>.from(entry.value as Map);
            }
          }
          if (baselines is Map) {
            for (final entry in baselines.entries) {
              if (entry.value is Map) {
                _originalFields[entry.key.toString()] =
                    Map<String, dynamic>.from(entry.value as Map);
              }
            }
          }
          final collectionChanges = value['collectionChanges'];
          final collectionBaselines = value['collectionBaselines'];
          if (collectionChanges is Map) {
            for (final entry in collectionChanges.entries) {
              _pendingCollections[entry.key.toString()] = entry.value is Map
                  ? Map<String, dynamic>.from(entry.value as Map) : null;
            }
          }
          if (collectionBaselines is Map) {
            for (final entry in collectionBaselines.entries) {
              _originalCollections[entry.key.toString()] = entry.value is Map
                  ? Map<String, dynamic>.from(entry.value as Map) : null;
            }
          }
          final orderEdit = value['orderPlanChange'];
          final orderBase = value['orderPlanBaseline'];
          if (orderEdit is Map && orderBase is Map) {
            _pendingOrderPlan = Map<String, dynamic>.from(orderEdit);
            _originalOrderPlan = Map<String, dynamic>.from(orderBase);
          }
          _applyPending(_state);
        }
      }
    } catch (e) {
      error = 'Could not read the local cache: $e';
    }
    notifyListeners();
    await refresh();
  }

  Future<void> refresh() async {
    if (ownerId.isEmpty || busy) return;
    busy = true;
    error = null;
    notifyListeners();
    try {
      final row = await client.from('mediaflow_states')
          .select('state_data,updated_at')
          .eq('user_id', ownerId)
          .maybeSingle();
      if (row == null) {
        hasCloudRow = false;
        cloudConnected = true;
        if (_state.isEmpty) error = 'This account has no MediaFlow cloud snapshot yet. Open the website to initialize it.';
      } else {
        final decoded = await compute(_unpack, row['state_data']);
        if (!decoded.containsKey('library') || decoded['library'] is! List) {
          throw const FormatException('Unexpected MediaFlow cloud format; no data was replaced.');
        }
        // Preserve staged local metadata; base for future writes is always refetched.
        _state = decoded;
        _viewCache = null;
        _applyPending(_state);
        updatedAt = row['updated_at']?.toString();
        hasCloudRow = true;
        cloudConnected = true;
        cached = false;
        await _saveLocalSnapshot();
      }
    } catch (e) {
      cloudConnected = false;
      error = 'Cloud refresh unavailable. Your existing local copy is retained. $e';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void _applyPending(Map<String, dynamic> target) {
    final library = target['library'];
    if (library is List) {
      for (final record in library) {
        if (record is! Map) continue;
        final patch = _pendingMetadata[plain(record['id'])];
        if (patch != null) record.addAll(patch);
      }
    }
    for (final change in _pendingCollections.entries) {
      CollectionMutations.apply(target, change.key, change.value);
    }
    if (_pendingOrderPlan != null) {
      OrderMutations.apply(target, _pendingOrderPlan!);
    }
  }

  Future<void> _saveLocalSnapshot() async {
    if (ownerId.isEmpty || _state.isEmpty) return;
    final destination = await _snapshotFile(ownerId);
    final temporary = File('${destination.path}.tmp');
    await temporary.writeAsBytes(await compute(_packLocal, _state), flush: true);
    if (await destination.exists()) await destination.delete();
    await temporary.rename(destination.path);
  }

  Future<void> _savePending() async {
    final file = await _pendingFile(ownerId);
    await file.writeAsString(jsonEncode({'edits': _pendingMetadata, 'baselines': _originalFields, 'collectionChanges': _pendingCollections, 'collectionBaselines': _originalCollections, 'orderPlanChange': _pendingOrderPlan, 'orderPlanBaseline': _originalOrderPlan}), flush: true);
  }

  /// Safe subset: cover, priority, tags, description, rating. Excludes progress,
  /// status, add/delete and logging, which require canonical web XP/History rules.
  Future<void> stageTitleMetadata(String titleId, {
    String? coverUrl,
    String? priority,
    List<String>? tags,
    String? description,
    double? rating,
  }) async {
    final patch = <String, dynamic>{};
    if (coverUrl != null) patch['coverUrl'] = coverUrl.trim();
    if (priority != null && ['low','medium','high'].contains(priority)) {
      patch['priority'] = priority;
    }
    if (tags != null) patch['tags'] = tags;
    if (description != null) patch['description'] = description;
    if (rating != null) {
      if (!rating.isFinite || rating < 0 || rating > 10) {
        throw ArgumentError.value(rating, 'rating', 'Rating must be from 0 to 10');
      }
      patch['rating'] = rating;
    }
    if (patch.isEmpty) return;
    final all = workspace.titles;
    if (!all.any((t) => t.id == titleId)) throw StateError('Title no longer exists');
    final record = (_state['library'] as List).cast<Map>().firstWhere(
      (x) => plain(x['id']) == titleId);
    final original = _originalFields.putIfAbsent(titleId, () => {});
    for (final field in patch.keys) {
      original.putIfAbsent(field, () => record[field]);
    }
    _pendingMetadata.putIfAbsent(titleId, () => {}).addAll(patch);
    _applyPending(_state);
    _viewCache = null;
    notifyListeners();
    await _savePending();
    await _saveLocalSnapshot();
  }

  /// Efficient guarded batch priority change. Capture one baseline for every
  /// changed title, then persist staged edits and snapshot once per batch.
  /// Upload later rebases patches on a freshly loaded snapshot and rejects
  /// concurrent edits without changing canonical logging/XP or History.
  Future<int> stageBulkPriority(Iterable<String> ids, String priority) async {
    if (!const {'low', 'medium', 'high'}.contains(priority)) {
      throw ArgumentError.value(priority, 'priority', 'Unsupported priority');
    }
    final library = _state['library'];
    if (library is! List) throw StateError('Library is not available');
    final requested = ids.toSet();
    if (requested.isEmpty) return 0;
    final records = <String, Map>{};
    for (final raw in library) {
      if (raw is! Map) continue;
      final id = plain(raw['id']);
      if (requested.contains(id)) records[id] = raw;
    }
    if (records.length != requested.length) {
      throw StateError('Some selected Library titles were removed. Nothing was changed.');
    }
    var count = 0;
    for (final entry in records.entries) {
      if (plain(entry.value['priority'], 'medium') == priority) continue;
      final baseline = _originalFields.putIfAbsent(entry.key, () => {});
      baseline.putIfAbsent('priority', () => entry.value['priority']);
      _pendingMetadata.putIfAbsent(entry.key, () => {})['priority'] = priority;
      entry.value['priority'] = priority;
      count++;
    }
    if (count > 0) {
      _viewCache = null;
      notifyListeners();
      await _savePending();
      await _saveLocalSnapshot();
    }
    return count;
  }

  /// v372-compatible native Collections CRUD. Changes are local until the user
  /// chooses Upload. The original complete Collection object is remembered so
  /// concurrent cloud edits cannot be silently overwritten.
  Future<void> stageCollection(Map<String, dynamic> collection) async {
    final id = plain(collection['id']);
    if (id.isEmpty || plain(collection['title']).trim().isEmpty) {
      throw StateError('Collection ID and name are required');
    }
    if (!_originalCollections.containsKey(id)) {
      _originalCollections[id] = CollectionMutations.collectionById(_state, id);
    }
    _pendingCollections[id] = Map<String, dynamic>.from(collection);
    CollectionMutations.apply(_state, id, collection);
    _viewCache = null;
    notifyListeners();
    await _savePending();
    await _saveLocalSnapshot();
  }

  Future<void> stageCollectionDelete(String id) async {
    final original = CollectionMutations.collectionById(_state, id);
    if (original == null) return;
    if (!_originalCollections.containsKey(id)) _originalCollections[id] = original;
    if (_originalCollections[id] == null) {
      // Delete a Collection created only on this device; nothing to sync.
      _pendingCollections.remove(id);
      _originalCollections.remove(id);
    } else {
      _pendingCollections[id] = null;
    }
    CollectionMutations.apply(_state, id, null);
    _viewCache = null;
    notifyListeners();
    await _savePending();
    await _saveLocalSnapshot();
  }

  /// Native direct Personal Order editor. Does not overwrite category queue,
  /// assigned-Collection, or future Personal Order metadata.
  Future<void> stageDirectOrder(List<String> ids) async {
    if (_state['orderPlan'] is! Map || _state['library'] is! List) {
      throw StateError('Your Personal Order or Library is unavailable');
    }
    final liveIds = workspace.titles.map((t) => t.id).toSet();
    if (_originalOrderPlan == null) {
      _originalOrderPlan = Map<String, dynamic>.from(_state['orderPlan'] as Map);
    }
    final next = OrderMutations.changeDirectTitles(
      Map<String, dynamic>.from(_state['orderPlan'] as Map), ids, liveIds);
    _pendingOrderPlan = next;
    OrderMutations.apply(_state, next);
    _viewCache = null;
    notifyListeners();
    await _savePending();
    await _saveLocalSnapshot();
  }

  /// Conditional update: if the website or another device changed the cloud
  /// row between read and write, Supabase updates zero rows and we keep edits.
  Future<void> uploadPendingMetadata() async {
    if (_pendingMetadata.isEmpty && _pendingCollections.isEmpty && _pendingOrderPlan == null) return;
    if (ownerId.isEmpty) throw StateError('Sign in first');
    if (busy) return;
    busy = true;
    error = null;
    notifyListeners();
    try {
      final row = await client.from('mediaflow_states')
          .select('state_data,updated_at')
          .eq('user_id', ownerId)
          .maybeSingle();
      if (row == null || row['updated_at'] == null) {
        throw StateError('No existing cloud snapshot to update. Nothing was written.');
      }
      final remote = await compute(_unpack, row['state_data']);
      final entries = remote['library'];
      if (entries is! List) throw const FormatException('Remote Library is unavailable');
      final hits = <String>{};
      for (final entry in entries) {
        if (entry is! Map) continue;
        final id = plain(entry['id']);
        if (_pendingMetadata.containsKey(id)) {
          final original = _originalFields[id];
          if (original == null) {
            throw StateError('An edit has no baseline for safe synchronization. Nothing was written.');
          }
          for (final field in _pendingMetadata[id]!.keys) {
            if (jsonEncode(entry[field]) != jsonEncode(original[field])) {
              throw StateError('The website changed $field for this title after you edited it. Nothing was written.');
            }
          }
          entry.addAll(_pendingMetadata[id]!);
          hits.add(id);
        }
      }
      if (hits.length != _pendingMetadata.length) {
        throw StateError('One or more edited titles were removed on another device. Nothing was written.');
      }
      // Validate ALL changes before applying ANY Collection changes.
      for (final id in _pendingCollections.keys) {
        if (!_originalCollections.containsKey(id)) {
          throw StateError('Collection has no original snapshot. Upload stopped.');
        }
        CollectionMutations.verifyBaseline(remote, id, _originalCollections[id]);
      }
      for (final change in _pendingCollections.entries) {
        CollectionMutations.apply(remote, change.key, change.value);
      }
      if (_pendingOrderPlan != null) {
        if (_originalOrderPlan == null) {
          throw StateError('Personal Order is missing its original cloud baseline');
        }
        OrderMutations.validateRemote(remote, _originalOrderPlan!);
        OrderMutations.apply(remote, _pendingOrderPlan!);
      }
      remote['savedAt'] = DateTime.now().millisecondsSinceEpoch;
      final encoded = await compute(_packCloud, remote);
      final newDate = DateTime.now().toUtc().toIso8601String();
      final updated = await client.from('mediaflow_states')
          .update({'state_data': encoded, 'updated_at': newDate})
          .eq('user_id', ownerId)
          .eq('updated_at', row['updated_at'])
          .select('updated_at');
      if (updated.length != 1) {
        throw StateError('Your web app saved newer changes during sync. No native changes were uploaded; retry to rebase safely.');
      }
      _pendingMetadata.clear();
      _originalFields.clear();
      _pendingCollections.clear();
      _originalCollections.clear();
      _pendingOrderPlan = null;
      _originalOrderPlan = null;
      updatedAt = updated.first['updated_at']?.toString();
      _state = remote;
      _viewCache = null;
      cached = false;
      cloudConnected = true;
      await _savePending();
      await _saveLocalSnapshot();
    } catch (e) {
      error = 'Changes could not be synced: $e';
      rethrow;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  /// Backup to an application-owned Documents path. No network is contacted.
  /// Use device file transfer / app storage to retrieve the exported JSON.
  Future<String> exportSnapshot() async {
    if (_state.isEmpty) throw StateError('No account data to export');
    final root = await getApplicationDocumentsDirectory();
    final date = DateTime.now().toUtc().toIso8601String().substring(0, 10);
    final file = File('${root.path}${Platform.pathSeparator}MediaFlow_${date}_snapshot.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(_state), flush: true);
    return file.path;
  }

  void reset() {
    _ownerId = null;
    _state = {};
    _viewCache = null;
    _pendingMetadata.clear();
    _originalFields.clear();
    _pendingCollections.clear();
    _originalCollections.clear();
    _pendingOrderPlan = null;
    _originalOrderPlan = null;
    cloudConnected = false;
    cached = false;
    hasCloudRow = false;
    error = null;
    notifyListeners();
  }
}
