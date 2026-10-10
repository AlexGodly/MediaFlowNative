import 'package:flutter_test/flutter_test.dart';
import 'package:mediaflow_native/data/dashboard_time.dart';
void main(){
  test('stopwatch start, pause and resume across screen reloads',(){
    final start=const MediaClock().start(1000);
    expect(start.elapsedAt(3600),2600);
    final loaded=MediaClock.fromJson(start.toJson());
    expect(loaded.elapsedAt(3600),2600);
    final paused=loaded.pause(6000);
    expect(paused.elapsedAt(7000),5000);
    expect(paused.start(9000).elapsedAt(11000),7000);
  });
  test('start time, add, subtract, reset and clear',(){
    final c=const MediaClock().setTime(3600000).add(30000).subtract(10000);
    expect(c.elapsed,3620000);
    expect(c.reset().elapsed,3620000);
    expect(c.clear().elapsed,0);
    expect(c.start(1000).add(500).elapsed,3620000);
  });
  test('runtime calculator validates and accumulates durations',(){
    expect(RuntimeMath.seconds(1,24,36),5076);
    expect(RuntimeMath.sum([5076,60,34]),5170);
    expect(RuntimeMath.format(5170),'01:26:10');
    expect(RuntimeMath.minutesRounded(89),1);
    expect(()=>RuntimeMath.seconds(1,60,0),throwsFormatException);
    expect(()=>RuntimeMath.sum([1,-5]),throwsFormatException);
  });
}
