import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Per-account native display override. The website's own Settings are never mutated.
class AppearancePreferences {
  final String ownerId;
  const AppearancePreferences(this.ownerId);
  Future<File> _file() async {
    final base=await getApplicationSupportDirectory();
    final dir=Directory('${base.path}${Platform.pathSeparator}mediaflow-native');
    await dir.create(recursive:true);
    return File('${dir.path}${Platform.pathSeparator}appearance-$ownerId.json');
  }
  Future<Map<String,dynamic>> read() async {
    try{
      final file=await _file();
      if(!await file.exists())return {};
      final value=jsonDecode(await file.readAsString());
      if(value is Map)return Map<String,dynamic>.from(value);
    } catch (_) { /* Keep default theme if preference is unreadable. */ }
    return {};
  }
  Future<void> write({String? theme,bool? dark}) async {
    final file=await _file();
    final tmp=File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode({'theme':theme,'dark':dark}),flush:true);
    if(await file.exists())await file.delete();
    await tmp.rename(file.path);
  }
}
