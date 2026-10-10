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
    final theme=Theme.of(context);
    return Scaffold(body:SafeArea(child:Center(child:SingleChildScrollView(
      padding:const EdgeInsets.all(22),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:440),
        child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          Center(child:Image.asset('assets/mediaflow.png',width:74,height:74)),
          const SizedBox(height:12),
          Text('MEDIAFLOW',textAlign:TextAlign.center,style:TextStyle(
            fontSize:11,letterSpacing:3.2,fontWeight:FontWeight.w800,color:theme.colorScheme.primary)),
          const SizedBox(height:5),
          Text('Your universe, everywhere.',textAlign:TextAlign.center,
            style:theme.textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w800)),
          const SizedBox(height:8),
          Text('Native for Android, iPhone and Windows. Sign in with your existing MediaFlow account.',
            textAlign:TextAlign.center,style:theme.textTheme.bodyMedium?.copyWith(color:theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height:26),
          MfCard(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
            Text(signup?'Create account':'Welcome back',style:theme.textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w800)),
            const SizedBox(height:18),
            TextField(controller:email,keyboardType:TextInputType.emailAddress,
              autofillHints:const [AutofillHints.email],decoration:const InputDecoration(labelText:'Email',prefixIcon:Icon(Icons.mail_outline))),
            const SizedBox(height:12),
            TextField(controller:password,obscureText:obscure,
              autofillHints:[signup?AutofillHints.newPassword:AutofillHints.password],
              decoration:InputDecoration(labelText:'Password',prefixIcon:const Icon(Icons.lock_outline),
                suffixIcon:IconButton(onPressed:()=>setState(()=>obscure=!obscure),
                  icon:Icon(obscure?Icons.visibility_outlined:Icons.visibility_off_outlined)))),
            const SizedBox(height:18),
            FilledButton(onPressed:loading?null:_submit,
              child:Padding(padding:const EdgeInsets.symmetric(vertical:12),
                child:loading?const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2)):
                Text(signup?'Create account':'Sign in to MediaFlow'))),
            const SizedBox(height:8),
            TextButton(onPressed:()=>setState(()=>signup=!signup),
              child:Text(signup?'Already have an account? Sign in':'New to MediaFlow? Create account')),
            if(!signup)TextButton(onPressed:_reset,child:const Text('Forgot password?')),
          ])),
          const SizedBox(height:16),
          Text('Connected to the same Supabase project as the MediaFlow website. Your existing website remains unchanged.',
            textAlign:TextAlign.center,style:theme.textTheme.labelSmall),
        ]))))));
  }
}
