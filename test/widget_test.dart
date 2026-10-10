import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediaflow_native/ui/design.dart';

void main() {
  testWidgets('native MediaFlow headers render at narrow phone width',(tester)async{
    tester.view.physicalSize=const Size(320,720);
    tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(theme:nativeTheme(dark:true,accent:const Color(0xFFEF7697)),
      home:const Scaffold(body:SingleChildScrollView(child:ScreenHeader(
        label:'MEDIAFLOW',title:'Your media, in motion.',
        subtitle:'Native account',icon:Icons.auto_awesome_rounded)))));
    expect(find.text('Your media, in motion.'),findsOneWidget);
    expect(tester.takeException(),isNull);
  });
}
