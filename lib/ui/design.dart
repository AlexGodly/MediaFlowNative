import 'package:flutter/material.dart';
import '../data/models.dart';
import 'theme_tokens.dart';

@immutable
class MfSkin extends ThemeExtension<MfSkin> {
  final MfPalette palette;
  const MfSkin(this.palette);
  @override MfSkin copyWith({MfPalette? palette})=>MfSkin(palette??this.palette);
  @override MfSkin lerp(ThemeExtension<MfSkin>? other,double t)=>t < .5 ? this : (other??this) as MfSkin;
}

MfPalette mfPalette(BuildContext context)=>
  Theme.of(context).extension<MfSkin>()?.palette??MfThemeTokens.presets['dark']!;

Color mediaAccent(String theme, Map<String,dynamic> settings)=>
  MfThemeTokens.resolve(theme,settings).accent;

ThemeData nativeTheme({required bool dark,required Color accent,MfPalette? palette}) {
  final p=palette??MfThemeTokens.resolve(dark?'dark':'light',{}).copyWith(accent:accent);
  final scheme=ColorScheme.fromSeed(seedColor:p.accent,
    brightness:dark?Brightness.dark:Brightness.light,
    surface:p.surface,primary:p.accent,onSurface:p.text,
    surfaceContainerHighest:p.raised,
    onSurfaceVariant:p.muted,outline:p.outline);
  final base=ThemeData(useMaterial3:true,
    brightness:dark?Brightness.dark:Brightness.light,
    colorScheme:scheme,
    scaffoldBackgroundColor:p.background,
    splashFactory:InkRipple.splashFactory,
    fontFamily:'Roboto',
    extensions:[MfSkin(p)],
  );
  final shape=RoundedRectangleBorder(borderRadius:BorderRadius.circular(17));
  return base.copyWith(
    appBarTheme:AppBarTheme(backgroundColor:p.background,
      foregroundColor:p.text,elevation:0,scrolledUnderElevation:0,
      titleTextStyle:TextStyle(color:p.text,fontSize:18,fontWeight:FontWeight.w800,letterSpacing:-.4)),
    cardTheme:CardThemeData(color:p.surface,margin:EdgeInsets.zero,elevation:0,
      shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(23),
        side:BorderSide(color:p.outline.withValues(alpha:.65)))),
    inputDecorationTheme:InputDecorationTheme(filled:true,fillColor:p.raised,
      hintStyle:TextStyle(color:p.muted,fontSize:13),
      prefixIconColor:p.muted,
      border:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:BorderSide.none),
      focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(14),
        borderSide:BorderSide(color:p.accent.withValues(alpha:.9),width:1.35)),
      contentPadding:const EdgeInsets.symmetric(horizontal:14,vertical:15)),
    chipTheme:base.chipTheme.copyWith(
      backgroundColor:p.raised,selectedColor:p.accent.withValues(alpha:.20),
      side:BorderSide(color:p.outline.withValues(alpha:.65)),
      labelStyle:TextStyle(color:p.text,fontWeight:FontWeight.w600,fontSize:12),
      shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12))),
    filledButtonTheme:FilledButtonThemeData(style:FilledButton.styleFrom(
      shape:shape,backgroundColor:p.accent,foregroundColor:p.background,
      textStyle:const TextStyle(fontWeight:FontWeight.w800,letterSpacing:.1),
      padding:const EdgeInsets.symmetric(horizontal:18,vertical:16))),
    outlinedButtonTheme:OutlinedButtonThemeData(style:OutlinedButton.styleFrom(
      shape:shape,side:BorderSide(color:p.outline),
      padding:const EdgeInsets.symmetric(horizontal:17,vertical:14))),
    dividerColor:p.outline.withValues(alpha:.50),
    navigationBarTheme:NavigationBarThemeData(backgroundColor:p.surface,
      height:72,indicatorColor:p.accent.withValues(alpha:.22),
      labelTextStyle:WidgetStatePropertyAll(TextStyle(color:p.text,fontSize:11,fontWeight:FontWeight.w600))),
    navigationRailTheme:NavigationRailThemeData(backgroundColor:p.surface,
      indicatorColor:p.accent.withValues(alpha:.17),
      selectedIconTheme:IconThemeData(color:p.accent),
      unselectedIconTheme:IconThemeData(color:p.muted),
      selectedLabelTextStyle:TextStyle(color:p.accent,fontWeight:FontWeight.w800),
      unselectedLabelTextStyle:TextStyle(color:p.muted)),
  );
}

class MfCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? tint;
  const MfCard({super.key,required this.child,this.padding=const EdgeInsets.all(18),this.tint});
  @override Widget build(BuildContext context) {
    final p=mfPalette(context);
    return Container(padding:padding,
      decoration:BoxDecoration(color:tint??p.surface,
        border:Border.all(color:p.outline.withValues(alpha:.58)),
        borderRadius:BorderRadius.circular(22),
        boxShadow:[BoxShadow(color:Colors.black.withValues(alpha:p.isLight ? .04 : .16),
          blurRadius:22,offset:const Offset(0,8))]),child:child);
  }
}

class MfBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? color;
  const MfBadge(this.text,{super.key,this.icon,this.color});
  @override Widget build(BuildContext context) {
    final c=color??Theme.of(context).colorScheme.primary;
    return Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:7),
      decoration:BoxDecoration(color:c.withValues(alpha:.11),
        border:Border.all(color:c.withValues(alpha:.23)),borderRadius:BorderRadius.circular(99)),
      child:Row(mainAxisSize:MainAxisSize.min,children:[
        if(icon!=null)...[Icon(icon,color:c,size:13),const SizedBox(width:5)],
        Text(text,style:TextStyle(color:c,fontSize:10.5,fontWeight:FontWeight.w800)),
      ]));
  }
}

/// Premium, fully theme-driven content surface used for highlighted content.
class MfAmbientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  const MfAmbientCard({super.key,required this.child,
    this.padding=const EdgeInsets.all(20),this.radius=24});
  @override Widget build(BuildContext context){
    final p=mfPalette(context);
    return Container(padding:padding,decoration:BoxDecoration(
      gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,
        colors:[Color.lerp(p.surface,p.accent,.19)!,p.surface,p.soft]),
      border:Border.all(color:p.accent.withValues(alpha:.27)),
      borderRadius:BorderRadius.circular(radius)),child:child);
  }
}

class MfSectionHeading extends StatelessWidget {
  final String title;
  final String? detail;
  final IconData icon;
  final Widget? trailing;
  const MfSectionHeading({super.key,required this.title,required this.icon,this.detail,this.trailing});
  @override Widget build(BuildContext context){
    final p=mfPalette(context);
    return Row(children:[
      Container(width:35,height:35,decoration:BoxDecoration(color:p.accent.withValues(alpha:.14),
        borderRadius:BorderRadius.circular(11)),child:Icon(icon,color:p.accent,size:18)),
      const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(title,style:TextStyle(fontSize:17,fontWeight:FontWeight.w800,letterSpacing:-.5,color:p.text)),
        if(detail!=null)Text(detail!,style:TextStyle(fontSize:11,color:p.muted)),
      ])),if(trailing!=null)trailing!,
    ]);
  }
}

IconData statusIcon(String status) => switch (status.toLowerCase()) {
  'watching' || 'reading' || 'active' => Icons.play_circle_outline_rounded,
  'completed' => Icons.task_alt_rounded,
  'onhold' || 'on_hold' || 'paused' => Icons.pause_circle_outline_rounded,
  'dropped' => Icons.cancel_outlined,
  _ => Icons.bookmark_border_rounded,
};

Color statusColor(String status, Color fallback) => switch (status.toLowerCase()) {
  'watching' || 'active' || 'reading' => const Color(0xFF65B6F8),
  'completed' => const Color(0xFF4CCCA2),
  'onhold' || 'on_hold' || 'paused' => const Color(0xFFFFC16D),
  'dropped' => const Color(0xFFF18B98),
  _ => fallback,
};

class TitleCover extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  const TitleCover(this.url, {super.key, this.width=56, this.height=77});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fallback = Container(
      width: width, height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.movie_filter_rounded, size: width * .4, color: theme.colorScheme.primary),
    );
    if (!url.startsWith('https://') && !url.startsWith('http://')) return fallback;
    return ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(
      url, width: width, height: height, fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
      frameBuilder: (_, child, frame, loaded) => frame == null ? fallback : child,
    ));
  }
}


class CategoryBadge extends StatelessWidget {
  final MediaCategory category;
  const CategoryBadge({super.key, required this.category});
  @override Widget build(BuildContext context) {
    final primary=Theme.of(context).colorScheme.primary;
    Widget icon=Icon(Icons.category_outlined,color:primary,size:14);
    final url=category.iconUrl;
    if(url.startsWith('assets/category-icons/') && url.endsWith('.png')){
      icon=Image.asset(url,width:16,height:16,errorBuilder:(_,__,___)=>Icon(Icons.category_outlined,color:primary,size:14));
    }else if(url.startsWith('https://') || url.startsWith('http://')){
      icon=Image.network(url,width:16,height:16,errorBuilder:(_,__,___)=>Icon(Icons.category_outlined,color:primary,size:14));
    }else if(category.icon.isNotEmpty){
      icon=Text(category.icon,style:const TextStyle(fontSize:13));
    }
    return Container(
      padding:const EdgeInsets.symmetric(horizontal:9,vertical:5),
      decoration:BoxDecoration(color:primary.withValues(alpha:.10),border:Border.all(color:primary.withValues(alpha:.22)),borderRadius:BorderRadius.circular(10)),
      child:Row(mainAxisSize:MainAxisSize.min,children:[
        icon,const SizedBox(width:5),
        Text(category.name,style:TextStyle(fontSize:11,fontWeight:FontWeight.w600,color:primary)),
      ]),
    );
  }
}

class TitleBadges extends StatelessWidget {
  final MediaTitle title;
  final MediaWorkspace workspace;
  const TitleBadges({super.key, required this.title, required this.workspace});
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final category = workspace.categoryFor(title.categoryId);
    return Wrap(spacing: 5, runSpacing: 5, children: [
      MfBadge(title.status.replaceAll('_', ' '), icon: statusIcon(title.status),
        color: statusColor(title.status, primary)),
      if (category != null) CategoryBadge(category:category),
      MfBadge('${title.priority} priority', icon: Icons.flag_outlined,
        color: title.priority == 'high' ? const Color(0xFFED859B) :
          title.priority == 'low' ? const Color(0xFF52C8AC) : primary),
    ]);
  }
}

class ScreenHeader extends StatelessWidget {
  final String label,title,subtitle;
  final IconData icon;
  const ScreenHeader({super.key,required this.label,required this.title,
    required this.subtitle,required this.icon});
  @override Widget build(BuildContext context){
    final p=mfPalette(context);
    return MfAmbientCard(padding:const EdgeInsets.all(22),child:Row(children:[
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(label.toUpperCase(),style:TextStyle(fontSize:10,fontWeight:FontWeight.w900,
          letterSpacing:2.1,color:p.accent)),
        const SizedBox(height:7),
        Text(title,style:TextStyle(color:p.text,fontSize:26,fontWeight:FontWeight.w900,
          letterSpacing:-1.2,height:1.06)),
        const SizedBox(height:8),
        Text(subtitle,style:TextStyle(color:p.muted,fontSize:12.5,height:1.55)),
      ])),const SizedBox(width:14),
      Container(width:54,height:54,decoration:BoxDecoration(
        color:p.accent.withValues(alpha:.13),borderRadius:BorderRadius.circular(18),
        border:Border.all(color:p.accent.withValues(alpha:.22))),
        child:Icon(icon,size:27,color:p.accent)),
    ]));
  }
}

class MfMetric extends StatelessWidget {
  final IconData icon;
  final String label,value;
  const MfMetric({super.key,required this.icon,required this.label,required this.value});
  @override Widget build(BuildContext context){
    final p=mfPalette(context);
    return MfCard(padding:const EdgeInsets.symmetric(horizontal:15,vertical:16),child:Column(
      crossAxisAlignment:CrossAxisAlignment.start,children:[
        Container(width:32,height:32,decoration:BoxDecoration(
          color:p.accent.withValues(alpha:.12),borderRadius:BorderRadius.circular(10)),
          child:Icon(icon,color:p.accent,size:18)),
        const Spacer(),
        FittedBox(fit:BoxFit.scaleDown,alignment:Alignment.centerLeft,
          child:Text(value,style:TextStyle(fontSize:25,fontWeight:FontWeight.w900,
            letterSpacing:-1,color:p.text))),
        const SizedBox(height:3),
        Text(label,maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(
          color:p.muted,fontSize:10.5,fontWeight:FontWeight.w600)),
      ]));
  }
}

void showMessage(BuildContext context,String message)=>
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(message)));
