import 'package:flutter_test/flutter_test.dart';
import 'package:mediaflow_native/data/xp_insights.dart';

void main(){
  test('persisted XP uses streak field when available, never double counts',(){
    final xp=XpInsights.fromSnapshot({
      'sessions':[{'xp':100,'xpWithStreak':140},{'xp':20},{'status':'skipped','xp':1000}],
      'xpLedger':{'libraryAdditions':{'a':25,'b':25}},
    });
    expect(xp.sessionCount,2);
    expect(xp.sessionXP,160);
    expect(xp.libraryBonus,50);
    expect(xp.confirmedTotal,210);
    expect(xp.explicitStreakCount,1);
  });
  test('legacy unknown XP is not silently invented',(){
    final xp=XpInsights.fromSnapshot({'sessions':[{'minutes':24}]});
    expect(xp.missingXPCount,1);
    expect(xp.confirmedTotal,0);
  });
}
