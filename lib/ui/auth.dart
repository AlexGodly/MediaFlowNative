import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'design.dart';

class NativeAuthScreen extends StatefulWidget {
  final SupabaseClient client;
  const NativeAuthScreen({super.key,required this.client});
  @override State<NativeAuthScreen> createState()=>_NativeAuthScreenState();
}
class _NativeAuthScreenState extends State<NativeAuthScreen> {
  final email=TextEditingController(),password=TextEditingController();
  bool signup=false,loading=false,obscure=true;
  @override void dispose(){email.dispose();password.dispose();super.dispose();}
  Future<void> _submit() async {
    if(email.text.trim().isEmpty || password.text.isEmpty)return;
    setState(()=>loading=true);
    try{
      if(signup){
        await widget.client.auth.signUp(email:email.text.trim(),password:password.text);
        if(mounted)showMessage(context,'Account created. If email confirmation is enabled, check your inbox.');
      }else{
        await widget.client.auth.signInWithPassword(email:email.text.trim(),password:password.text);
      }
    }catch(e){if(mounted)showMessage(context,'Authentication failed: $e');}
    finally{if(mounted)setState(()=>loading=false);}
  }
  Future<void> _reset() async {
    if(email.text.trim().isEmpty){showMessage(context,'Enter your email address first.');return;}
    try{
      await widget.client.auth.resetPasswordForEmail(email.text.trim());
      if(mounted)showMessage(context,'Password recovery requested. Check your inbox.');
    }catch(e){if(mounted)showMessage(context,'Recovery failed: $e');}
  }
  @override Widget build(BuildContext context) {
    final p=mfPalette(context);
    final wide=MediaQuery.sizeOf(context).width>=760;
    final form=MfCard(padding:const EdgeInsets.all(24),child:Column(
      crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      Text(signup?'Create your account':'Welcome back',
        style:TextStyle(fontWeight:FontWeight.w900,fontSize:25,letterSpacing:-.9,color:p.text)),
      const SizedBox(height:6),
      Text('Sign in to your existing MediaFlow workspace.',
        style:TextStyle(fontSize:12.5,color:p.muted)),
      const SizedBox(height:25),
      TextField(controller:email,keyboardType:TextInputType.emailAddress,
        autofillHints:const [AutofillHints.email],
        decoration:const InputDecoration(labelText:'Email address',prefixIcon:Icon(Icons.mail_outline_rounded))),
      const SizedBox(height:13),
      TextField(controller:password,obscureText:obscure,
        autofillHints:[signup?AutofillHints.newPassword:AutofillHints.password],
        decoration:InputDecoration(labelText:'Password',prefixIcon:const Icon(Icons.lock_outline_rounded),
          suffixIcon:IconButton(onPressed:()=>setState(()=>obscure=!obscure),
            icon:Icon(obscure?Icons.visibility_outlined:Icons.visibility_off_outlined)))),
      const SizedBox(height:20),
      FilledButton.icon(onPressed:loading?null:_submit,
        icon:loading?const SizedBox(width:17,height:17,
          child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.arrow_forward_rounded,size:19),
        label:Padding(padding:const EdgeInsets.symmetric(vertical:6),
          child:Text(signup?'Create account':'Sign in to MediaFlow'))),
      const SizedBox(height:9),
      TextButton(onPressed:()=>setState(()=>signup=!signup),
        child:Text(signup?'Already have an account? Sign in':'New here? Create account')),
      if(!signup)TextButton(onPressed:_reset,child:const Text('Forgot password?')),
      const SizedBox(height:12),
      Text('SECURE CONNECTION  ·  EXISTING MEDIAFLOW ACCOUNT',
        textAlign:TextAlign.center,style:TextStyle(color:p.muted,fontWeight:FontWeight.w700,
          fontSize:9,letterSpacing:.65)),
    ]));
    final brand=_brand(context,wide);
    return Scaffold(body:SafeArea(child:Center(child:SingleChildScrollView(
      padding:EdgeInsets.all(wide?32:18),
      child:ConstrainedBox(constraints:BoxConstraints(maxWidth:wide?1080:460),
        child:wide?Row(crossAxisAlignment:CrossAxisAlignment.center,children:[
          Expanded(flex:6,child:brand),const SizedBox(width:30),
          Expanded(flex:5,child:form),
        ]):Column(children:[brand,const SizedBox(height:22),form]),
      )))));
  }

  Widget _brand(BuildContext context,bool wide){
    final p=mfPalette(context);
    return MfAmbientCard(padding:EdgeInsets.all(wide?38:24),radius:28,
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[Image.asset('assets/mediaflow.png',width:wide?66:52,height:wide?66:52),
          const SizedBox(width:15),Expanded(child:Column(
            crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text('MEDIAFLOW',style:TextStyle(color:p.text,fontWeight:FontWeight.w900,
                fontSize:wide?23:20,letterSpacing:1)),
              Text('BY ALEX GODLY',style:TextStyle(color:p.accent,
                fontSize:9,fontWeight:FontWeight.w800,letterSpacing:2.2)),
          ]))]),
        SizedBox(height:wide?54:24),
        Text('Your universe.\nEverywhere.',style:TextStyle(
          fontSize:wide?45:31,fontWeight:FontWeight.w900,letterSpacing:-2,
          height:1.05,color:p.text)),
        const SizedBox(height:14),
        Text('One Library. Every story. Your collection travels with you.',
          style:TextStyle(color:p.muted,height:1.5,fontSize:wide?15:12.5)),
        const SizedBox(height:27),
        Wrap(spacing:9,runSpacing:8,children:[
          MfBadge('ANDROID',icon:Icons.smartphone_rounded),
          MfBadge('WINDOWS',icon:Icons.desktop_windows_rounded),
          MfBadge('SHARED ACCOUNT',icon:Icons.cloud_done_rounded),
        ]),
      ]));
  }

}
