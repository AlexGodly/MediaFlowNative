import 'package:flutter/material.dart';
import '../data/mediaflow_repository.dart';
import '../data/mediaflow_snapshot.dart';
import 'design.dart';

/// Comprehensive *read-only* view of the actual website settings snapshot.
/// Do not claim a setting is supported simply because it is present here:
/// many website options trigger JS side-effects and need explicit Dart ports.
class SettingsSnapshotExplorer extends StatefulWidget {
  final MediaFlowRepository repo;
  const SettingsSnapshotExplorer({super.key, required this.repo});
  @override State<SettingsSnapshotExplorer> createState() => _SettingsSnapshotExplorerState();
}

class _SettingsSnapshotExplorerState extends State<SettingsSnapshotExplorer> {
  final query = TextEditingController();
  @override void dispose() {query.dispose(); super.dispose();}
  @override Widget build(BuildContext context) {
    final settings = widget.repo.workspace.settings;
    final groups = settings.entries.toList()..sort((a,b)=>a.key.compareTo(b.key));
    final term=query.text.trim().toLowerCase();
    final results = groups.where((e)=>term.isEmpty ||
      e.key.toLowerCase().contains(term) || _matches(e.value,term)).toList();
    return ListView(padding:const EdgeInsets.all(16),children:[
      const ScreenHeader(label:'Website settings inspector',title:'Every saved preference',
        subtitle:'Inspect actual account settings from the shared MediaFlow cloud snapshot.',
        icon:Icons.tune_rounded),
      const SizedBox(height:12),
      const MfCard(child:Row(children:[Icon(Icons.lock_outline),SizedBox(width:10),
        Expanded(child:Text('These website settings are shown read-only until their native behavior and persistence are verified. An inspector is not a replacement for a working settings control.',style:TextStyle(fontSize:12)))])),
      const SizedBox(height:13),
      TextField(controller:query,onChanged:(_)=>setState((){}),
        decoration:InputDecoration(prefixIcon:const Icon(Icons.search),
          hintText:'Search all stored setting keys and values',
          suffixIcon:query.text.isEmpty?null:IconButton(
            icon:const Icon(Icons.clear),onPressed:(){query.clear();setState((){});}))),
      const SizedBox(height:8),
      Text('${results.length} of ${groups.length} top-level preferences',style:Theme.of(context).textTheme.labelMedium),
      const SizedBox(height:8),
      for (final entry in results) Padding(padding:const EdgeInsets.only(bottom:6),child:MfCard(
        padding:const EdgeInsets.symmetric(horizontal:12,vertical:2),
        child:ExpansionTile(tilePadding:EdgeInsets.zero,childrenPadding:const EdgeInsets.only(bottom:10),
          leading:Icon(_icon(entry.key),size:21),
          title:Text(entry.key,style:const TextStyle(fontWeight:FontWeight.w600)),
          subtitle:Text(_description(entry.value),maxLines:1),
          children:[_SettingsValue(label:entry.key,value:entry.value,depth:0)],
        ),
      )),
      const SizedBox(height:20),
    ]);
  }
  static bool _matches(dynamic value,String term) {
    if(value is Map) return value.entries.any((entry) =>
        entry.key.toString().toLowerCase().contains(term)||_matches(entry.value,term));
    if(value is List) return value.any((item)=>_matches(item,term));
    return value.toString().toLowerCase().contains(term);
  }
  static String _description(dynamic value){
    if(value is Map) return '${value.length} saved options';
    if(value is List) return '${value.length} entries';
    return plain(value,'unset');
  }
  static IconData _icon(String key){
    final k=key.toLowerCase();
    if(k.contains('theme')||k.contains('appear')||k.contains('color'))return Icons.palette_outlined;
    if(k.contains('library')||k.contains('cover'))return Icons.collections_bookmark_outlined;
    if(k.contains('log')||k.contains('history'))return Icons.history_toggle_off;
    if(k.contains('xp')||k.contains('level')||k.contains('streak'))return Icons.emoji_events_outlined;
    if(k.contains('sync')||k.contains('cloud'))return Icons.cloud_sync_outlined;
    if(k.contains('backup')||k.contains('export'))return Icons.archive_outlined;
    if(k.contains('order')||k.contains('queue'))return Icons.format_list_numbered;
    if(k.contains('categor'))return Icons.category_outlined;
    return Icons.tune;
  }
}

class _SettingsValue extends StatelessWidget {
  final String label;
  final dynamic value;
  final int depth;
  const _SettingsValue({required this.label,required this.value,required this.depth});
  @override Widget build(BuildContext context){
    if(depth>=5)return SelectableText('$label: [nested configuration]',style:const TextStyle(fontSize:12));
    if(value is Map){
      final entries=(value as Map).entries.toList()..sort((a,b)=>a.key.toString().compareTo(b.key.toString()));
      return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        for(final entry in entries)Padding(padding:EdgeInsets.only(left:depth*6,top:5),
          child: _SettingsValue(label:entry.key.toString(),value:entry.value,depth:depth+1)),
      ]);
    }
    if(value is List){
      final list=value as List;
      if(list.length>16)return SelectableText('$label: ${list.length} stored entries (preview omitted)',
        style:const TextStyle(fontSize:12));
      return Padding(padding:const EdgeInsets.only(top:3),child:Column(
        crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('$label (${list.length})',style:const TextStyle(fontWeight:FontWeight.w600,fontSize:12)),
          for(var i=0;i<list.length;i++)_SettingsValue(label:'$i',value:list[i],depth:depth+1),
        ]));
    }
    return Padding(padding:const EdgeInsets.only(top:3),child:Row(
      crossAxisAlignment:CrossAxisAlignment.start,children:[
        Expanded(flex:2,child:Text(label,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w500))),
        const SizedBox(width:5),
        Expanded(flex:3,child:SelectableText(plain(value,'null'),
          style:TextStyle(fontSize:12,color:Theme.of(context).colorScheme.primary))),
      ]));
  }
}
