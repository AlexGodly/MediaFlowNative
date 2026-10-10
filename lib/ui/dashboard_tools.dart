import 'dart:async';
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import '../data/dashboard_time.dart';
import '../data/mediaflow_repository.dart';
import 'design.dart';

/// Fully functional Dashboard stopwatch and runtime calculator.
/// Saves local per-account state without risking the website's XP/History ledgers.
class DashboardTools extends StatefulWidget {
  final MediaFlowRepository repo;
  const DashboardTools({super.key,required this.repo});
  @override State<DashboardTools> createState()=>_DashboardToolsState();
}

class _DashboardToolsState extends State<DashboardTools> {
  MediaClock clock=const MediaClock();
  final hours=TextEditingController(text:'0'), minutes=TextEditingController(text:'0'), seconds=TextEditingController(text:'0');
  final rows=<List<TextEditingController>>[];
  bool multi=false,ready=false,collapsedStopwatch=false,collapsedCalculator=false;
  int result=0, count=0, previous=0,previousCount=0,carryCount=0;
  bool hasResult=false;
  late DashboardTimeStore storage;
  Timer? ticker;

  @override void initState(){
    super.initState();
    storage=DashboardTimeStore(widget.repo.ownerId);
    _addRow();_addRow();
    _load();
    ticker=Timer.periodic(const Duration(milliseconds:250),(_){if(mounted&&clock.running)setState((){});});
  }
  @override void dispose(){
    ticker?.cancel();hours.dispose();minutes.dispose();seconds.dispose();
    for(final row in rows){for(final c in row){c.dispose();}}
    super.dispose();
  }
  int get now=>DateTime.now().millisecondsSinceEpoch;
  void _addRow([List<int>? from])=>rows.add(List.generate(3,(i)=>TextEditingController(text:'${from?[i]??0}')));
  Future<void> _load() async {
    final data=await storage.read();
    if(!mounted)return;
    setState((){
      // Only import the website stopwatch on first use; never silently write to its cloud fields.
      clock=MediaClock.fromJson(data['clock']??widget.repo.workspace.json['stopwatch']);
      multi=data['multi']==true;
      collapsedStopwatch=data['collapsedStopwatch']==true;
      collapsedCalculator=data['collapsedCalculator']==true;
      result=(data['result'] is num?(data['result'] as num).toInt():0).clamp(0,999999999999);
      previous=(data['previous'] is num?(data['previous'] as num).toInt():0).clamp(0,999999999999);
      count=(data['count'] is num?(data['count'] as num).toInt():0).clamp(0,99999);
      previousCount=(data['previousCount'] is num?(data['previousCount'] as num).toInt():0).clamp(0,99999);
      carryCount=(data['carryCount'] is num?(data['carryCount'] as num).toInt():0).clamp(0,99999);
      hasResult=data['hasResult']==true;
      if(data['rows'] is List){
        for(final row in rows){for(final c in row){c.dispose();}}
        rows.clear();
        for(final raw in data['rows'] as List){
          if(raw is List&&raw.length==3){
            _addRow(raw.map((v)=>(v is num?v.toInt():0).clamp(0,99999)).toList());
          }
        }
        while(rows.length<2){_addRow();}
      }
      ready=true;
    });
  }
  Future<void> _persist() async {
    if(!ready)return;
    try{await storage.write({
      'clock':clock.toJson(), 'multi':multi,'collapsedStopwatch':collapsedStopwatch,
      'collapsedCalculator':collapsedCalculator,
      'rows':rows.map((r)=>r.map((c)=>int.tryParse(c.text)??0).toList()).toList(),
      'result':result,'previous':previous,'count':count,'previousCount':previousCount,
      'carryCount':carryCount,'hasResult':hasResult,
    });}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Could not save timer: $e')));}
  }
  void _change(MediaClock next){setState(()=>clock=next);_persist();}
  void _notice(String text)=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(text),duration:const Duration(seconds:2)));
  int _inputValue(TextEditingController c,{required int max}){
    final v=int.tryParse(c.text.trim());
    if(v==null||v<0||v>max)throw FormatException('Enter a whole number between 0 and $max.');
    return v;
  }
  int _timeFields(List<TextEditingController> ctrls)=>RuntimeMath.seconds(
    _inputValue(ctrls[0],max:99999),_inputValue(ctrls[1],max:59),_inputValue(ctrls[2],max:59));
  int _customMilliseconds()=>_timeFields([hours,minutes,seconds])*1000;
  void _setCustom(String action){
    if(clock.running)return;
    try{
      final ms=_customMilliseconds();
      if(action=='set')_change(clock.setTime(ms));
      if(action=='add')_change(clock.add(ms));
      if(action=='subtract')_change(clock.subtract(ms));
    }catch(e){_notice('$e');}
  }
  void _calculate(){
    try {
      final seconds=rows.map(_timeFields).toList();
      final values=multi?seconds:seconds.take(2).toList();
      final sum=RuntimeMath.sum(values);
      if(sum==0){_notice('Enter a runtime first.');return;}
      setState((){
        previous=values.first;
        previousCount=carryCount>0?carryCount:(values.first>0?1:0);
        result=sum;
        count=multi?values.where((x)=>x>0).length:previousCount+(values[1]>0?1:0);
        hasResult=true;
      });
      _persist();
    }catch(e){_notice('$e');}
  }
  void _continue(){
    if(!hasResult)return;
    final h=result~/3600,m=(result%3600)~/60,s=result%60;
    setState((){
      multi=false;carryCount=count;
      for(var i=0;i<3;i++){rows[0][i].text='${[h,m,s][i]}';rows[1][i].text='0';}
    });_persist();
  }
  void _restorePrevious(){
    if(!hasResult||previous==0)return;
    final h=previous~/3600,m=(previous%3600)~/60,s=previous%60;
    setState((){
      multi=false;result=previous;count=previousCount;carryCount=previousCount;
      for(var i=0;i<3;i++){rows[0][i].text='${[h,m,s][i]}';rows[1][i].text='0';}
    });_persist();
  }
  Widget _timeInput(String label,TextEditingController c,{int max=59})=>SizedBox(width:76,child:TextField(
    controller:c,keyboardType:TextInputType.number,
    decoration:InputDecoration(labelText:label,isDense:true,contentPadding:const EdgeInsets.symmetric(horizontal:9,vertical:11)),
    onChanged:(_)=>_persist(),
  ));
  Widget _stopwatch()=>MfAmbientCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[const Icon(Icons.timer_outlined,size:20),const SizedBox(width:9),
      const Expanded(child:Text('Stopwatch',style:TextStyle(fontWeight:FontWeight.w900,fontSize:18))),
      IconButton(tooltip:collapsedStopwatch?'Expand stopwatch':'Collapse stopwatch',onPressed:(){setState(()=>collapsedStopwatch=!collapsedStopwatch);_persist();},
        icon:Icon(collapsedStopwatch?Icons.keyboard_arrow_down_rounded:Icons.keyboard_arrow_up_rounded))]),
    if(!collapsedStopwatch)...[
      const SizedBox(height:8),Center(child:Text(RuntimeMath.format(clock.elapsedAt(now)~/1000),
        style:const TextStyle(fontWeight:FontWeight.w900,fontSize:37,fontFeatures:[FontFeature.tabularFigures()],letterSpacing:-1.5))),
      const SizedBox(height:12),Wrap(alignment:WrapAlignment.center,spacing:7,runSpacing:7,children:[
        FilledButton.icon(onPressed:clock.running?null:()=>_change(clock.start(now)),
          icon:const Icon(Icons.play_arrow_rounded,size:18),label:const Text('Start')),
        OutlinedButton.icon(onPressed:clock.running?()=>_change(clock.pause(now)):null,
          icon:const Icon(Icons.pause_rounded,size:18),label:const Text('Pause')),
        OutlinedButton(onPressed:()=>_change(clock.reset()),child:const Text('Reset')),
        TextButton(onPressed:()=>_change(clock.clear()),child:const Text('Clear')),
      ]),
      const SizedBox(height:15),Wrap(spacing:8,runSpacing:8,crossAxisAlignment:WrapCrossAlignment.center,children:[
        _timeInput('Hours',hours,max:999),_timeInput('Minutes',minutes),_timeInput('Seconds',seconds),
      ]),const SizedBox(height:9),Wrap(spacing:8,runSpacing:7,children:[
        OutlinedButton(onPressed:clock.running?null:()=>_setCustom('set'),child:const Text('Set time')),
        OutlinedButton(onPressed:clock.running?null:()=>_setCustom('add'),child:const Text('+ Add')),
        OutlinedButton(onPressed:clock.running?null:()=>_setCustom('subtract'),child:const Text('− Subtract')),
      ]),const SizedBox(height:8),
      Text('Time is saved on this device.',style:Theme.of(context).textTheme.bodySmall),
    ],
  ]));
  Widget _calculator()=>MfAmbientCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[const Icon(Icons.calculate_outlined,size:20),const SizedBox(width:9),
      const Expanded(child:Text('Runtime Calculator',style:TextStyle(fontWeight:FontWeight.w900,fontSize:18))),
      IconButton(tooltip:collapsedCalculator?'Expand calculator':'Collapse calculator',onPressed:(){setState(()=>collapsedCalculator=!collapsedCalculator);_persist();},
        icon:Icon(collapsedCalculator?Icons.keyboard_arrow_down_rounded:Icons.keyboard_arrow_up_rounded))]),
    if(!collapsedCalculator)...[
      const SizedBox(height:6),Text('Add times together or carry a running total.',style:Theme.of(context).textTheme.bodySmall),
      const SizedBox(height:12),SegmentedButton<bool>(segments:const [
        ButtonSegment(value:false,label:Text('Carry forward')),
        ButtonSegment(value:true,label:Text('Multiple rows')),
      ],selected:{multi},onSelectionChanged:(v){setState(()=>multi=v.first);_persist();}),
      const SizedBox(height:13),
      for(var i=0;i<(multi?rows.length:2);i++)...[
        Row(children:[Expanded(child:Text('Runtime ${i+1}',style:const TextStyle(fontWeight:FontWeight.w700))),
          if(multi&&rows.length>2)IconButton(tooltip:'Remove runtime ${i+1}',
            icon:const Icon(Icons.remove_circle_outline),onPressed:(){
              setState((){final removed=rows.removeAt(i);for(final c in removed){c.dispose();}});_persist();}),
        ]),const SizedBox(height:5),Wrap(spacing:8,runSpacing:8,children:[
          _timeInput('Hours',rows[i][0],max:99999),_timeInput('Minutes',rows[i][1]),_timeInput('Seconds',rows[i][2]),
        ]),const SizedBox(height:9),
      ],
      if(multi)TextButton.icon(onPressed:(){setState(()=>_addRow());_persist();},
        icon:const Icon(Icons.add_rounded),label:const Text('Add runtime row')),
      const SizedBox(height:7),const Divider(),
      Row(children:[const Expanded(child:Text('Total',style:TextStyle(fontWeight:FontWeight.w700))),
        Text(hasResult?RuntimeMath.format(result):'00:00:00',
          style:const TextStyle(fontWeight:FontWeight.w900,fontSize:22,fontFeatures:[FontFeature.tabularFigures()])),
      ]),const SizedBox(height:2),
      if(hasResult)Text('$count runtime${count==1?'':'s'} · ${RuntimeMath.minutesRounded(result)} rounded minutes',
        style:Theme.of(context).textTheme.bodySmall),
      const SizedBox(height:12),Wrap(spacing:8,runSpacing:7,children:[
        FilledButton(onPressed:_calculate,child:const Text('Calculate')),
        if(!multi)OutlinedButton(onPressed:hasResult?_continue:null,child:const Text('Continue')),
        if(!multi)TextButton(onPressed:previous>0?_restorePrevious:null,child:const Text('Previous total')),
        TextButton(onPressed:(){setState((){
          for(final row in rows){for(final c in row){c.text='0';}}
          result=0;previous=0;count=0;previousCount=0;carryCount=0;hasResult=false;
        });_persist();},child:const Text('Clear')),
      ]),
    ],
  ]));
  @override Widget build(BuildContext context){
    if(!ready)return const SizedBox(height:40,child:Center(child:CircularProgressIndicator.adaptive()));
    return LayoutBuilder(builder:(ctx,constraints){
      if(constraints.maxWidth<800)return Column(children:[_stopwatch(),const SizedBox(height:13),_calculator()]);
      return Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Expanded(child:_stopwatch()),const SizedBox(width:13),Expanded(child:_calculator())]);
    });
  }
}
