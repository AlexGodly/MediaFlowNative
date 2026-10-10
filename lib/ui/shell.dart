import 'package:flutter/material.dart';
import '../data/mediaflow_repository.dart';
import '../data/models.dart';
import 'design.dart';
import 'pages.dart';
import 'logging.dart';

class NativeShell extends StatefulWidget {
  final MediaFlowRepository repo;
  final VoidCallback signOut;
  final bool dark;
  final ValueChanged<bool> changeAppearance;
  const NativeShell({super.key,required this.repo,required this.signOut,
    required this.dark,required this.changeAppearance});
  @override State<NativeShell> createState()=>_NativeShellState();
}
class _NativeShellState extends State<NativeShell> {
  int page=0, more=0;
  void _open(MediaTitle title)=>showTitleDetails(context,widget.repo,title);
  @override Widget build(BuildContext context){
    final desktop=MediaQuery.sizeOf(context).width>=830;
    final workspace=widget.repo.workspace;
    final pages=<Widget>[
      DashboardPage(repo:widget.repo,openTitle:_open),
      LibraryPage(repo:widget.repo,openTitle:_open),
      NativeLoggingPage(repo:widget.repo),
      CollectionsPage(repo:widget.repo,openTitle:_open),
      OrderPage(repo:widget.repo,openTitle:_open),
      HistoryPage(repo:widget.repo),
      StatisticsPage(repo:widget.repo),
      AccountPage(repo:widget.repo,signOut:widget.signOut,dark:widget.dark,
        changeAppearance:widget.changeAppearance),
    ];
    final contents=desktop?pages[page]:page<4?pages[page]:_moreView(pages);
    return Scaffold(
      appBar:AppBar(toolbarHeight:64,titleSpacing:16,
        title:Row(children:[
          Image.asset('assets/mediaflow.png',width:32,height:32),const SizedBox(width:9),
          const Text('MediaFlow',style:TextStyle(fontWeight:FontWeight.w800,fontSize:19)),
          const SizedBox(width:8),
          Text('NATIVE',style:TextStyle(fontSize:9,letterSpacing:1.5,fontWeight:FontWeight.w800,
            color:Theme.of(context).colorScheme.primary)),
        ]),actions:[
          if(widget.repo.pendingCount>0)Padding(padding:const EdgeInsets.symmetric(horizontal:4),
            child:Center(child:MfBadge('${widget.repo.pendingCount} local edits',icon:Icons.cloud_upload_outlined))),
          IconButton(tooltip:'Refresh from Supabase',onPressed:widget.repo.busy?null:widget.repo.refresh,
            icon:const Icon(Icons.sync_rounded)),
          const SizedBox(width:6),
        ]),
      body:Row(children:[
        if(desktop)NavigationRail(
          minWidth:72,extended:MediaQuery.sizeOf(context).width>=1160,
          selectedIndex:page,
          onDestinationSelected:(i)=>setState(()=>page=i),
          backgroundColor:Theme.of(context).colorScheme.surface,
          destinations:const [
            NavigationRailDestination(icon:Icon(Icons.dashboard_outlined),selectedIcon:Icon(Icons.dashboard),label:Text('Dashboard')),
            NavigationRailDestination(icon:Icon(Icons.library_books_outlined),selectedIcon:Icon(Icons.library_books),label:Text('Library')),
            NavigationRailDestination(icon:Icon(Icons.bolt_outlined),selectedIcon:Icon(Icons.bolt),label:Text('Logging')),
            NavigationRailDestination(icon:Icon(Icons.collections_bookmark_outlined),selectedIcon:Icon(Icons.collections_bookmark),label:Text('Collections')),
            NavigationRailDestination(icon:Icon(Icons.format_list_numbered),label:Text('Personal Order')),
            NavigationRailDestination(icon:Icon(Icons.history),label:Text('History')),
            NavigationRailDestination(icon:Icon(Icons.insights),label:Text('Statistics')),
            NavigationRailDestination(icon:Icon(Icons.settings_outlined),label:Text('Settings')),
          ]),
        Expanded(child:Column(children:[
          if(widget.repo.error!=null)MaterialBanner(
            content:Text(widget.repo.error!,maxLines:3,overflow:TextOverflow.ellipsis,
              style:const TextStyle(fontSize:12)),
            leading:const Icon(Icons.info_outline),actions:[TextButton(onPressed:widget.repo.refresh,
              child:const Text('Retry'))]),
          if(widget.repo.busy)const LinearProgressIndicator(minHeight:2),
          Expanded(child:KeyedSubtree(key:ValueKey('${desktop?'desktop':'mobile'}-$page-$more'),
            child:workspace.titles.isEmpty && !widget.repo.hasData?
              _empty():contents)),
        ])),
      ]),
      bottomNavigationBar:desktop?null:NavigationBar(
        selectedIndex:page,onDestinationSelected:(i)=>setState(()=>page=i),
        destinations:const [
          NavigationDestination(icon:Icon(Icons.dashboard_outlined),selectedIcon:Icon(Icons.dashboard),label:'Home'),
          NavigationDestination(icon:Icon(Icons.library_books_outlined),selectedIcon:Icon(Icons.library_books),label:'Library'),
          NavigationDestination(icon:Icon(Icons.bolt_outlined),selectedIcon:Icon(Icons.bolt),label:'Logging'),
          NavigationDestination(icon:Icon(Icons.collections_bookmark_outlined),selectedIcon:Icon(Icons.collections_bookmark),label:'Collections'),
          NavigationDestination(icon:Icon(Icons.more_horiz),label:'More'),
        ]),
    );
  }
  Widget _empty()=>Center(child:Padding(padding:const EdgeInsets.all(22),
    child:MfCard(child:Column(mainAxisSize:MainAxisSize.min,children:[
      Icon(Icons.cloud_off_outlined,size:44,color:Theme.of(context).colorScheme.primary),
      const SizedBox(height:12),const Text('No workspace loaded yet.'),
      const SizedBox(height:8),const Text('Sign in to an existing MediaFlow account and refresh your cloud Library.'),
      const SizedBox(height:12),FilledButton(onPressed:widget.repo.refresh,child:const Text('Retry cloud load')),
    ]))));
  Widget _moreView(List<Widget> pages)=>Column(children:[
    Padding(padding:const EdgeInsets.fromLTRB(12,10,12,6),child:SingleChildScrollView(
      scrollDirection:Axis.horizontal,child:Row(children:[
        for(var i=0;i<4;i++)Padding(padding:const EdgeInsets.only(right:6),child:ChoiceChip(
          label:Text(['Personal Order','History','Statistics','Settings'][i]),
          selected:more==i,onSelected:(_)=>setState(()=>more=i))),
      ]))),
    Expanded(child:pages[more+4]),
  ]);
}

class AccountPage extends StatelessWidget {
  final MediaFlowRepository repo;
  final VoidCallback signOut;
  final bool dark;
  final ValueChanged<bool> changeAppearance;
  const AccountPage({super.key,required this.repo,required this.signOut,
    required this.dark,required this.changeAppearance});
  @override Widget build(BuildContext context){
    final user=repo.client.auth.currentUser;
    final settings=repo.workspace.settings;
    return ListView(padding:const EdgeInsets.all(16),children:[
      ScreenHeader(label:'Account & settings',title:'Your workspace',
        subtitle:'Native preferences and the existing MediaFlow cloud',icon:Icons.tune_rounded),
      const SizedBox(height:13),
      MfCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(user?.email??'Account',style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.bold)),
        const SizedBox(height:5),
        const Text('Same Supabase authentication as the website.'),
        const SizedBox(height:9),
        Wrap(spacing:7,runSpacing:7,children:[
          MfBadge(repo.cloudConnected?'Cloud connected':'Offline cache',
            icon:repo.cloudConnected?Icons.cloud_done_outlined:Icons.cloud_off_outlined),
          MfBadge('${repo.pendingCount} pending metadata edits',icon:Icons.edit_note_rounded),
        ]),
      ])),
      const SizedBox(height:12),
      MfCard(child:Column(children:[
        SwitchListTile.adaptive(contentPadding:EdgeInsets.zero,
          secondary:const Icon(Icons.dark_mode_outlined),title:const Text('Dark appearance'),
          subtitle:const Text('Native preview; follows the account theme on startup.'),
          value:dark,onChanged:changeAppearance),
        const Divider(),
        ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.palette_outlined),
          title:const Text('Website theme'),subtitle:Text('${settings['theme']??'dark'} · Native palette adapts to supported accents')),
      ])),
      const SizedBox(height:12),
      MfCard(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        const Text('Cloud & data protection',style:TextStyle(fontWeight:FontWeight.bold)),
        const SizedBox(height:12),
        OutlinedButton.icon(onPressed:repo.busy?null:()async{
          await repo.refresh();
          if(context.mounted)showMessage(context,repo.cloudConnected?'Cloud snapshot refreshed.':'Using the local cache.');
        },icon:const Icon(Icons.sync),label:const Text('Refresh cloud snapshot')),
        const SizedBox(height:8),
        FilledButton.icon(onPressed:repo.pendingCount==0||repo.busy?null:()async{
          final allowed=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(
            title:const Text('Upload staged metadata?'),
            content:Text('Upload ${repo.pendingCount} title metadata edits. MediaFlow will refetch the complete existing snapshot, preserve unrelated fields, and reject a concurrent cloud change.'),
            actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),
              FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Upload edits'))]));
          if(allowed!=true)return;
          try{
            await repo.uploadPendingMetadata();
            if(context.mounted)showMessage(context,'Metadata safely uploaded to your existing MediaFlow cloud.');
          }catch(e){if(context.mounted)showMessage(context,'Upload blocked: $e');}
        },icon:const Icon(Icons.cloud_upload_outlined),
          label:Text('Upload ${repo.pendingCount} metadata edits')),
        const SizedBox(height:8),
        OutlinedButton.icon(onPressed:()async{
          try{
            final location=await repo.exportSnapshot();
            if(context.mounted)showDialog<void>(context:context,builder:(ctx)=>AlertDialog(
              title:const Text('Local backup exported'),content:SelectableText(location),
              actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Close'))]));
          }catch(e){if(context.mounted)showMessage(context,'Export failed: $e');}
        },icon:const Icon(Icons.file_download_outlined),label:const Text('Export local snapshot JSON')),
        const SizedBox(height:7),
        const Text('Other MediaFlow backup, sync, import and restore workflows remain available on your website until their native ports are validated.',
          style:TextStyle(fontSize:12)),
      ])),
      const SizedBox(height:12),
      MfCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('Feature-parity roadmap',style:TextStyle(fontWeight:FontWeight.bold)),
        const SizedBox(height:8),
        const Text('Native v1 includes account sign-in, cloud Library, Dashboard, Collections, Personal Order, History, basic Statistics, local logging drafts, metadata editing and safe cloud uploads. Full logging commits, XP engine, Collections editing, complete themes and all web settings still require porting.',
          style:TextStyle(fontSize:13)),
        const SizedBox(height:10),
        const Text('Your MediaFlow website remains fully usable and is not replaced by this app.',
          style:TextStyle(fontWeight:FontWeight.w600)),
      ])),
      const SizedBox(height:15),
      OutlinedButton.icon(onPressed:signOut,icon:const Icon(Icons.logout_rounded),label:const Text('Sign out')),
      const SizedBox(height:40),
    ]);
  }
}
