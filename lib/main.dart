import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config.dart';
import 'data/mediaflow_repository.dart';
import 'ui/auth.dart';
import 'ui/design.dart';
import 'ui/shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url:MediaFlowConfig.supabaseUrl,
    publishableKey:MediaFlowConfig.supabasePublishableKey,
    authOptions:const FlutterAuthClientOptions(autoRefreshToken:true),
  );
  runApp(const MediaFlowNativeApp());
}

class MediaFlowNativeApp extends StatefulWidget {
  const MediaFlowNativeApp({super.key});
  @override State<MediaFlowNativeApp> createState()=>_MediaFlowNativeAppState();
}
class _MediaFlowNativeAppState extends State<MediaFlowNativeApp> {
  late final SupabaseClient client=Supabase.instance.client;
  late final MediaFlowRepository repo=MediaFlowRepository(client);
  StreamSubscription<AuthState>? subscription;
  String? activeUserId;
  bool initialized=false;
  bool loading=true;
  bool? appearanceOverride;
  @override void initState(){
    super.initState();
    subscription=client.auth.onAuthStateChange.listen((event){
      final id=event.session?.user.id;
      if(id!=activeUserId)_syncUser(id);
    });
    _syncUser(client.auth.currentSession?.user.id);
  }
  Future<void> _syncUser(String? uid) async {
    if(uid==activeUserId && initialized)return;
    initialized=true;
    activeUserId=uid;
    if(mounted)setState(()=>loading=uid!=null);
    if(uid==null){repo.reset();if(mounted)setState(()=>loading=false);return;}
    await repo.initialize(uid);
    if(mounted && activeUserId==uid)setState(()=>loading=false);
  }
  Future<void> _signOut() async {
    await client.auth.signOut();
    await _syncUser(null);
  }
  @override void dispose(){subscription?.cancel();repo.dispose();super.dispose();}
  @override Widget build(BuildContext context) {
    return AnimatedBuilder(animation:repo,builder:(ctx,child){
      final settings=repo.workspace.settings;
      final selectedTheme=(settings['theme']??'dark').toString();
      final dark=appearanceOverride??!selectedTheme.toLowerCase().contains('light');
      final color=mediaAccent(selectedTheme,settings);
      return MaterialApp(
        title:'MediaFlow by Alex Godly',debugShowCheckedModeBanner:false,
        theme:nativeTheme(dark:dark,accent:color),
        home:loading?Scaffold(body:Center(child:Column(mainAxisSize:MainAxisSize.min,children:[
          Image.asset('assets/mediaflow.png',width:64,height:64),
          const SizedBox(height:20),const CircularProgressIndicator(),
          const SizedBox(height:14),const Text('Loading your MediaFlow workspace…'),
        ]))):activeUserId==null?NativeAuthScreen(client:client):
          NativeShell(repo:repo,signOut:_signOut,dark:dark,
            changeAppearance:(v)=>setState(()=>appearanceOverride=v)),
      );
    });
  }
}
