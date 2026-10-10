import 'package:flutter/material.dart';
import '../data/mediaflow_repository.dart';
import '../data/models.dart';
import 'design.dart';
import 'theme_tokens.dart';
import 'pages.dart';
import 'library_page.dart';
import 'logging.dart';
import 'settings_explorer.dart';
import '../data/xp_insights.dart';

class NativeShell extends StatefulWidget {
  final MediaFlowRepository repo;
  final VoidCallback signOut;
  final bool dark;
  final ValueChanged<bool> changeAppearance;
  final String selectedTheme;
  final ValueChanged<String?> changeTheme;
  const NativeShell({super.key,required this.repo,required this.signOut,
    required this.dark,required this.changeAppearance,
    required this.selectedTheme,required this.changeTheme});
  @override State<NativeShell> createState()=>_NativeShellState();
}

const _destinations = <(String,IconData,IconData)>[
  ('Dashboard',Icons.space_dashboard_outlined,Icons.space_dashboard_rounded),
  ('Library',Icons.video_library_outlined,Icons.video_library_rounded),
  ('Logging',Icons.edit_note_outlined,Icons.edit_note_rounded),
  ('Collections',Icons.grid_view_outlined,Icons.grid_view_rounded),
  ('Personal Order',Icons.format_list_numbered,Icons.format_list_numbered_rounded),
  ('History',Icons.history_outlined,Icons.history_rounded),
  ('Statistics',Icons.insights_outlined,Icons.insights_rounded),
  ('Settings',Icons.tune_outlined,Icons.tune_rounded),
];

class _NativeShellState extends State<NativeShell> {
  int page=0,more=0;
  void _open(MediaTitle title)=>showTitleDetails(context,widget.repo,title);
  @override Widget build(BuildContext context){
    final screenWidth=MediaQuery.sizeOf(context).width;
    final desktop=screenWidth>=850;
    final p=mfPalette(context);
    final workspace=widget.repo.workspace;
    final screens=<Widget>[
      DashboardPage(repo:widget.repo,openTitle:_open),
      LibraryPage(repo:widget.repo,openTitle:_open),
      NativeLoggingPage(repo:widget.repo),
      CollectionsPage(repo:widget.repo,openTitle:_open),
      OrderPage(repo:widget.repo,openTitle:_open),
      HistoryPage(repo:widget.repo),
      StatisticsPage(repo:widget.repo),
      AccountPage(repo:widget.repo,signOut:widget.signOut,dark:widget.dark,
        changeAppearance:widget.changeAppearance,
        selectedTheme:widget.selectedTheme,changeTheme:widget.changeTheme),
    ];
    final content=desktop?screens[page]:page<4?screens[page]:_moreView(screens);
    return Scaffold(
      appBar:AppBar(toolbarHeight:72,titleSpacing:18,
        title:Row(children:[
          Container(width:40,height:40,padding:const EdgeInsets.all(5),
            decoration:BoxDecoration(borderRadius:BorderRadius.circular(13),
              color:p.accent.withValues(alpha:.09),
              border:Border.all(color:p.accent.withValues(alpha:.24))),
            child:Image.asset('assets/mediaflow.png')),
          const SizedBox(width:10),
          Flexible(child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[
            Text('MediaFlow',maxLines:1,overflow:TextOverflow.ellipsis,
              style:TextStyle(fontSize:19,fontWeight:FontWeight.w900,letterSpacing:-.8,color:p.text)),
            Text('BY ALEX GODLY',style:TextStyle(fontSize:8.3,fontWeight:FontWeight.w800,
              letterSpacing:2.1,color:p.accent)),
          ])),
        ]),actions:[
          if(screenWidth>580 && widget.repo.pendingCount>0)
            Padding(padding:const EdgeInsets.only(right:8),child:Center(
              child:MfBadge('${widget.repo.pendingCount} staged',icon:Icons.cloud_upload_outlined))),
          Padding(padding:const EdgeInsets.only(right:6),child:Tooltip(
            message:widget.repo.cloudConnected?'Synced account connection':'Offline / local cache',
            child:Container(width:9,height:9,decoration:BoxDecoration(shape:BoxShape.circle,
              color:widget.repo.cloudConnected?const Color(0xFF40C7A9):p.muted,
              boxShadow:[BoxShadow(color:(widget.repo.cloudConnected?const Color(0xFF40C7A9):p.muted)
                .withValues(alpha:.25),blurRadius:9)])))),
          IconButton(tooltip:'Refresh cloud workspace',onPressed:widget.repo.busy?null:widget.repo.refresh,
            icon:const Icon(Icons.sync_rounded)),
          const SizedBox(width:8),
        ]),
      body:Row(children:[
        if(desktop) _sidebar(p,screenWidth>=1190),
        Expanded(child:Column(children:[
          if(widget.repo.error!=null)MaterialBanner(
            content:Text(widget.repo.error!,maxLines:3,overflow:TextOverflow.ellipsis,
              style:const TextStyle(fontSize:12)),
            leading:const Icon(Icons.info_outline),actions:[
              TextButton(onPressed:widget.repo.refresh,child:const Text('Retry'))]),
          if(widget.repo.busy)LinearProgressIndicator(minHeight:2,
            backgroundColor:p.surface,color:p.accent),
          Expanded(child:KeyedSubtree(key:ValueKey('${desktop?'desktop':'mobile'}-$page-$more'),
            child:workspace.titles.isEmpty && !widget.repo.hasData?_empty():content)),
        ])),
      ]),
      bottomNavigationBar:desktop?null:Container(
        decoration:BoxDecoration(border:Border(top:BorderSide(color:p.outline.withValues(alpha:.4)))),
        child:NavigationBar(selectedIndex:page,
          onDestinationSelected:(i)=>setState(()=>page=i),
          destinations:const [
            NavigationDestination(icon:Icon(Icons.space_dashboard_outlined),
              selectedIcon:Icon(Icons.space_dashboard_rounded),label:'Home'),
            NavigationDestination(icon:Icon(Icons.video_library_outlined),
              selectedIcon:Icon(Icons.video_library_rounded),label:'Library'),
            NavigationDestination(icon:Icon(Icons.edit_note_outlined),
              selectedIcon:Icon(Icons.edit_note_rounded),label:'Logging'),
            NavigationDestination(icon:Icon(Icons.grid_view_outlined),
              selectedIcon:Icon(Icons.grid_view_rounded),label:'Collections'),
            NavigationDestination(icon:Icon(Icons.apps_outlined),
              selectedIcon:Icon(Icons.apps_rounded),label:'More'),
          ])),
    );
  }
  Widget _sidebar(MfPalette p,bool expanded){
    return Container(width:expanded?244:76,
      decoration:BoxDecoration(color:p.surface,
        border:Border(right:BorderSide(color:p.outline.withValues(alpha:.5)))),
      child:Column(children:[
        Padding(padding:EdgeInsets.fromLTRB(expanded?19:15,26,12,12),
          child:Align(alignment:Alignment.centerLeft,
            child:expanded?Text('WORKSPACE',style:TextStyle(letterSpacing:2.2,
              fontSize:10,fontWeight:FontWeight.w800,color:p.muted)):
              Icon(Icons.blur_on_rounded,color:p.muted,size:18))),
        Expanded(child:ListView(padding:EdgeInsets.symmetric(horizontal:expanded?12:8),
          children:[for(var i=0;i<_destinations.length;i++)
            Padding(padding:const EdgeInsets.only(bottom:5),child:_sidebarTile(p,i,expanded)),
          ])),
        Padding(padding:const EdgeInsets.all(12),child:Container(
          width:double.infinity,padding:EdgeInsets.all(expanded?13:10),
          decoration:BoxDecoration(borderRadius:BorderRadius.circular(17),
            gradient:LinearGradient(colors:[p.accent.withValues(alpha:.18),p.raised]),
            border:Border.all(color:p.accent.withValues(alpha:.2))),
          child:expanded?Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Icon(Icons.cloud_done_outlined,color:p.accent,size:19),const SizedBox(height:8),
            Text('YOUR UNIVERSE',style:TextStyle(fontSize:10,letterSpacing:1.2,
              fontWeight:FontWeight.w900,color:p.text)),const SizedBox(height:4),
            Text('${widget.repo.workspace.titles.length} titles connected',
              style:TextStyle(fontSize:11,color:p.muted)),
          ]):Icon(Icons.auto_awesome_rounded,color:p.accent,size:22),
        )),
      ]));
  }
  Widget _sidebarTile(MfPalette p,int i,bool expanded){
    final selected=page==i;
    final title=_destinations[i].$1;
    return Tooltip(message:expanded?'':title,
      child:Material(color:Colors.transparent,child:InkWell(
        borderRadius:BorderRadius.circular(14),
        onTap:()=>setState(()=>page=i),
        child:AnimatedContainer(duration:const Duration(milliseconds:180),height:50,
          padding:EdgeInsets.symmetric(horizontal:expanded?13:0),
          decoration:BoxDecoration(borderRadius:BorderRadius.circular(14),
            color:selected?p.accent.withValues(alpha:.15):Colors.transparent,
            border:Border.all(color:selected?p.accent.withValues(alpha:.25):Colors.transparent)),
          child:Row(mainAxisAlignment:expanded?MainAxisAlignment.start:MainAxisAlignment.center,
            children:[Icon(selected?_destinations[i].$3:_destinations[i].$2,
              color:selected?p.accent:p.muted,size:22),
              if(expanded)...[const SizedBox(width:13),
                Expanded(child:Text(title,style:TextStyle(fontSize:12.5,
                  fontWeight:selected?FontWeight.w800:FontWeight.w600,
                  color:selected?p.text:p.muted))),
                if(selected)Container(width:5,height:5,decoration:BoxDecoration(
                  color:p.accent,shape:BoxShape.circle))],
            ])))));
  }
  Widget _empty()=>Center(child:Padding(padding:const EdgeInsets.all(22),
    child:MfAmbientCard(child:Column(mainAxisSize:MainAxisSize.min,children:[
      Icon(Icons.cloud_off_outlined,size:42,color:Theme.of(context).colorScheme.primary),
      const SizedBox(height:12),const Text('No workspace loaded yet.'),
      const SizedBox(height:8),const Text('Sign in to your MediaFlow account and refresh your cloud Library.'),
      const SizedBox(height:12),FilledButton(onPressed:widget.repo.refresh,child:const Text('Retry cloud load')),
    ]))));
  Widget _moreView(List<Widget> pages){
    final p=mfPalette(context);
    return Column(children:[
      Padding(padding:const EdgeInsets.fromLTRB(14,12,14,8),child:SingleChildScrollView(
        scrollDirection:Axis.horizontal,child:Row(children:[
          for(var i=0;i<4;i++)Padding(padding:const EdgeInsets.only(right:7),
            child:ChoiceChip(avatar:Icon(_destinations[i+4].$2,size:15,
              color:more==i?p.accent:p.muted),
              label:Text(_destinations[i+4].$1),selected:more==i,
              onSelected:(_)=>setState(()=>more=i))),
        ]))),
      Expanded(child:pages[more+4]),
    ]);
  }
}

class AccountPage extends StatelessWidget {
  final MediaFlowRepository repo;
  final VoidCallback signOut;
  final bool dark;
  final ValueChanged<bool> changeAppearance;
  final String selectedTheme;
  final ValueChanged<String?> changeTheme;
  const AccountPage({super.key,required this.repo,required this.signOut,
    required this.dark,required this.changeAppearance,
    required this.selectedTheme,required this.changeTheme});
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
      MfAmbientCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        MfSectionHeading(title:'Appearance studio',icon:Icons.palette_outlined,
          detail:'Native palettes drawn from actual MediaFlow v372 themes'),
        const SizedBox(height:14),
        Row(children:[
          Expanded(child:Text('Current theme: ${selectedTheme.replaceAll('-', ' ')}',
            style:const TextStyle(fontWeight:FontWeight.w800))),
          OutlinedButton.icon(icon:const Icon(Icons.color_lens_outlined,size:18),
            onPressed:()=>showModalBottomSheet<void>(context:context,
              showDragHandle:true,isScrollControlled:true,
              builder:(ctx)=>_ThemePicker(selected:selectedTheme,onSelect:(v){
                changeTheme(v);Navigator.pop(ctx);
              })),label:const Text('Choose')),
        ]),
        const SizedBox(height:7),
        Text('Theme choice is saved locally for this account. It does not modify website Settings.',
          style:Theme.of(context).textTheme.bodySmall),
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
        const Text('Account settings inventory',style:TextStyle(fontWeight:FontWeight.w700)),
        const SizedBox(height:5),
        Text('${settings.length} stored top-level preferences. Inspect every saved field, including nested website settings.',
          style:Theme.of(context).textTheme.bodySmall),
        const SizedBox(height:8),
        OutlinedButton.icon(icon:const Icon(Icons.tune),
          onPressed:()=>Navigator.of(context).push(MaterialPageRoute<void>(
            builder:(ctx)=>Scaffold(appBar:AppBar(title:const Text('MediaFlow Settings')),
              body:SettingsSnapshotExplorer(repo:repo)))),
          label:const Text('Inspect all website settings')),
      ])),
      const SizedBox(height:12),
      Builder(builder:(ctx){
        final xp=XpInsights.fromSnapshot(repo.workspace.json);
        return MfCard(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          const Text('Saved XP audit',style:TextStyle(fontWeight:FontWeight.w700)),
          const SizedBox(height:8),
          Text('Stored session XP: ${xp.sessionXP} · Library additions: ${xp.libraryBonus}'),
          Text('Stored XP subtotal: ${xp.confirmedTotal}',style:const TextStyle(fontWeight:FontWeight.w700)),
          if(xp.missingXPCount>0)Text('${xp.missingXPCount} legacy sessions require canonical website XP recalculation.',
            style:Theme.of(ctx).textTheme.bodySmall),
          const SizedBox(height:5),
          const Text('Read-only audit. This is not the website XP/streak/mission calculation engine.',
            style:TextStyle(fontSize:12)),
        ]));
      }),
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
            title:const Text('Upload native edits?'),
            content:Text('Upload ${repo.pendingCount} staged metadata, Collection, or Personal Order edits. MediaFlow will refetch the complete existing snapshot, preserve unrelated fields, and reject a concurrent cloud change.'),
            actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),
              FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Upload edits'))]));
          if(allowed!=true)return;
          try{
            await repo.uploadPendingMetadata();
            if(context.mounted)showMessage(context,'Metadata safely uploaded to your existing MediaFlow cloud.');
          }catch(e){if(context.mounted)showMessage(context,'Upload blocked: $e');}
        },icon:const Icon(Icons.cloud_upload_outlined),
          label:Text('Upload ${repo.pendingCount} native edits')),
        const SizedBox(height:8),
        OutlinedButton.icon(onPressed:()async{
          try{
            final location=await repo.exportSnapshot();
            if(context.mounted){showDialog<void>(context:context,builder:(ctx)=>AlertDialog(
              title:const Text('Local backup exported'),content:SelectableText(location),
              actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Close'))]));}
          }catch(e){if(context.mounted)showMessage(context,'Export failed: $e');}
        },icon:const Icon(Icons.file_download_outlined),label:const Text('Export local snapshot JSON')),
        const SizedBox(height:7),
        const Text('Other MediaFlow backup, sync, import and restore workflows remain available on your website until their native ports are validated.',
          style:TextStyle(fontSize:12)),
      ])),
      const SizedBox(height:12),
      MfCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('Native parity audit',style:TextStyle(fontWeight:FontWeight.bold)),
        const SizedBox(height:8),
        const Text('The native app is still under development. Logging/XP commits, advanced queues, missions, importers, full website settings handlers, and lossless native backup restoration remain unported. This screen provides genuine theme previews rather than replacing website Settings.',
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

class _ThemePicker extends StatefulWidget {
  final String selected;
  final ValueChanged<String?> onSelect;
  const _ThemePicker({required this.selected,required this.onSelect});
  @override State<_ThemePicker> createState()=>_ThemePickerState();
}
class _ThemePickerState extends State<_ThemePicker>{
  final query=TextEditingController();
  @override void dispose(){query.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    final names=MfThemeTokens.presets.keys.where((n)=>n.contains(query.text.trim().toLowerCase())).toList()..sort();
    final p=mfPalette(context);
    return SafeArea(child:FractionallySizedBox(heightFactor:.83,
      child:Padding(padding:const EdgeInsets.fromLTRB(18,8,18,12),
      child:Column(children:[
        Row(children:[Expanded(child:Text('MediaFlow themes',
          style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w800))),
          MfBadge('${MfThemeTokens.presets.length} palettes')]),
        const SizedBox(height:12),
        TextField(controller:query,onChanged:(_)=>setState((){}),
          decoration:const InputDecoration(prefixIcon:Icon(Icons.search_rounded),hintText:'Search themes')),
        const SizedBox(height:12),
        Expanded(child:ListView.builder(itemCount:names.length,itemBuilder:(ctx,i){
          final name=names[i],v=MfThemeTokens.presets[name]!;
          return Padding(padding:const EdgeInsets.only(bottom:7),child:Material(
            color:p.surface,borderRadius:BorderRadius.circular(14),child:InkWell(
              borderRadius:BorderRadius.circular(14),onTap:()=>widget.onSelect(name),
              child:Padding(padding:const EdgeInsets.all(12),child:Row(children:[
                Container(width:50,height:36,decoration:BoxDecoration(
                  color:v.background,border:Border.all(color:v.outline,width:1),
                  borderRadius:BorderRadius.circular(9)),
                  child:Center(child:Container(height:14,width:24,
                    decoration:BoxDecoration(color:v.accent,borderRadius:BorderRadius.circular(5))))),
                const SizedBox(width:12),
                Expanded(child:Text(name.replaceAll('-', ' '),
                  style:TextStyle(color:p.text,fontWeight:FontWeight.w700))),
                if(name==widget.selected)Icon(Icons.check_circle,color:p.accent,size:20),
              ])))));
        })),
        TextButton.icon(onPressed:()=>widget.onSelect(null),
          icon:const Icon(Icons.restart_alt_rounded),label:const Text('Follow website theme')),
      ]))));
  }
}
