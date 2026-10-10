import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Pure stopwatch calculations follow MediaFlow's elapsed/start/reset contract.
class MediaClock {
  final int elapsed;
  final int startedAt;
  final int resetValue;
  final bool running;
  const MediaClock({this.elapsed=0,this.startedAt=0,this.resetValue=0,this.running=false});
  int elapsedAt(int now) => elapsed + (running ? (now-startedAt).clamp(0,1<<52) : 0);
  MediaClock start(int now) => running ? this : MediaClock(elapsed:elapsed,startedAt:now,resetValue:resetValue,running:true);
  MediaClock pause(int now) => running ? MediaClock(elapsed:elapsedAt(now),resetValue:resetValue) : this;
  MediaClock setTime(int ms) => MediaClock(elapsed:ms.clamp(0,3599999999),resetValue:ms.clamp(0,3599999999));
  MediaClock add(int ms) => running ? this : setTime(elapsed+ms);
  MediaClock subtract(int ms) => running ? this : setTime((elapsed-ms).clamp(0,3599999999));
  MediaClock reset() => MediaClock(elapsed:resetValue,resetValue:resetValue);
  MediaClock clear() => const MediaClock();
  factory MediaClock.fromJson(Object? input){
    if(input is! Map)return const MediaClock();
    int read(String key) => (input[key] is num ? (input[key] as num).toInt() : 0).clamp(0,1<<52);
    return MediaClock(elapsed:read('elapsed'),startedAt:read('startedAt'),resetValue:read('resetValue'),running:input['running']==true);
  }
  Map<String,dynamic> toJson()=>{'elapsed':elapsed,'startedAt':startedAt,'resetValue':resetValue,'running':running};
}

/// Website-like runtime operations in integer seconds, without floating drift.
class RuntimeMath {
  static int seconds(int hours,int minutes,int seconds){
    if(hours<0||hours>99999||minutes<0||minutes>59||seconds<0||seconds>59){
      throw const FormatException('Hours must be 0–99999; minutes and seconds 0–59.');
    }
    return hours*3600+minutes*60+seconds;
  }
  static int sum(Iterable<int> values){
    var result=0;
    for(final v in values){if(v<0)throw const FormatException('Runtimes cannot be negative.');result+=v;}
    return result;
  }
  static String format(int seconds){
    final s=seconds.clamp(0,999999999999);
    return '${(s~/3600).toString().padLeft(2,'0')}:${((s%3600)~/60).toString().padLeft(2,'0')}:${(s%60).toString().padLeft(2,'0')}';
  }
  static int minutesRounded(int seconds)=>(seconds/60).round();
}

/// Device-local backup for dashboard tools. Independent of cloud snapshots.
class DashboardTimeStore {
  final String ownerId;
  const DashboardTimeStore(this.ownerId);
  Future<File> _file() async {
    final base=await getApplicationSupportDirectory();
    final folder=Directory('${base.path}${Platform.pathSeparator}mediaflow-native');
    await folder.create(recursive:true);
    return File('${folder.path}${Platform.pathSeparator}dashboard-time-$ownerId.json');
  }
  Future<Map<String,dynamic>> read() async {
    try {
      final file=await _file();
      if(!await file.exists())return {};
      final json=jsonDecode(await file.readAsString());
      if(json is Map)return Map<String,dynamic>.from(json);
    } catch (_) {/* Existing tools and Library remain usable on error. */}
    return {};
  }
  Future<void> write(Map<String,dynamic> data) async {
    final file=await _file();
    final temp=File('${file.path}.tmp');
    await temp.writeAsString(jsonEncode(data),flush:true);
    if(await file.exists())await file.delete();
    await temp.rename(file.path);
  }
}
