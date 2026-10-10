import 'dart:async';
import 'package:flutter/material.dart';
import '../data/mediaflow_repository.dart';
import '../data/native_drafts.dart';
import '../data/models.dart';
import '../data/mediaflow_snapshot.dart';
import 'design.dart';

class NativeLoggingPage extends StatefulWidget {
  final MediaFlowRepository repo;
  const NativeLoggingPage({super.key,required this.repo});
  @override State<NativeLoggingPage> createState()=>_NativeLoggingPageState();
}
class _NativeLoggingPageState extends State<NativeLoggingPage> {
  Map<String,dynamic> draft={'mode':'itemized','quickMethod':'amount','titles':<dynamic>[]};
  Timer? timer;
  bool ready=false;
  NativeDraftStore get store=>NativeDraftStore(widget.repo.ownerId);
  @override void initState(){super.initState();_load();}
  Future<void> _load() async {
    final saved=await store.load();
    if(!mounted)return;
    setState((){
      if(saved.isNotEmpty)draft=saved;
      if(draft['titles'] is! List)draft['titles']=<dynamic>[];
      ready=true;
    });
  }
  void changed(){
    if(mounted)setState((){});
    timer?.cancel();
    timer=Timer(const Duration(milliseconds:350),()=>store.save(draft));
  }
  @override void dispose(){timer?.cancel();store.save(draft);super.dispose();}
  List<Map<String,dynamic>> get entries=>asObjects(draft['titles']);
  void _update(String id,void Function(Map<String,dynamic>) fn){
    final items=draft['titles'] as List;
    final index=items.indexWhere((v)=>v is Map && plain(v['id'])==id);
    if(index<0)return;
    final value=Map<String,dynamic>.from(items[index] as Map);
    fn(value);items[index]=value;changed();
  }
  Future<void> _selectTitle() async {
    final all=widget.repo.workspace.titles;
    final picked=await showModalBottomSheet<MediaTitle>(context:context,isScrollControlled:true,
      showDragHandle:true,builder:(ctx)=>_TitlePicker(titles:all));
    if(picked==null)return;
    if(entries.any((e)=>plain(e['id'])==picked.id)){
      if(mounted)showMessage(context,'Already added to this draft.');return;
    }
    (draft['titles'] as List).add({'id':picked.id,'units':<dynamic>[],
      'amount':1,'last':picked.progress,'minutes':0});
    changed();
  }
  Future<void> _clear() async {
    final okay=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(
      title:const Text('Clear all added titles?'),
      content:Text('Remove ${entries.length} title(s) from this local unfinished draft? Your saved MediaFlow Library, History and XP will not change.'),
      actions:[TextButton.icon(onPressed:()=>Navigator.pop(ctx,false),icon:const Icon(Icons.shield_outlined),label:const Text('Keep titles')),
        FilledButton.icon(onPressed:()=>Navigator.pop(ctx,true),icon:const Icon(Icons.delete_outline),label:const Text('Clear titles'))],
    ));
    if(okay==true){draft['titles']=<dynamic>[];changed();}
  }
  @override Widget build(BuildContext context) {
    if(!ready)return const Center(child:CircularProgressIndicator());
    final data=widget.repo.workspace;
    final map={for(final t in data.titles)t.id:t};
    final perUnit=draft['mode']=='itemized';
    final count=perUnit?entries.fold<int>(0,(n,e)=>n+asObjects(e['units']).length):
      entries.fold<int>(0,(n,e)=>n+(draft['quickMethod']=='amount'?numeric(e['amount']).toInt():
      (numeric(e['last'])-numeric(map[plain(e['id'])]?.progress)).toInt().clamp(0,999999).toInt()));
    return ListView(padding:const EdgeInsets.all(16),children:[
      ScreenHeader(label:'Native logging studio',title:perUnit?'Precision logging':'Express logging',
        subtitle:'Compose drafts locally. Full website-compatible XP commits are still being ported.',
        icon:perUnit?Icons.format_list_numbered_rounded:Icons.bolt_rounded),
      const SizedBox(height:12),
      MfCard(tint:Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha:.24),
        child:Row(children:[const Icon(Icons.shield_outlined,size:21),const SizedBox(width:12),
          const Expanded(child:Text('SAFE MODE · Unsaved native drafts stay on this device. They are never written into website History or XP until the canonical engine is ported.',
            style:TextStyle(fontSize:12)))])),
      const SizedBox(height:14),
      SegmentedButton<String>(segments:const [
        ButtonSegment(value:'itemized',label:Text('Per unit'),icon:Icon(Icons.list_alt_rounded)),
        ButtonSegment(value:'quick',label:Text('Quick Logging'),icon:Icon(Icons.bolt_rounded)),
      ],selected:{plain(draft['mode'],'itemized')},
        onSelectionChanged:(s){draft['mode']=s.first;changed();}),
      if(!perUnit)...[
        const SizedBox(height:10),
        SegmentedButton<String>(segments:const [
          ButtonSegment(value:'amount',label:Text('Amount consumed')),
          ButtonSegment(value:'last',label:Text('Last progress')),
        ],selected:{plain(draft['quickMethod'],'amount')},
          onSelectionChanged:(s){draft['quickMethod']=s.first;changed();}),
      ],
      const SizedBox(height:14),
      Row(children:[
        Expanded(child:MfMetric(icon:Icons.collections_bookmark_outlined,label:'Titles',value:'${entries.length}')),
        const SizedBox(width:9),
        Expanded(child:MfMetric(icon:Icons.list_alt_rounded,label:'Units in draft',value:'$count')),
      ]),
      const SizedBox(height:14),
      Row(children:[
        Expanded(child:FilledButton.icon(onPressed:_selectTitle,
          icon:const Icon(Icons.add_circle_outline),label:const Text('Add Library title'))),
        const SizedBox(width:8),
        IconButton.filledTonal(tooltip:'Clear local draft',onPressed:entries.isEmpty?null:_clear,
          icon:const Icon(Icons.delete_sweep_outlined)),
      ]),
      const SizedBox(height:15),
      if(entries.isEmpty)const MfCard(child:Padding(padding:EdgeInsets.all(12),
        child:Column(children:[Icon(Icons.auto_stories_outlined,size:38),SizedBox(height:8),
          Text('Your native draft is empty.'),SizedBox(height:5),Text('Add a title from your synced Library to begin.')])))
      else ...entries.map((entry){
        final id=plain(entry['id']);final title=map[id];
        if(title==null)return const SizedBox.shrink();
        final units=asObjects(entry['units']);
        return Padding(padding:const EdgeInsets.only(bottom:12),child:MfCard(child:Column(
          crossAxisAlignment:CrossAxisAlignment.start,children:[
            Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
              TitleCover(title.cover,width:66,height:91),const SizedBox(width:12),
              Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text(title.title,maxLines:2,overflow:TextOverflow.ellipsis,
                  style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.bold)),
                const SizedBox(height:7),TitleBadges(title:title,workspace:data),
              ])),
              IconButton(onPressed:(){
                (draft['titles'] as List).removeWhere((e)=>e is Map && e['id']==id);changed();
              },tooltip:'Remove title',icon:const Icon(Icons.close_rounded)),
            ]),
            const SizedBox(height:12),
            if(perUnit)...[
              for(var i=0;i<units.length;i++)_UnitEditor(
                key:ValueKey('$id/${plain(units[i]['id'], 'legacy-$i')}'),value:units[i],index:i,
                onChanged:(newUnit){_update(id,(e){
                  final items=List<Map<String,dynamic>>.from(asObjects(e['units']));
                  if(i<items.length)items[i]=newUnit;
                  e['units']=items;
                });},
                onRemove:(){_update(id,(e){
                  final items=asObjects(e['units']);if(i<items.length)items.removeAt(i);
                  e['units']=items;
                });},
              ),
              Align(alignment:Alignment.centerLeft,child:OutlinedButton.icon(
                onPressed:(){_update(id,(e){
                  final items=asObjects(e['units']);
                  items.add({'id':'unit-${DateTime.now().microsecondsSinceEpoch}',
                    'number':title.progress+items.length+1,
                    'hours':0,'minutes':24,'seconds':0,
                    'timestamp':DateTime.now().toIso8601String(),'repeat':false});
                  e['units']=items;
                });},icon:const Icon(Icons.add_rounded),label:const Text('Add unit'))),
            ]else ...[
              TextFormField(key:ValueKey('$id/${draft['quickMethod']}'),
                initialValue:plain(entry[draft['quickMethod']=='amount'?'amount':'last']),
                keyboardType:TextInputType.number,
                decoration:InputDecoration(labelText:draft['quickMethod']=='amount'?'Amount consumed':'Last progress'),
                onChanged:(v)=>_update(id,(e){e[draft['quickMethod']=='amount'?'amount':'last']=int.tryParse(v)??0;})),
              const SizedBox(height:9),
              TextFormField(key:ValueKey('$id/minutes'),initialValue:plain(entry['minutes']),
                keyboardType:TextInputType.number,
                decoration:const InputDecoration(labelText:'Minutes spent'),
                onChanged:(v)=>_update(id,(e){e['minutes']=int.tryParse(v)??0;})),
            ],
          ])));
      }),
      const SizedBox(height:8),
      const MfCard(child:Row(children:[Icon(Icons.info_outline,size:20),SizedBox(width:10),
        Expanded(child:Text('Native draft saving is local-only in this milestone. Record official sessions in your MediaFlow website to keep XP, progress and History synchronized.'))])),
      const SizedBox(height:25),
    ]);
  }
}

class _UnitEditor extends StatefulWidget {
  final Map<String,dynamic> value;
  final int index;
  final ValueChanged<Map<String,dynamic>> onChanged;
  final VoidCallback onRemove;
  const _UnitEditor({super.key,required this.value,required this.index,
    required this.onChanged,required this.onRemove});
  @override State<_UnitEditor> createState()=>_UnitEditorState();
}
class _UnitEditorState extends State<_UnitEditor> {
  void field(String key,String text){
    final copy=Map<String,dynamic>.from(widget.value);
    copy[key]=int.tryParse(text)??0;
    widget.onChanged(copy);
  }
  @override Widget build(BuildContext context) {
    final val=widget.value;
    return Padding(padding:const EdgeInsets.only(bottom:9),child:Container(
      padding:const EdgeInsets.all(11),decoration:BoxDecoration(
        color:Theme.of(context).colorScheme.primary.withValues(alpha:.045),
        borderRadius:BorderRadius.circular(13),
        border:Border.all(color:Theme.of(context).dividerColor)),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[
          Expanded(child:Text('Unit ${widget.index+1}',style:const TextStyle(fontWeight:FontWeight.bold))),
          IconButton(tooltip:'Remove unit',onPressed:widget.onRemove,
            icon:const Icon(Icons.remove_circle_outline_rounded,size:20)),
        ]),
        TextFormField(initialValue:plain(val['number']),keyboardType:TextInputType.number,
          decoration:const InputDecoration(labelText:'Episode / chapter number'),
          onChanged:(v)=>field('number',v)),
        const SizedBox(height:7),
        Row(children:[
          for(final key in ['hours','minutes','seconds'])...[
            Expanded(child:TextFormField(initialValue:plain(val[key]),keyboardType:TextInputType.number,
              decoration:InputDecoration(labelText:key[0].toUpperCase()+key.substring(1)),
              onChanged:(v)=>field(key,v))),
            if(key!='seconds')const SizedBox(width:7),
          ],
        ]),
        SwitchListTile.adaptive(contentPadding:EdgeInsets.zero,dense:true,
          title:const Text('Rewatch / reread'),value:val['repeat']==true,
          onChanged:(v){final copy=Map<String,dynamic>.from(val);copy['repeat']=v;widget.onChanged(copy);}),
        Text('Added: ${plain(val['timestamp'])}',style:Theme.of(context).textTheme.labelSmall),
      ])));
  }
}

class _TitlePicker extends StatefulWidget {
  final List<MediaTitle> titles;
  const _TitlePicker({required this.titles});
  @override State<_TitlePicker> createState()=>_TitlePickerState();
}
class _TitlePickerState extends State<_TitlePicker> {
  String query='';
  @override Widget build(BuildContext context) {
    final data=widget.titles.where((e)=>e.title.toLowerCase().contains(query.toLowerCase())).take(120).toList();
    return SafeArea(child:FractionallySizedBox(heightFactor:.88,child:Column(children:[
      Padding(padding:const EdgeInsets.all(16),child:TextField(
        autofocus:true,decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Find a Library title'),
        onChanged:(v)=>setState(()=>query=v))),
      Expanded(child:ListView.builder(itemCount:data.length,itemBuilder:(ctx,i){
        final item=data[i];
        return ListTile(leading:TitleCover(item.cover,width:42,height:56),
          title:Text(item.title,maxLines:2),subtitle:Text(item.status),
          trailing:const Icon(Icons.add_circle_outline),onTap:()=>Navigator.pop(context,item));
      })),
    ])));
  }
}
