import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config.dart';
import 'data/mediaflow_repository.dart';
import 'data/appearance_preferences.dart';
import 'ui/auth.dart';
import 'ui/design.dart';
import 'ui/theme_tokens.dart';
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
  String? themeOverride;
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
    if(uid==null){
      repo.reset();themeOverride=null;appearanceOverride=null;
      if(mounted)setState(()=>loading=false);return;
    }
    await repo.initialize(uid);
    final native=await AppearancePreferences(uid).read();
    if(activeUserId==uid){
      themeOverride=native['theme'] is String ? native['theme'] as String:null;
      appearanceOverride=native['dark'] is bool ? native['dark'] as bool:null;
    }
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
      final selectedTheme=themeOverride??(settings['theme']??'dark').toString();
      final palette=MfThemeTokens.resolve(selectedTheme,settings,overrideDark:appearanceOverride);
      final dark=!palette.isLight;
      final color=palette.accent;
      return MaterialApp(
        title:'MediaFlow by Alex Godly',debugShowCheckedModeBanner:false,
        theme:nativeTheme(dark:dark,accent:color,palette:palette),
        home:loading?Scaffold(body:Center(child:Column(mainAxisSize:MainAxisSize.min,children:[
          Image.asset('assets/mediaflow.png',width:64,height:64),
          const SizedBox(height:20),const CircularProgressIndicator(),
          const SizedBox(height:14),const Text('Loading your MediaFlow workspace…'),
        ]))):activeUserId==null?NativeAuthScreen(client:client):
          NativeShell(repo:repo,signOut:_signOut,dark:dark,
            selectedTheme:selectedTheme,
            changeTheme:(value){
              setState(()=>themeOverride=value);
              final id=activeUserId;
              if(id!=null){AppearancePreferences(id).write(theme:value,dark:appearanceOverride);}
            },
            changeAppearance:(v){
              setState(()=>appearanceOverride=v);
              final id=activeUserId;
              if(id!=null){AppearancePreferences(id).write(theme:themeOverride,dark:v);}
            }),
      );
    });
  }
}
