import 'dart:convert';
import 'dart:io';

/// Matches v372 services/cloud-sync/004-v115-cloud-data-loss-prevention-recovery-guard.js.
/// A snapshot MUST preserve all unknown fields when reserialized: this is a
/// multi-hundred-feature application and stripping unknown fields loses data.
abstract final class MediaFlowSnapshotCodec {
  static Map<String, dynamic> decodeCloud(dynamic encoded) {
    if (encoded == null) return <String, dynamic>{};
    if (encoded is! Map) throw const FormatException('Cloud snapshot is not an object');
    final payload = Map<String, dynamic>.from(encoded);
    if (payload['__mediaflowCompressed'] != 'gzip') return payload;
    final raw = payload['data'];
    if (raw is! String) throw const FormatException('Compressed MediaFlow payload has no data');
    final bytes = gzip.decode(base64Decode(raw));
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map) throw const FormatException('Decompressed snapshot is not an object');
    return Map<String, dynamic>.from(decoded);
  }

  static Map<String, dynamic> encodeCloud(Map<String, dynamic> snapshot) {
    // Use web-compatible gzip+base64 wrapper; do not write partial snapshots.
    final text = jsonEncode(snapshot);
    if (text.length < 200000) return snapshot;
    return {
      '__mediaflowCompressed': 'gzip',
      'data': base64Encode(gzip.encode(utf8.encode(text))),
    };
  }

  static List<int> encodeLocal(Map<String, dynamic> state) =>
      gzip.encode(utf8.encode(jsonEncode(state)));

  static Map<String, dynamic> decodeLocal(List<int> payload) {
    final obj = jsonDecode(utf8.decode(gzip.decode(payload)));
    if (obj is! Map) throw const FormatException('Local snapshot is not an object');
    return Map<String, dynamic>.from(obj);
  }
}

Map<String, dynamic> asObject(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

List<Map<String, dynamic>> asObjects(dynamic value) => value is List
    ? value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : <Map<String, dynamic>>[];

String plain(dynamic value, [String fallback = '']) =>
    value == null ? fallback : value.toString();

double numeric(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse(plain(value)) ?? 0;
