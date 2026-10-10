import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediaflow_native/ui/design.dart';
import 'package:mediaflow_native/ui/theme_tokens.dart';

void main() {
  test('theme bridge contains web color palettes',(){
    expect(MfThemeTokens.presets.length,greaterThanOrEqualTo(100));
    expect(MfThemeTokens.presets['purple']?.accent,const Color(0xFFB892FF));
    expect(MfThemeTokens.presets['ocean']?.background,const Color(0xFF07181D));
    expect(MfThemeTokens.presets['midnight'],isNotNull);
    expect(MfThemeTokens.presets['platform-anilist-dark'],isNotNull);
  });
  test('custom theme respects website custom-theme palette',(){
    final palette=MfThemeTokens.resolve('custom',{
      'customTheme':{'bg':'#0a0b0c','panel':'#131415','raised':'#212223',
        'border':'#303132','text':'#fefefe','accent':'#77ccaa'}
    });
    expect(palette.accent,const Color(0xFF77CCAA));
    expect(palette.surface,const Color(0xFF131415));
    expect(palette.background,const Color(0xFF0A0B0C));
  });
  testWidgets('premium mobile header and metric fit 320 px',(tester)async{
    tester.view.physicalSize=const Size(320,720);
    tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const p=MfPalette(background:Color(0xFF0C0F17),surface:Color(0xFF141821),
      raised:Color(0xFF202633),text:Color(0xFFF5F7FB),
      accent:Color(0xFF8C92FA),outline:Color(0xFF3D4550));
    await tester.pumpWidget(MaterialApp(theme:nativeTheme(dark:true,accent:p.accent,palette:p),
      home:const Scaffold(body:SingleChildScrollView(child:Column(children:[
        ScreenHeader(label:'MediaFlow',title:'Your media, everywhere.',
          subtitle:'Premium native workspace',icon:Icons.auto_awesome_rounded),
        SizedBox(height:16),
        SizedBox(width:150,height:150,child:MfMetric(icon:Icons.video_library_outlined,
          label:'Titles',value:'30,000')),
      ])))));
    expect(find.text('Your media, everywhere.'),findsOneWidget);
    expect(tester.takeException(),isNull);
  });
}
