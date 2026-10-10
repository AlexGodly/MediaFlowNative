import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mediaflow_repository.dart';
import '../data/mediaflow_snapshot.dart';
import '../data/models.dart';
import '../data/collection_mutations.dart';
import 'design.dart';

class DashboardPage extends StatelessWidget {
  final MediaFlowRepository repo;
  final void Function(MediaTitle) openTitle;
  const DashboardPage({super.key, required this.repo, required this.openTitle});
  @override
  Widget build(BuildContext context) {
    final data = repo.workspace;
    final titles = data.titles;
    final sessions = data.sessions;
    final active = titles.where((t) => ['watching','reading','active'].contains(t.status)).take(6).toList();
    final completed = titles.where((t) => t.status == 'completed').length;
    final width = MediaQuery.sizeOf(context).width;
    return ListView(padding: const EdgeInsets.all(18), children: [
      const ScreenHeader(label:'MediaFlow Native · v2',title:'Your media, in motion.',
        subtitle:'One Library. Every device. Your existing MediaFlow account.',icon:Icons.auto_awesome_rounded),
      const SizedBox(height: 15),
      GridView.count(shrinkWrap:true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: width < 650 ? 3 : 4, childAspectRatio: width < 400 ? .87 : 1.35,
        crossAxisSpacing: 9, mainAxisSpacing: 9, children: [
          MfMetric(icon:Icons.library_books_outlined,label:'Library',value:NumberFormat.compact().format(titles.length)),
          MfMetric(icon:Icons.task_alt_outlined,label:'Completed',value:NumberFormat.compact().format(completed)),
          MfMetric(icon:Icons.history_rounded,label:'Sessions',value:NumberFormat.compact().format(sessions.length)),
          if (width >= 650) MfMetric(icon:Icons.collections_bookmark_outlined,label:'Collections',value:'${data.collections.length}'),
        ]),
      const SizedBox(height: 22),
      Row(children:[const Icon(Icons.play_circle_outline_rounded,size:20), const SizedBox(width:8),
        Text('Continue your journey',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w700))]),
      const SizedBox(height: 12),
      if (active.isEmpty) const MfCard(child:Text('Your active Library titles will appear here after you sign in.')),
      for (final title in active) ...[
        MfCard(padding:const EdgeInsets.all(11),child: InkWell(
          borderRadius:BorderRadius.circular(12),onTap:()=>openTitle(title),
          child:Row(children:[
            TitleCover(title.cover,width:54,height:74), const SizedBox(width:13),
            Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text(title.title,maxLines:2,overflow:TextOverflow.ellipsis,
                style:const TextStyle(fontWeight:FontWeight.w700,fontSize:14)),
              const SizedBox(height:5),
              Text('${title.progress}${title.total > 0 ? ' / ${title.total}' : ''} units',
                style:Theme.of(context).textTheme.bodySmall),
              const SizedBox(height:6),
              LinearProgressIndicator(value:title.total>0?(title.progress/title.total).clamp(0.0,1.0):0,
                minHeight:4,borderRadius:BorderRadius.circular(3)),
            ])),const SizedBox(width:5),const Icon(Icons.chevron_right_rounded,size:20),
          ]))),
        const SizedBox(height: 9),
      ],
      const SizedBox(height: 18),
      MfCard(child: Row(children:[
        Icon(Icons.shield_outlined,color:Theme.of(context).colorScheme.primary), const SizedBox(width:12),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('Connected to your existing account',style:TextStyle(fontWeight:FontWeight.w700)),
          const SizedBox(height:3),
          Text('This native app reads the same Supabase workspace as the website. Advanced logging and XP writes stay protected during the initial port.',
            style:Theme.of(context).textTheme.bodySmall),
        ])),
      ])),
    ]);
  }
}

class LibraryPage extends StatefulWidget {
  final MediaFlowRepository repo;
  final void Function(MediaTitle) openTitle;
  const LibraryPage({super.key,required this.repo,required this.openTitle});
  @override State<LibraryPage> createState()=>_LibraryPageState();
}
class _LibraryPageState extends State<LibraryPage> {
  final query=TextEditingController();
  String status='all', category='all';
  bool grid=false;
  @override void dispose(){query.dispose();super.dispose();}
  @override Widget build(BuildContext context) {
    final space=widget.repo.workspace;
    final all=space.titles;
    final search=query.text.trim().toLowerCase();
    final visible=all.where((t)=>(search.isEmpty || t.title.toLowerCase().contains(search)) &&
      (status=='all' || t.status==status) && (category=='all'||t.categoryId==category)).toList();
    final statuses=all.map((x)=>x.status).toSet().toList()..sort();
    final categories=space.categories;
    return Column(children:[
      Padding(padding:const EdgeInsets.fromLTRB(16,16,16,8),child:Column(children:[
        ScreenHeader(label:'Library',title:'Every story, one place',
          subtitle:'${NumberFormat.decimalPattern().format(all.length)} titles · ${NumberFormat.decimalPattern().format(visible.length)} shown',icon:Icons.grid_view_rounded),
        const SizedBox(height:12),
        TextField(controller:query,onChanged:(_)=>setState((){}),
          decoration:InputDecoration(prefixIcon:const Icon(Icons.search),hintText:'Search your titles',
            suffixIcon:query.text.isEmpty?null:IconButton(icon:const Icon(Icons.close),onPressed:(){query.clear();setState((){});}))),
        const SizedBox(height:9),
        Row(children:[
          Expanded(child:DropdownButtonFormField<String>(initialValue:status,isExpanded:true,
            decoration:const InputDecoration(labelText:'Status',isDense:true),
            items:[const DropdownMenuItem(value:'all',child:Text('All statuses')),
              ...statuses.map((s)=>DropdownMenuItem(value:s,child:Text(s,overflow:TextOverflow.ellipsis)))],
            onChanged:(v)=>setState(()=>status=v??'all'))),
          const SizedBox(width:8),
          Expanded(child:DropdownButtonFormField<String>(initialValue:category,isExpanded:true,
            decoration:const InputDecoration(labelText:'Category',isDense:true),
            items:[const DropdownMenuItem(value:'all',child:Text('All categories')),
              ...categories.map((c)=>DropdownMenuItem(value:c.id,child:Text(c.name,overflow:TextOverflow.ellipsis)))],
            onChanged:(v)=>setState(()=>category=v??'all'))),
          IconButton(tooltip:grid?'List view':'Grid view',
            onPressed:()=>setState(()=>grid=!grid),
            icon:Icon(grid?Icons.view_list_rounded:Icons.grid_view_rounded)),
        ]),
      ])),
      Expanded(child:visible.isEmpty? const Center(child:Text('No titles match your search.')):
        grid ? LayoutBuilder(builder:(context, constraints){
          final count=(constraints.maxWidth/175).floor().clamp(2,7);
          return GridView.builder(padding:const EdgeInsets.all(14),
            gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:count,crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:.65),
            itemCount:visible.length,itemBuilder:(ctx,index){
              final t=visible[index];
              return InkWell(onTap:()=>widget.openTitle(t),child:MfCard(padding:const EdgeInsets.all(8),
                child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                  Expanded(child:SizedBox(width:double.infinity,child:FittedBox(fit:BoxFit.contain,child:TitleCover(t.cover,width:95,height:132)))),
                  const SizedBox(height:8),
                  Text(t.title,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.w600,fontSize:12)),
                  const SizedBox(height:4),
                  Text('${t.progress}${t.total>0?'/ ${t.total}':''}',style:Theme.of(ctx).textTheme.labelSmall),
                ])));
            });
        }): ListView.builder(padding:const EdgeInsets.fromLTRB(14,5,14,18),
          itemCount:visible.length,itemExtent:103,itemBuilder:(context,index){
            final t=visible[index];
            return Padding(padding:const EdgeInsets.only(bottom:8),child:MfCard(padding:const EdgeInsets.symmetric(horizontal:10,vertical:8),
              child:InkWell(onTap:()=>widget.openTitle(t),child:Row(children:[
                TitleCover(t.cover,width:55,height:76),const SizedBox(width:11),
                Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,
                  mainAxisAlignment:MainAxisAlignment.center,children:[
                    Text(t.title,maxLines:2,overflow:TextOverflow.ellipsis,
                      style:const TextStyle(fontWeight:FontWeight.w700,fontSize:13)),
                    const SizedBox(height:6),
                    Text('${space.categoryFor(t.categoryId)?.name??'Category'}  ·  ${t.progress}${t.total>0?'/ ${t.total}':''}',
                      maxLines:1,overflow:TextOverflow.ellipsis,style:Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height:5),
                    Wrap(spacing:5,children:[MfBadge(t.status,icon:statusIcon(t.status),
                      color:statusColor(t.status,Theme.of(context).colorScheme.primary)),
                      if (t.priority=='high') const MfBadge('High priority',icon:Icons.flag_outlined,color:Color(0xFFED859B))]),
                  ])),
                const Icon(Icons.chevron_right_rounded,size:17),
              ]))));
          }),
      ),
    ]);
  }
}

Future<void> showTitleDetails(BuildContext context, MediaFlowRepository repo, MediaTitle title) async {
  final updated=repo.workspace.titles.where((x)=>x.id==title.id);
  if(updated.isEmpty)return;
  final item=updated.first;
  final space=repo.workspace;
  final cover=TextEditingController(text:item.cover);
  final tags=TextEditingController(text:item.tags.join(', '));
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
          Text('Native v1 safely edits cover, priority and tags. Progress, status, XP and logs still use the website.',
            style:Theme.of(ctx).textTheme.bodySmall),
          const SizedBox(height:12),
          TextField(controller:cover,decoration:const InputDecoration(labelText:'Cover URL')),
          const SizedBox(height:10),
          DropdownButtonFormField<String>(initialValue:priority,decoration:const InputDecoration(labelText:'Priority'),
            items:const ['low','medium','high'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),
            onChanged:(v)=>setDialog(()=>priority=v??priority)),
          const SizedBox(height:10),
          TextField(controller:tags,decoration:const InputDecoration(labelText:'Tags (comma-separated)')),
        ]))),
      actions:[
        TextButton(onPressed:()=>Navigator.of(ctx).pop(),child:const Text('Close')),
        FilledButton.icon(icon:const Icon(Icons.save_outlined),label:const Text('Save locally'),
          onPressed:()async{
            await repo.stageTitleMetadata(item.id,coverUrl:cover.text,priority:priority,
              tags:tags.text.split(',').map((e)=>e.trim()).where((e)=>e.isNotEmpty).toList());
            edited=true;
            if(ctx.mounted)Navigator.of(ctx).pop();
          }),
      ],
    )));
  cover.dispose();tags.dispose();
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

class OrderPage extends StatelessWidget {
  final MediaFlowRepository repo;
  final void Function(MediaTitle) openTitle;
  const OrderPage({super.key,required this.repo,required this.openTitle});
  @override Widget build(BuildContext context) {
    final space=repo.workspace;
    final ids=space.orderedIds;
    final byId={for(final title in space.titles)title.id:title};
    return Column(children:[
      Padding(padding:const EdgeInsets.all(16),child:ScreenHeader(
        label:'Personal Order',title:'Your own sequence',
        subtitle:'${ids.length} direct title positions · Existing web order preserved',icon:Icons.format_list_numbered_rounded)),
      Expanded(child:ListView.builder(itemCount:ids.length,itemBuilder:(ctx,index){
        final title=byId[ids[index]];
        if(title==null)return const SizedBox.shrink();
        return Padding(padding:const EdgeInsets.fromLTRB(16,0,16,8),child:MfCard(padding:const EdgeInsets.all(10),
          child:ListTile(onTap:()=>openTitle(title),contentPadding:EdgeInsets.zero,
            leading:TitleCover(title.cover,width:42,height:60),
            title:Text('${index+1}. ${title.title}',maxLines:2),
            subtitle:Text('${title.status}  ·  ${title.progress} ${title.total>0?'/ ${title.total}':''}'),
            trailing:const Icon(Icons.chevron_right_rounded))));
      })),
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
