import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mediaflow_repository.dart';
import '../data/mediaflow_snapshot.dart';
import '../data/models.dart';
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
      const ScreenHeader(label:'MediaFlow Native · v1',title:'Your media, in motion.',
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
              ])))));
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

class CollectionsPage extends StatelessWidget {
  final MediaFlowRepository repo;
  final void Function(MediaTitle) openTitle;
  const CollectionsPage({super.key,required this.repo,required this.openTitle});
  @override Widget build(BuildContext context) {
    final space=repo.workspace;
    final all=space.collections;
    final byId={for (final t in space.titles)t.id:t};
    return ListView(padding:const EdgeInsets.all(16),children:[
      ScreenHeader(label:'Collections',title:'Curated universes',
        subtitle:'${all.length} collections from your existing MediaFlow account',icon:Icons.collections_bookmark_outlined),
      const SizedBox(height:15),
      if(all.isEmpty)const MfCard(child:Text('No Collections found in your account.')),
      ...all.map((col){
        final titles=col.titleIds.map((id)=>byId[id]).whereType<MediaTitle>().toList();
        return Padding(padding:const EdgeInsets.only(bottom:10),child:MfCard(child:ExpansionTile(
          tilePadding:EdgeInsets.zero,childrenPadding:const EdgeInsets.only(top:10),
          leading:col.cover.isNotEmpty?TitleCover(col.cover,width:46,height:62):
            Icon(Icons.collections_bookmark_rounded,color:Theme.of(context).colorScheme.primary),
          title:Text(col.title,style:const TextStyle(fontWeight:FontWeight.w700)),
          subtitle:Text('${titles.length} titles${col.description.isEmpty?'':' · ${col.description}'}',maxLines:2,overflow:TextOverflow.ellipsis),
          children:[
            if(titles.isEmpty)const Padding(padding:EdgeInsets.all(12),child:Text('No assigned titles.')),
            ...titles.take(300).map((t)=>ListTile(dense:true,onTap:()=>openTitle(t),
              leading:TitleCover(t.cover,width:34,height:48),title:Text(t.title,maxLines:2),
              trailing:const Icon(Icons.chevron_right_rounded))),
            if(titles.length>300)Text('Showing the first 300 of ${titles.length} entries'),
          ],
        )));
      }),
    ]);
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

class HistoryPage extends StatelessWidget {
  final MediaFlowRepository repo;
  const HistoryPage({super.key,required this.repo});
  @override Widget build(BuildContext context) {
    final logs=repo.workspace.sessions.toList()..sort((a,b)=>b.timestamp.compareTo(a.timestamp));
    return Column(children:[
      Padding(padding:const EdgeInsets.all(16),child:ScreenHeader(label:'Consumption History',title:'Every session matters',
        subtitle:'${logs.length} records from your existing account',icon:Icons.history_rounded)),
      Expanded(child:ListView.builder(itemCount:logs.length,itemBuilder:(ctx,index){
        final session=logs[index];
        final names=asObjects(session.raw['titles']).map((e)=>plain(e['title'])).where((e)=>e.isNotEmpty).take(3).join(', ');
        final date=session.date.isNotEmpty?session.date:
          session.timestamp>0?DateFormat('MMM d, yyyy').format(DateTime.fromMillisecondsSinceEpoch(session.timestamp)):'Unknown date';
        return Padding(padding:const EdgeInsets.fromLTRB(16,0,16,9),child:MfCard(child:Column(
          crossAxisAlignment:CrossAxisAlignment.start,children:[
            Row(children:[Icon(Icons.check_circle_outline_rounded,color:Theme.of(ctx).colorScheme.primary,size:20),
              const SizedBox(width:8),Expanded(child:Text(names.isEmpty?session.title:names,maxLines:2,
                overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.w700)))]),
            const SizedBox(height:10),
            Wrap(spacing:6,runSpacing:6,children:[
              MfBadge(date,icon:Icons.calendar_today_outlined),
              MfBadge('${session.amount} ${session.unit.isEmpty?'units':session.unit}',icon:Icons.list_alt_rounded),
              MfBadge('${session.minutes}m',icon:Icons.schedule),
            ]),
            if(session.note.isNotEmpty)...[const SizedBox(height:8),Text(session.note,style:Theme.of(ctx).textTheme.bodySmall)],
          ])));
      })),
    ]);
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
