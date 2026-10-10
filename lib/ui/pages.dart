import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mediaflow_repository.dart';
import '../data/mediaflow_snapshot.dart';
import '../data/models.dart';
import '../data/collection_mutations.dart';
import 'design.dart';
import 'theme_tokens.dart';

class DashboardPage extends StatelessWidget {
  final MediaFlowRepository repo;
  final void Function(MediaTitle) openTitle;
  const DashboardPage({super.key,required this.repo,required this.openTitle});
  @override Widget build(BuildContext context) {
    final space=repo.workspace;
    final titles=space.titles;
    final sessions=space.sessions;
    final active=titles.where((t)=>
      ['watching','reading','active'].contains(t.status.toLowerCase())).toList();
    final completed=titles.where((t)=>t.status.toLowerCase()=='completed').length;
    final p=mfPalette(context);
    final width=MediaQuery.sizeOf(context).width;
    final compact=width<650;
    final featured=active.isNotEmpty?active.first:(titles.isNotEmpty?titles.first:null);
    final recentSessions=sessions.length;
    final completionPercent=titles.isEmpty?0.0:completed/titles.length;
    final mediaName=featured?.title??'Your universe, organized.';
    return ListView(padding:EdgeInsets.symmetric(horizontal:compact?15:25,vertical:compact?17:25),children:[
      ConstrainedBox(constraints:const BoxConstraints(maxWidth:1450),
        child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          Row(children:[
            Container(width:7,height:7,decoration:BoxDecoration(color:p.accent,shape:BoxShape.circle)),
            const SizedBox(width:9),
            Text('YOUR MEDIA UNIVERSE',style:TextStyle(fontWeight:FontWeight.w900,
              fontSize:10,letterSpacing:2.3,color:p.accent)),
            const Spacer(),
            if(!compact)MfBadge('Native workspace',icon:Icons.devices_rounded),
          ]),
          const SizedBox(height:10),
          Text('Welcome back.',style:TextStyle(color:p.text,fontSize:compact?31:39,
            height:1.08,letterSpacing:-1.8,fontWeight:FontWeight.w900)),
          const SizedBox(height:5),
          Text('Everything you love, all in one place.',style:TextStyle(color:p.muted,fontSize:13)),
          const SizedBox(height:23),
          if(featured!=null) _featureHero(context,featured,mediaName,compact,p),
          if(featured==null) MfAmbientCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            const Text('Your next story starts here.',style:TextStyle(fontWeight:FontWeight.w900,fontSize:22)),
            const SizedBox(height:8),Text('Sign in and sync your Library to see your collection.',style:TextStyle(color:p.muted)),
          ])),
          const SizedBox(height:16),
          GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),
            crossAxisCount:compact?2:4,childAspectRatio:compact?1.03:1.9,
            crossAxisSpacing:10,mainAxisSpacing:10,children:[
              MfMetric(icon:Icons.video_library_outlined,label:'Titles in Library',
                value:NumberFormat.compact().format(titles.length)),
              MfMetric(icon:Icons.task_alt_rounded,label:'Completed',value:NumberFormat.compact().format(completed)),
              MfMetric(icon:Icons.schedule_rounded,label:'Sessions logged',
                value:NumberFormat.compact().format(recentSessions)),
              MfMetric(icon:Icons.grid_view_rounded,label:'Collections',
                value:NumberFormat.compact().format(space.collections.length)),
            ]),
          const SizedBox(height:27),
          MfSectionHeading(icon:Icons.play_circle_outline_rounded,
            title:'Currently in progress',detail:'Pick up where you left off',
            trailing:MfBadge('${active.length} active')),
          const SizedBox(height:14),
          if(active.isEmpty)MfCard(child:Text('Your active titles will appear here.',
            style:TextStyle(color:p.muted))),
          if(active.isNotEmpty)
            SizedBox(height:compact?218:246,child:ListView.separated(
              scrollDirection:Axis.horizontal,
              itemCount:active.length>16?16:active.length,
              separatorBuilder:(_,__)=>const SizedBox(width:12),
              itemBuilder:(ctx,i){
                final title=active[i];
                final w=compact?133.0:162.0;
                return SizedBox(width:w,child:InkWell(
                  borderRadius:BorderRadius.circular(18),onTap:()=>openTitle(title),
                  child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                    Stack(children:[
                      TitleCover(title.cover,width:w,height:compact?163:183),
                      Positioned(left:7,bottom:7,right:7,child:Container(
                        padding:const EdgeInsets.symmetric(horizontal:7,vertical:5),
                        decoration:BoxDecoration(color:Colors.black.withValues(alpha:.70),
                          borderRadius:BorderRadius.circular(8)),
                        child:Text('${title.progress}${title.total>0?' / ${title.total}':''} units',
                          maxLines:1,style:const TextStyle(fontSize:10,color:Colors.white,
                            fontWeight:FontWeight.w700)))),
                    ]),const SizedBox(height:8),
                    Text(title.title,maxLines:1,overflow:TextOverflow.ellipsis,
                      style:TextStyle(fontWeight:FontWeight.w800,color:p.text,fontSize:12)),
                    const SizedBox(height:7),
                    ClipRRect(borderRadius:BorderRadius.circular(8),child:LinearProgressIndicator(
                      value:title.total>0?(title.progress/title.total).clamp(0.0,1.0):0,
                      backgroundColor:p.raised,color:p.accent,minHeight:4)),
                  ])));
              })),
          const SizedBox(height:25),
          MfSectionHeading(icon:Icons.auto_graph_rounded,
            title:'Your progress',detail:'A snapshot of your media journey'),
          const SizedBox(height:12),
          MfCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text('Completion overview',style:TextStyle(color:p.text,fontWeight:FontWeight.w800,fontSize:15)),
              const SizedBox(height:4),Text('$completed of ${titles.length} titles completed',
                style:TextStyle(color:p.muted,fontSize:11.5)),
            ])),Text('${(completionPercent*100).toStringAsFixed(1)}%',
              style:TextStyle(color:p.accent,fontSize:24,fontWeight:FontWeight.w900,letterSpacing:-.9))]),
            const SizedBox(height:16),ClipRRect(borderRadius:BorderRadius.circular(12),
              child:LinearProgressIndicator(value:completionPercent,backgroundColor:p.raised,
                color:p.accent,minHeight:10)),
          ])),
          const SizedBox(height:14),
          MfAmbientCard(padding:const EdgeInsets.all(16),child:Row(children:[
            Icon(Icons.shield_outlined,color:p.accent,size:21),const SizedBox(width:12),
            Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text('Connected to your MediaFlow account',style:TextStyle(fontWeight:FontWeight.w800,
                color:p.text,fontSize:12)),const SizedBox(height:4),
              Text('Safe cloud reading and staged edits. Website-only XP and logging writes stay protected.',
                style:TextStyle(color:p.muted,fontSize:11,height:1.5)),
            ])),
          ])),
          const SizedBox(height:35),
        ])),
    ]);
  }

  Widget _featureHero(BuildContext context,MediaTitle featured,String title,bool compact,MfPalette p){
    final coverWidth=compact?100.0:165.0;
    final coverHeight=compact?146.0:225.0;
    return MfAmbientCard(padding:EdgeInsets.all(compact?15:23),child:Row(children:[
      TitleCover(featured.cover,width:coverWidth,height:coverHeight),
      SizedBox(width:compact?14:25),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,
        mainAxisAlignment:MainAxisAlignment.center,children:[
        MfBadge('UP NEXT',icon:Icons.auto_awesome_rounded),
        const SizedBox(height:10),
        Text(title,maxLines:3,overflow:TextOverflow.ellipsis,
          style:TextStyle(color:p.text,fontSize:compact?19:27,
            fontWeight:FontWeight.w900,height:1.16,letterSpacing:-.7)),
        const SizedBox(height:8),
        Text('Your next chapter is waiting.',maxLines:2,
          style:TextStyle(color:p.muted,fontSize:compact?10.5:13)),
        const SizedBox(height:14),
        TextButton.icon(onPressed:()=>openTitle(featured),
          icon:const Icon(Icons.arrow_outward_rounded,size:16),
          label:const Text('View title')),
      ])),
    ]));
  }
}

Future<void> showTitleDetails(BuildContext context, MediaFlowRepository repo, MediaTitle title) async {
  final updated=repo.workspace.titles.where((x)=>x.id==title.id);
  if(updated.isEmpty)return;
  final item=updated.first;
  final space=repo.workspace;
  final cover=TextEditingController(text:item.cover);
  final tags=TextEditingController(text:item.tags.join(', '));
  final description=TextEditingController(text:item.description);
  final rating=TextEditingController(text:item.rating.toStringAsFixed(1));
  var priority=item.priority;
  var edited=false;
  await showDialog<void>(context:context,builder:(dialogContext)=>StatefulBuilder(
    builder:(ctx,setDialog)=>AlertDialog(
      title:const Text('Title details'),
      content:SizedBox(width:480,child:SingleChildScrollView(child:Column(
        mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
          Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
            TitleCover(item.cover,width:85,height:120),const SizedBox(width:13),
            Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text(item.title,style:Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.bold)),
              const SizedBox(height:9),TitleBadges(title:item,workspace:space),
              const SizedBox(height:10),Text('Progress: ${item.progress}${item.total>0?' / ${item.total}':''}'),
            ])),
          ]),const SizedBox(height:18),
          const Text('Editable metadata',style:TextStyle(fontWeight:FontWeight.w700)),
          const SizedBox(height:4),
          Text('Cover, priority, tags, rating and description can be staged for safe cloud upload. Progress, status, XP and official logging still require the website.',
            style:Theme.of(ctx).textTheme.bodySmall),
          const SizedBox(height:12),
          TextField(controller:cover,decoration:const InputDecoration(labelText:'Cover URL')),
          const SizedBox(height:10),
          DropdownButtonFormField<String>(initialValue:priority,decoration:const InputDecoration(labelText:'Priority'),
            items:const ['low','medium','high'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),
            onChanged:(v)=>setDialog(()=>priority=v??priority)),
          const SizedBox(height:10),
          TextField(controller:tags,decoration:const InputDecoration(labelText:'Tags (comma-separated)')),
          const SizedBox(height:10),
          TextField(controller:rating,keyboardType:const TextInputType.numberWithOptions(decimal:true),
            decoration:const InputDecoration(labelText:'Rating (0–10)')),
          const SizedBox(height:10),
          TextField(controller:description,maxLines:4,decoration:const InputDecoration(labelText:'Description')),
        ]))),
      actions:[
        TextButton(onPressed:()=>Navigator.of(ctx).pop(),child:const Text('Close')),
        FilledButton.icon(icon:const Icon(Icons.save_outlined),label:const Text('Save locally'),
          onPressed:()async{
            final score=double.tryParse(rating.text.trim());
            if(score == null || score < 0 || score > 10){showMessage(ctx,'Rating must be between 0 and 10.');return;}
            try {
              await repo.stageTitleMetadata(item.id,coverUrl:cover.text,priority:priority,
                description:description.text,rating:score,
                tags:tags.text.split(',').map((e)=>e.trim()).where((e)=>e.isNotEmpty).toList());
            } catch(e){if(ctx.mounted)showMessage(ctx,'Could not save: $e');return;}
            edited=true;
            if(ctx.mounted)Navigator.of(ctx).pop();
          }),
      ],
    )));
  cover.dispose();tags.dispose();description.dispose();rating.dispose();
  if(edited && context.mounted)showMessage(context,'Metadata saved locally. Use Account → Upload edits to sync safely.');
}

class CollectionsPage extends StatefulWidget {
  final MediaFlowRepository repo;
  final void Function(MediaTitle) openTitle;
  const CollectionsPage({super.key, required this.repo, required this.openTitle});
  @override State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  final query = TextEditingController();
  String sort = 'updated';
  @override void dispose() { query.dispose(); super.dispose(); }

  Future<void> _edit([MediaCollection? collection]) async {
    final name = TextEditingController(text: collection?.title ?? '');
    final description = TextEditingController(text: collection?.description ?? '');
    final cover = TextEditingController(text: collection?.cover ?? '');
    final selected = List<String>.of(collection?.titleIds ?? []);
    final old = collection?.raw;
    var changed = false;
    try {
      await showDialog<void>(context:context, builder:(ctx) => StatefulBuilder(
        builder:(ctx, update) => AlertDialog(
          title:Text(collection == null ? 'Create Collection' : 'Edit Collection'),
          content:SizedBox(width:550, child:SingleChildScrollView(child:Column(
            mainAxisSize:MainAxisSize.min, crossAxisAlignment:CrossAxisAlignment.start,
            children:[
              TextField(controller:name, maxLength:180, decoration:const InputDecoration(
                labelText:'Collection name', prefixIcon:Icon(Icons.collections_bookmark_outlined))),
              const SizedBox(height:8),
              TextField(controller:description, maxLines:3, decoration:const InputDecoration(
                labelText:'Description', prefixIcon:Icon(Icons.notes_outlined))),
              const SizedBox(height:8),
              TextField(controller:cover, decoration:const InputDecoration(
                labelText:'Cover URL', prefixIcon:Icon(Icons.image_outlined))),
              const SizedBox(height:14),
              Row(children:[Expanded(child:Text('Collection titles (${selected.length})',
                style:Theme.of(ctx).textTheme.titleSmall?.copyWith(fontWeight:FontWeight.bold))),
                IconButton.filledTonal(tooltip:'Add Library titles',onPressed:()async{
                  final result=await showModalBottomSheet<MediaTitle>(context:ctx,
                    showDragHandle:true,isScrollControlled:true,
                    builder:(pickerContext)=>_CollectionTitlePicker(titles:widget.repo.workspace.titles,
                      selected:selected.toSet()));
                  if(result!=null && !selected.contains(result.id)) update(()=>selected.add(result.id));
                },icon:const Icon(Icons.add_rounded)),
              ]),
              if(selected.isEmpty)const Padding(padding:EdgeInsets.symmetric(vertical:12),
                child:Text('No titles yet. Add titles from your Library.')),
              SizedBox(height:selected.isEmpty?0:(selected.length*54).clamp(54,280).toDouble(),
                child:ReorderableListView.builder(
                  buildDefaultDragHandles:false,
                  itemCount:selected.length,
                  onReorder:(a,b)=>update((){
                    if(b>a)b--; final id=selected.removeAt(a);selected.insert(b,id);
                  }),
                  itemBuilder:(listContext,i){
                    final id=selected[i];
                    MediaTitle? title;
                    for(final t in widget.repo.workspace.titles){if(t.id==id){title=t;break;}}
                    return ListTile(key:ValueKey(id),dense:true,
                      leading:ReorderableDragStartListener(index:i,child:const Icon(Icons.drag_handle_rounded)),
                      title:Text(title?.title??'Missing Library title',maxLines:1,overflow:TextOverflow.ellipsis),
                      trailing:IconButton(tooltip:'Remove from Collection',
                        onPressed:()=>update(()=>selected.removeAt(i)),icon:const Icon(Icons.remove_circle_outline_rounded)));
                  },
                )),
              const SizedBox(height:7),
              Text('Changes stay on this device until you upload them in Settings. Cloud uploads reject conflicting edits.',
                style:Theme.of(ctx).textTheme.bodySmall),
            ]))),
          actions:[
            TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Cancel')),
            FilledButton.icon(icon:const Icon(Icons.save_rounded),label:const Text('Save locally'),
              onPressed:()async{
                if(name.text.trim().isEmpty){showMessage(ctx,'Enter a Collection name.');return;}
                final id=collection?.id??'native-${DateTime.now().microsecondsSinceEpoch}';
                final next=old==null?
                  CollectionMutations.create(id,name.text,description:description.text,
                    coverUrl:cover.text,titleIds:selected):
                  CollectionMutations.revise(old,title:name.text,
                    description:description.text,coverUrl:cover.text,titleIds:selected);
                try {await widget.repo.stageCollection(next);changed=true;
                  if(ctx.mounted)Navigator.pop(ctx);
                } catch(e){if(ctx.mounted)showMessage(ctx,'Save failed: $e');}
              }),
          ],
        )));
    } finally { name.dispose(); description.dispose(); cover.dispose(); }
    if(changed && mounted) setState((){});
  }

  Future<void> _delete(MediaCollection collection) async {
    final confirmed=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(
      title:const Text('Delete Collection?'),
      content:Text('Remove “${collection.title}” from your Collections? The Library titles will remain untouched. You can review cloud edits before uploading.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Keep Collection')),
        FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Delete locally'))]));
    if(confirmed!=true)return;
    try {await widget.repo.stageCollectionDelete(collection.id);
      if(mounted)setState((){});
    } catch(e){if(mounted)showMessage(context,'Delete failed: $e');}
  }

  @override Widget build(BuildContext context) {
    final space=widget.repo.workspace;
    final titles={for(final t in space.titles)t.id:t};
    final filter=query.text.trim().toLowerCase();
    final collections=space.collections.where((c)=>c.title.toLowerCase().contains(filter)).toList();
    if(sort=='title') { collections.sort((a,b)=>a.title.toLowerCase().compareTo(b.title.toLowerCase())); }
    else if(sort=='count') { collections.sort((a,b)=>b.titleIds.length.compareTo(a.titleIds.length)); }
    else { collections.sort((a,b)=>numeric(b.raw['updatedAt']).compareTo(numeric(a.raw['updatedAt']))); }
    return Column(children:[
      Padding(padding:const EdgeInsets.fromLTRB(16,16,16,10),child:Column(children:[
        ScreenHeader(label:'Collections · Native v2',title:'Curated universes',
          subtitle:'${space.collections.length} Collections · ${widget.repo.pendingCollectionCount} staged changes',
          icon:Icons.collections_bookmark_outlined),
        const SizedBox(height:12),
        Row(children:[Expanded(child:FilledButton.icon(onPressed:()=>_edit(),
          icon:const Icon(Icons.add),label:const Text('New Collection'))),
          const SizedBox(width:9),
          IconButton.filledTonal(tooltip:'Upload pending native changes',
            onPressed:widget.repo.pendingCount==0||widget.repo.busy?null:()async{
              try{await widget.repo.uploadPendingMetadata();
                if(context.mounted)showMessage(context,'Collections and metadata synchronized.');
              }catch(e){if(context.mounted)showMessage(context,'Upload blocked: $e');}
            },icon:const Icon(Icons.cloud_upload_outlined)),
        ]),
        const SizedBox(height:10),
        TextField(controller:query,onChanged:(_)=>setState((){}),decoration:InputDecoration(
          hintText:'Search Collections',prefixIcon:const Icon(Icons.search),
          suffixIcon:query.text.isEmpty?null:IconButton(onPressed:(){query.clear();setState((){});},
            icon:const Icon(Icons.close)))),
        const SizedBox(height:8),
        SegmentedButton<String>(segments:const [ButtonSegment(value:'updated',label:Text('Recent')),
          ButtonSegment(value:'title',label:Text('A–Z')),
          ButtonSegment(value:'count',label:Text('Size'))],
          selected:{sort},onSelectionChanged:(v)=>setState(()=>sort=v.first)),
      ])),
      Expanded(child:collections.isEmpty? const Center(child:Text('No Collections match your search.')):
        ListView.builder(padding:const EdgeInsets.fromLTRB(16,3,16,24),
          itemCount:collections.length,itemBuilder:(ctx,i){
            final col=collections[i];
            final members=col.titleIds.map((id)=>titles[id]).whereType<MediaTitle>().toList();
            return Padding(padding:const EdgeInsets.only(bottom:10),child:MfCard(child:ExpansionTile(
              tilePadding:EdgeInsets.zero,childrenPadding:const EdgeInsets.only(top:8),
              leading:col.cover.isNotEmpty?TitleCover(col.cover,width:46,height:64):
                Icon(Icons.collections_bookmark,color:Theme.of(context).colorScheme.primary),
              title:Text(col.title,style:const TextStyle(fontWeight:FontWeight.w700)),
              subtitle:Text('${members.length} titles · ${col.description}',maxLines:2,
                overflow:TextOverflow.ellipsis),
              children:[
                Wrap(spacing:8,runSpacing:6,children:[
                  OutlinedButton.icon(onPressed:()=>_edit(col),icon:const Icon(Icons.edit_outlined),label:const Text('Edit')),
                  OutlinedButton.icon(onPressed:()=>_delete(col),icon:const Icon(Icons.delete_outline),label:const Text('Delete')),
                ]),
                const SizedBox(height:9),
                if(members.isEmpty)const Padding(padding:EdgeInsets.all(12),child:Text('No titles assigned.')),
                ...members.take(120).map((t)=>ListTile(dense:true,onTap:()=>widget.openTitle(t),
                  leading:TitleCover(t.cover,width:34,height:48),
                  title:Text(t.title,maxLines:2),trailing:const Icon(Icons.chevron_right_rounded))),
                if(members.length>120)Text('Showing first 120 of ${members.length} titles'),
              ],
            )));
          })),
    ]);
  }
}

class _CollectionTitlePicker extends StatefulWidget {
  final List<MediaTitle> titles;
  final Set<String> selected;
  const _CollectionTitlePicker({required this.titles,required this.selected});
  @override State<_CollectionTitlePicker> createState()=>_CollectionTitlePickerState();
}
class _CollectionTitlePickerState extends State<_CollectionTitlePicker> {
  final query=TextEditingController();
  @override void dispose(){query.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    final q=query.text.trim().toLowerCase();
    final matches=widget.titles.where((t)=>!widget.selected.contains(t.id)&&
      (q.isEmpty||t.title.toLowerCase().contains(q))).take(120).toList();
    return SafeArea(child:FractionallySizedBox(heightFactor:.82,child:Column(children:[
      Padding(padding:const EdgeInsets.all(15),child:Column(children:[
        Text('Add Library title',style:Theme.of(context).textTheme.titleLarge),
        const SizedBox(height:12),TextField(controller:query,autofocus:true,
          onChanged:(_)=>setState((){}),decoration:const InputDecoration(
          hintText:'Search up to 50,000 titles',prefixIcon:Icon(Icons.search))),
      ])),
      Expanded(child:ListView.builder(itemCount:matches.length,itemBuilder:(ctx,i){
        final t=matches[i];return ListTile(onTap:()=>Navigator.pop(context,t),
          leading:TitleCover(t.cover,width:36,height:49),title:Text(t.title,maxLines:2),
          trailing:const Icon(Icons.add_circle_outline));
      })),
    ])));
  }
}

class OrderPage extends StatefulWidget {
  final MediaFlowRepository repo;
  final void Function(MediaTitle) openTitle;
  const OrderPage({super.key,required this.repo,required this.openTitle});
  @override State<OrderPage> createState()=>_OrderPageState();
}
class _OrderPageState extends State<OrderPage> {
  Future<void> _add() async {
    final existing=widget.repo.workspace.orderedIds.toSet();
    final picked=await showModalBottomSheet<MediaTitle>(context:context,
      isScrollControlled:true,showDragHandle:true,
      builder:(ctx)=>_CollectionTitlePicker(
        titles:widget.repo.workspace.titles,selected:existing));
    if(picked==null)return;
    try {
      await widget.repo.stageDirectOrder([...widget.repo.workspace.orderedIds,picked.id]);
      if(mounted)setState((){});
    }catch(e){if(mounted)showMessage(context,'Order update failed: $e');}
  }
  Future<void> _reorder(int from,int to) async {
    final ids=List<String>.from(widget.repo.workspace.orderedIds);
    if(to>from)to--;
    final moved=ids.removeAt(from);ids.insert(to,moved);
    try{
      await widget.repo.stageDirectOrder(ids);
      if(mounted)setState((){});
    }catch(e){if(mounted)showMessage(context,'Reorder failed: $e');}
  }
  Future<void> _remove(String id) async {
    final ids=List<String>.from(widget.repo.workspace.orderedIds)..remove(id);
    try{
      await widget.repo.stageDirectOrder(ids);
      if(mounted)setState((){});
    }catch(e){if(mounted)showMessage(context,'Remove failed: $e');}
  }
  @override Widget build(BuildContext context) {
    final space=widget.repo.workspace;
    final ids=space.orderedIds;
    final byId={for(final t in space.titles)t.id:t};
    final width=MediaQuery.sizeOf(context).width;
    return Column(children:[
      Padding(padding:const EdgeInsets.all(16),child:Column(children:[
        ScreenHeader(label:'Personal Order · direct titles',title:'Your sequence',
          subtitle:'${ids.length} direct titles · Assigned Collection queues preserved',
          icon:Icons.format_list_numbered_rounded),
        const SizedBox(height:12),
        Row(children:[
          Expanded(child:FilledButton.icon(onPressed:_add,
            icon:const Icon(Icons.add),label:const Text('Add title'))),
          const SizedBox(width:8),
          MfBadge(widget.repo.pendingOrderChanges?'Order unsynced':'Cloud order',icon:Icons.reorder),
        ]),
        const SizedBox(height:8),
        const Text('Drag the handle to reorder direct titles. Native changes remain local until uploaded in Settings. Website Collection assignments and per-category queues remain untouched.',style:TextStyle(fontSize:12)),
      ])),
      Expanded(child:ids.isEmpty?const Center(child:Text('No direct titles. Add one from your Library.')):
        ReorderableListView.builder(
          buildDefaultDragHandles:false,
          padding:const EdgeInsets.fromLTRB(12,0,12,18),
          itemCount:ids.length,onReorder:_reorder,
          itemBuilder:(ctx,index){
            final id=ids[index],title=byId[id];
            return Padding(key:ValueKey(id),padding:const EdgeInsets.only(bottom:8),
              child:MfCard(padding:const EdgeInsets.symmetric(horizontal:9,vertical:6),
                child:Row(children:[
                  ReorderableDragStartListener(index:index,child:const Padding(
                    padding:EdgeInsets.symmetric(horizontal:3),child:Icon(Icons.drag_handle))),
                  const SizedBox(width:5),
                  Text('${index+1}.',style:const TextStyle(fontWeight:FontWeight.w600)),
                  const SizedBox(width:8),
                  if(title!=null)TitleCover(title.cover,width:40,height:56),
                  const SizedBox(width:10),
                  Expanded(child:InkWell(onTap:title==null?null:()=>widget.openTitle(title),
                    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                      Text(title?.title??'Title unavailable',maxLines:2,
                        overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.w600)),
                      if(title!=null)Text('${title.status} · ${title.progress}${title.total>0?'/${title.total}':''}',
                        style:Theme.of(context).textTheme.labelSmall),
                    ]))),
                  IconButton(tooltip:'Remove from Personal Order',icon:const Icon(Icons.remove_circle_outline),
                    onPressed:()=>_remove(id)),
                  if(width>550)const Icon(Icons.chevron_right,size:18),
                ])));

          },
        )),
    ]);
  }
}

class HistoryPage extends StatefulWidget {
  final MediaFlowRepository repo;
  const HistoryPage({super.key, required this.repo});
  @override State<HistoryPage> createState() => _HistoryPageState();
}
class _HistoryPageState extends State<HistoryPage> {
  final search = TextEditingController();
  String category = 'all';
  String ordering = 'newest';
  @override void dispose() {search.dispose();super.dispose();}
  @override Widget build(BuildContext context) {
    final space=widget.repo.workspace;
    final all=space.sessions;
    final query=search.text.trim().toLowerCase();
    final history=all.where((session){
      if(category!='all'&&session.categoryId!=category) return false;
      if(query.isEmpty)return true;
      if(session.title.toLowerCase().contains(query)||session.note.toLowerCase().contains(query))return true;
      return asObjects(session.raw['titles']).any((t)=>
        plain(t['title']).toLowerCase().contains(query)||
        plain(t['libraryId']).toLowerCase().contains(query));
    }).toList();
    history.sort((a,b)=>ordering=='oldest'?a.timestamp.compareTo(b.timestamp):b.timestamp.compareTo(a.timestamp));
    return Column(children:[
      Padding(padding:const EdgeInsets.fromLTRB(16,16,16,10),child:Column(children:[
        ScreenHeader(label:'Consumption History',title:'Every session matters',
          subtitle:'${history.length} of ${all.length} sessions · Website records preserved',icon:Icons.history_rounded),
        const SizedBox(height:12),
        TextField(controller:search,onChanged:(_)=>setState((){}),
          decoration:InputDecoration(prefixIcon:const Icon(Icons.search),
            hintText:'Search titles and notes',suffixIcon:search.text.isEmpty?null:
            IconButton(onPressed:(){search.clear();setState((){});},icon:const Icon(Icons.close)))),
        const SizedBox(height:9),
        Row(children:[
          Expanded(child:DropdownButtonFormField<String>(initialValue:category,
            isExpanded:true,decoration:const InputDecoration(labelText:'Category',isDense:true),
            items:[const DropdownMenuItem(value:'all',child:Text('All categories')),
              ...space.categories.map((cat)=>DropdownMenuItem(value:cat.id,
                child:Text(cat.name,overflow:TextOverflow.ellipsis)))],
            onChanged:(v)=>setState(()=>category=v??'all'))),
          const SizedBox(width:8),
          Expanded(child:DropdownButtonFormField<String>(initialValue:ordering,
            isExpanded:true,decoration:const InputDecoration(labelText:'Sort',isDense:true),
            items:const [DropdownMenuItem(value:'newest',child:Text('Newest first')),
              DropdownMenuItem(value:'oldest',child:Text('Oldest first'))],
            onChanged:(v)=>setState(()=>ordering=v??'newest'))),
        ]),
      ])),
      Expanded(child:history.isEmpty?const Center(child:Text('No History sessions match your filters.')):
      ListView.builder(itemCount:history.length,padding:const EdgeInsets.fromLTRB(16,0,16,24),
        itemBuilder:(ctx,i){
          final session=history[i];
          final titles=asObjects(session.raw['titles']);
          final label=titles.map((e)=>plain(e['title'])).where((e)=>e.isNotEmpty).take(3).join(', ');
          final date=session.date.isNotEmpty?session.date:
            session.timestamp>0?DateFormat('MMM d, yyyy').format(
              DateTime.fromMillisecondsSinceEpoch(session.timestamp)):'Unknown date';
          final units=titles.fold<int>(0,(sum,t)=>sum+asObjects(t['v369Units']).length);
          final duration=numeric(session.raw['v369DurationSeconds']);
          return Padding(padding:const EdgeInsets.only(bottom:10),child:MfCard(child:ExpansionTile(
            tilePadding:EdgeInsets.zero,childrenPadding:EdgeInsets.zero,
            title:Text(label.isEmpty?session.title:label,
              maxLines:2,overflow:TextOverflow.ellipsis,
              style:const TextStyle(fontWeight:FontWeight.w700)),
            subtitle:Padding(padding:const EdgeInsets.only(top:7),
              child:Wrap(spacing:6,runSpacing:6,children:[
                MfBadge(date,icon:Icons.calendar_today_outlined),
                MfBadge('${session.amount} ${session.unit.isEmpty?'units':session.unit}',icon:Icons.list_alt_rounded),
                MfBadge(duration>0?'${(duration/60).toStringAsFixed(1)}m':
                  '${session.minutes}m',icon:Icons.timer_outlined),
                if(units>0)MfBadge('$units detailed units',icon:Icons.format_list_numbered_rounded),
              ])),
            children:[
              if(session.note.isNotEmpty)Padding(padding:const EdgeInsets.fromLTRB(8,10,8,6),child:
                Text(session.note,style:Theme.of(ctx).textTheme.bodySmall)),
              ...titles.map((title){
                final itemUnits=asObjects(title['v369Units']);
                return Padding(padding:const EdgeInsets.only(bottom:6),child:Column(
                  crossAxisAlignment:CrossAxisAlignment.start,children:[
                    ListTile(dense:true,contentPadding:EdgeInsets.zero,
                      title:Text(plain(title['title'],'Logged title'),style:const TextStyle(fontWeight:FontWeight.w600)),
                      subtitle:Text('${numeric(title['qty']).toInt()} units · ${itemUnits.length} detailed entries')),
                    for(final u in itemUnits.take(100)) Padding(padding:const EdgeInsets.fromLTRB(12,0,0,7),
                      child:Row(children:[
                        Icon(u['isRepeat']==true?Icons.repeat_rounded:Icons.check_circle_outline,
                          size:16,color:Theme.of(ctx).colorScheme.primary),const SizedBox(width:8),
                        Expanded(child:Text('Unit ${plain(u['number'],'?')} · ${_formatTimestamp(u['loggedAt'])}',
                          maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:12))),
                        Text(_unitRuntime(u),style:const TextStyle(fontSize:12,fontWeight:FontWeight.bold)),
                      ])),
                    if(itemUnits.length>100)Text('First 100 of ${itemUnits.length} detailed units shown',
                      style:Theme.of(ctx).textTheme.bodySmall),
                  ]));
              }),
            ],
          )));
        })),
    ]);
  }
  static String _formatTimestamp(dynamic raw){
    if(raw==null)return 'Unknown time';
    final value=raw is num?raw.toInt():int.tryParse(raw.toString());
    final date=value!=null?DateTime.fromMillisecondsSinceEpoch(value):DateTime.tryParse(raw.toString());
    return date==null?raw.toString():DateFormat('MMM d, yyyy · HH:mm').format(date);
  }
  static String _unitRuntime(Map<String,dynamic> unit){
    final s=numeric(unit['durationSeconds']).toInt();
    if(s>0) return '${s ~/ 3600}h ${(s % 3600) ~/ 60}m ${s%60}s';
    final h=numeric(unit['hours']).toInt(),m=numeric(unit['minutes']).toInt(),sec=numeric(unit['seconds']).toInt();
    return '${h}h ${m}m ${sec}s';
  }
}

class StatisticsPage extends StatelessWidget {
  final MediaFlowRepository repo;
  const StatisticsPage({super.key,required this.repo});
  @override Widget build(BuildContext context) {
    final space=repo.workspace;
    final statuses=<String,int>{};
    final byCategory=<String,int>{};
    for(final t in space.titles){
      statuses[t.status]=(statuses[t.status]??0)+1;
      byCategory[t.categoryId]=(byCategory[t.categoryId]??0)+1;
    }
    final ordered=byCategory.entries.toList()..sort((a,b)=>b.value.compareTo(a.value));
    return ListView(padding:const EdgeInsets.all(16),children:[
      ScreenHeader(label:'Statistics',title:'Your media in numbers',subtitle:'Native insights from the live MediaFlow snapshot',icon:Icons.insights_rounded),
      const SizedBox(height:16),
      Text('Library statuses',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w700)),
      const SizedBox(height:9),
      for(final e in statuses.entries)...[
        MfCard(child:Row(children:[Icon(statusIcon(e.key),color:statusColor(e.key,Theme.of(context).colorScheme.primary)),
          const SizedBox(width:12),Expanded(child:Text(e.key)),Text(NumberFormat.decimalPattern().format(e.value),style:const TextStyle(fontWeight:FontWeight.w700))])),
        const SizedBox(height:7),
      ],
      const SizedBox(height:15),
      Text('Top categories',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w700)),
      const SizedBox(height:9),
      for(final e in ordered.take(18)) ...[
        MfCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Row(children:[Expanded(child:Text(space.categoryFor(e.key)?.name??'Other')),
            Text(NumberFormat.decimalPattern().format(e.value),style:const TextStyle(fontWeight:FontWeight.w700))]),
          const SizedBox(height:9),
          LinearProgressIndicator(value:space.titles.isEmpty?0:e.value/space.titles.length,
            borderRadius:BorderRadius.circular(4),minHeight:5),
        ])),const SizedBox(height:7),
      ],
    ]);
  }
}
