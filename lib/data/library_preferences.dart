import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// App-local Library UI preferences. Never changes or overwrites the web snapshot.
class LibraryPreferences {
  final String ownerId;
  const LibraryPreferences(this.ownerId);

  Future<File> _file() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}${Platform.pathSeparator}mediaflow-native');
    await dir.create(recursive: true);
    return File('${dir.path}${Platform.pathSeparator}library-ui-$ownerId.json');
  }

  Future<Map<String, dynamic>> read() async {
    try {
      final file = await _file();
      if (!await file.exists()) return {};
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) { /* Keep functional defaults if old preferences are invalid. */ }
    return {};
  }

  Future<void> write(Map<String, dynamic> settings) async {
    final destination = await _file();
    final temp = File('${destination.path}.tmp');
    await temp.writeAsString(jsonEncode(settings), flush: true);
    if (await destination.exists()) await destination.delete();
    await temp.rename(destination.path);
  }
}
