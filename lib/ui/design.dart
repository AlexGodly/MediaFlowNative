import 'package:flutter/material.dart';
import '../data/models.dart';

Color mediaAccent(String theme, Map<String, dynamic> settings) {
  final custom = settings['accentColor'] ?? settings['customAccent'] ?? settings['flowColor'];
  if (custom is String && RegExp(r'^#([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$').hasMatch(custom)) {
    final digits = custom.substring(1);
    return Color(int.parse(digits.length == 6 ? 'FF$digits' : digits, radix: 16));
  }
  switch (theme.toLowerCase()) {
    case 'pink': case 'rose': return const Color(0xFFE36A9B);
    case 'green': case 'emerald': return const Color(0xFF39C6A0);
    case 'purple': case 'violet': return const Color(0xFFA18AFF);
    case 'orange': case 'amber': return const Color(0xFFFFB66F);
    case 'blue': case 'ocean': return const Color(0xFF6DAEF7);
    default: return const Color(0xFFEF7697);
  }
}

ThemeData nativeTheme({required bool dark, required Color accent}) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: dark ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent, brightness: dark ? Brightness.dark : Brightness.light,
      surface: dark ? const Color(0xFF141821) : const Color(0xFFF8F8FC),
    ),
    scaffoldBackgroundColor: dark ? const Color(0xFF0C0F17) : const Color(0xFFF4F5F9),
    fontFamily: 'Roboto',
  );
  return base.copyWith(
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: dark ? const Color(0xFF191F2A) : Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: accent.withValues(alpha: dark ? .14 : .09)),
        borderRadius: BorderRadius.circular(22),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? const Color(0xFF202633) : const Color(0xFFF0F2F8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    ),
    chipTheme: base.chipTheme.copyWith(
      side: BorderSide(color: accent.withValues(alpha: .2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: dark ? const Color(0xFF171C26) : Colors.white,
      indicatorColor: accent.withValues(alpha: .22),
    ),
    dividerColor: dark ? Colors.white12 : Colors.black12,
  );
}

class MfCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? tint;
  const MfCard({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.tint});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: tint ?? theme.cardTheme.color,
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: .13)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class MfBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? color;
  const MfBadge(this.text, {super.key, this.icon, this.color});
  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(color: c.withValues(alpha: .10),
        border: Border.all(color: c.withValues(alpha: .22)),
        borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, color: c, size: 13), const SizedBox(width: 5)],
        Text(text, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    );
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
  final String label;
  final String title;
  final String subtitle;
  final IconData icon;
  const ScreenHeader({super.key, required this.label, required this.title,
    required this.subtitle, required this.icon});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [theme.colorScheme.primary.withValues(alpha: .22),
                   theme.colorScheme.primary.withValues(alpha: .035)]),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: .20)),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 10, letterSpacing: 2,
              fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
          const SizedBox(height: 6),
          Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ])),
        const SizedBox(width: 12),
        Icon(icon, size: 36, color: theme.colorScheme.primary),
      ]),
    );
  }
}

class MfMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const MfMetric({super.key, required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final theme=Theme.of(context);
    return MfCard(padding: const EdgeInsets.all(15), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 19),
        const SizedBox(height: 9),
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
          child: Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
        const SizedBox(height: 3),
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelSmall),
      ],
    ));
  }
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
