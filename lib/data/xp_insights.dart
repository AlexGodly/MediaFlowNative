import 'mediaflow_snapshot.dart';

/// Read persisted XP snapshots. XP is NOT recalculated or persisted here:
/// v372 combines completion, repeat, streak, and other adjustments.
class XpInsights {
  final int sessionCount;
  final int libraryBonus;
  final int sessionXP;
  final int explicitStreakCount;
  final int missingXPCount;
  const XpInsights({required this.sessionCount,required this.libraryBonus,
    required this.sessionXP,required this.explicitStreakCount,
    required this.missingXPCount});
  int get confirmedTotal => sessionXP+libraryBonus;

  factory XpInsights.fromSnapshot(Map<String,dynamic> state){
    final sessions=asObjects(state['sessions']);
    final ledger=asObject(state['xpLedger']);
    final additions=asObject(ledger['libraryAdditions']);
    var bonus=0;
    for(final val in additions.values){bonus+=numeric(val).toInt().clamp(0,1<<30).toInt();}
    var count=0,history=0,streakCount=0,unknown=0;
    for(final entry in sessions){
      if(entry['status']=='skipped')continue;
      count++;
      if(entry['xpWithStreak'] is num){
        history+=(entry['xpWithStreak'] as num).toInt().clamp(0,1<<30).toInt();
        streakCount++;
      } else if(entry['xp'] is num){
        history+=(entry['xp'] as num).toInt().clamp(0,1<<30).toInt();
      } else {
        unknown++;
      }
    }
    return XpInsights(sessionCount:count,libraryBonus:bonus,
      sessionXP:history,explicitStreakCount:streakCount,missingXPCount:unknown);
  }
}
