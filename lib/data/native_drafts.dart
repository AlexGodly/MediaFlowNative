import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Native drafts are purposely separate from canonical web XP/History commits.
/// Until those engines are fully ported, never write these into Supabase state.
class NativeDraftStore {
  final String userId;
  const NativeDraftStore(this.userId);
  Future<File> get _file async {
    final dir = await getApplicationSupportDirectory();
    final root = Directory('${dir.path}${Platform.pathSeparator}mediaflow-native');
    await root.create(recursive: true);
    return File('${root.path}${Platform.pathSeparator}draft-$userId.json');
  }

  Future<Map<String, dynamic>> load() async {
    try {
      final file = await _file;
      if (!await file.exists()) return {};
      final decoded = jsonDecode(await file.readAsString());
      return decoded is Map ? Map<String, dynamic>.from(decoded) : {};
    } catch (_) {
      return {};
    }
  }

  Future<void> save(Map<String, dynamic> drafts) async {
    final file = await _file;
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(jsonEncode(drafts), flush: true);
    if (await file.exists()) await file.delete();
    await temp.rename(file.path);
  }
}
