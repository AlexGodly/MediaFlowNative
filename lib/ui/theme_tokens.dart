import 'package:flutter/material.dart';

/// Web parity: colors copied from v372 CSS html[data-theme] definitions.
/// This is a design-token bridge, not a port of dynamic-cover artwork extraction.
class MfPalette {
  final Color background, surface, raised, text, accent, outline;
  const MfPalette({required this.background, required this.surface,
    required this.raised, required this.text, required this.accent,
    required this.outline});

  bool get isLight => ThemeData.estimateBrightnessForColor(background) == Brightness.light;
  Color get muted => Color.lerp(text,background,.42)!;
  Color get soft => Color.lerp(surface,raised,.55)!;
  Color get glow => Color.lerp(accent,background,.68)!;

  MfPalette copyWith({Color? background,Color? surface,Color? raised,
    Color? text,Color? accent,Color? outline}) => MfPalette(
    background:background??this.background, surface:surface??this.surface,
    raised:raised??this.raised, text:text??this.text,
    accent:accent??this.accent, outline:outline??this.outline);
}

const _fallbackDark = MfPalette(background:Color(0xFF0A0E15),surface:Color(0xFF131B26),
  raised:Color(0xFF1D2734),text:Color(0xFFF0F4FB),accent:Color(0xFF8C92FA),outline:Color(0xFF344153));
const _fallbackLight = MfPalette(background:Color(0xFFF4F6FA),surface:Colors.white,
  raised:Color(0xFFE9EEF5),text:Color(0xFF192435),accent:Color(0xFF5F63CD),outline:Color(0xFFCBD5E2));

class MfThemeTokens {
  static const Map<String,MfPalette> presets = {
    'amoled': MfPalette(background:Color(0xFF000000), surface:Color(0xFF0A0C10), raised:Color(0xFF141820), text:Color(0xFFF7F8FA), accent:Color(0xFFEF7697), outline:Color(0xFF252D38)),
    'apricot': MfPalette(background:Color(0xFFFFF3E6), surface:Color(0xFFFFFAF5), raised:Color(0xFFFFDFBD), text:Color(0xFF422B1D), accent:Color(0xFFE57E38), outline:Color(0xFFE6B17E)),
    'aqua': MfPalette(background:Color(0xFF06191B), surface:Color(0xFF0B282B), raised:Color(0xFF10383C), text:Color(0xFFEFFFFF), accent:Color(0xFF25D6D9), outline:Color(0xFF28636A)),
    'arctic': MfPalette(background:Color(0xFFEAF8FF), surface:Color(0xFFF8FDFF), raised:Color(0xFFDFF3FF), text:Color(0xFF102D3C), accent:Color(0xFF008FC7), outline:Color(0xFF9BCCE3)),
    'aurora-night': MfPalette(background:Color(0xFF071419), surface:Color(0xFF0D2026), raised:Color(0xFF143039), text:Color(0xFFEEFCFF), accent:Color(0xFF57E2B2), outline:Color(0xFF2E5A62)),
    'autumn': MfPalette(background:Color(0xFF1A1008), surface:Color(0xFF2A1A0D), raised:Color(0xFF3A2512), text:Color(0xFFFFF4DF), accent:Color(0xFFE07A2D), outline:Color(0xFF684422)),
    'blueprint': MfPalette(background:Color(0xFF06182B), surface:Color(0xFF0A2744), raised:Color(0xFF0E365C), text:Color(0xFFEEF8FF), accent:Color(0xFF48A9FF), outline:Color(0xFF285B86)),
    'bronze': MfPalette(background:Color(0xFF17100A), surface:Color(0xFF271A10), raised:Color(0xFF382417), text:Color(0xFFFFF3E4), accent:Color(0xFFCD7F32), outline:Color(0xFF62442B)),
    'bubblegum': MfPalette(background:Color(0xFFFFF0FB), surface:Color(0xFFFFF8FD), raised:Color(0xFFFBDCF3), text:Color(0xFF4D2944), accent:Color(0xFFFF58B0), outline:Color(0xFFE8A6D2)),
    'candy': MfPalette(background:Color(0xFFFFF4EA), surface:Color(0xFFFFFAFD), raised:Color(0xFFFFE3EF), text:Color(0xFF412C42), accent:Color(0xFFFF4F9A), outline:Color(0xFFF1B2CE)),
    'cherry': MfPalette(background:Color(0xFF16080D), surface:Color(0xFF2A0D16), raised:Color(0xFF3C1220), text:Color(0xFFFFF0F4), accent:Color(0xFFE3265F), outline:Color(0xFF6D2739)),
    'coastal-breeze': MfPalette(background:Color(0xFFEEF9FB), surface:Color(0xFFFFFFFF), raised:Color(0xFFDFF2F5), text:Color(0xFF17343B), accent:Color(0xFF1689A3), outline:Color(0xFFA8CFD6)),
    'cobalt': MfPalette(background:Color(0xFF071229), surface:Color(0xFF0B1C3D), raised:Color(0xFF102954), text:Color(0xFFEEF5FF), accent:Color(0xFF3B82F6), outline:Color(0xFF254C82)),
    'coffee': MfPalette(background:Color(0xFF17120F), surface:Color(0xFF241C17), raised:Color(0xFF30251E), text:Color(0xFFFBF4EC), accent:Color(0xFFD6A56F), outline:Color(0xFF514033)),
    'coral': MfPalette(background:Color(0xFF10202A), surface:Color(0xFF17313B), raised:Color(0xFF1E424B), text:Color(0xFFF2FFFF), accent:Color(0xFFFF786D), outline:Color(0xFF397079)),
    'crimson': MfPalette(background:Color(0xFF120609), surface:Color(0xFF210B10), raised:Color(0xFF321019), text:Color(0xFFFFF1F3), accent:Color(0xFFFF345F), outline:Color(0xFF5B1D2B)),
    'cyber': MfPalette(background:Color(0xFF080B10), surface:Color(0xFF10151D), raised:Color(0xFF151D28), text:Color(0xFFEAFFFB), accent:Color(0xFF35F2C1), outline:Color(0xFF26394A)),
    'dark': MfPalette(background:Color(0xFF0C0F17), surface:Color(0xFF171C26), raised:Color(0xFF202737), text:Color(0xFFEDF1F8), accent:Color(0xFFEF7697), outline:Color(0xFF344254)),
    'desert': MfPalette(background:Color(0xFFF3E2C2), surface:Color(0xFFFFF1D7), raised:Color(0xFFEAD0A5), text:Color(0xFF3E2C1B), accent:Color(0xFFC76B29), outline:Color(0xFFB98E58)),
    'dracula': MfPalette(background:Color(0xFF17141F), surface:Color(0xFF211D2B), raised:Color(0xFF2B2638), text:Color(0xFFF8F8F2), accent:Color(0xFFFF79C6), outline:Color(0xFF514666)),
    'emerald': MfPalette(background:Color(0xFF061711), surface:Color(0xFF0B251B), raised:Color(0xFF103426), text:Color(0xFFEFFFF7), accent:Color(0xFF2EE59D), outline:Color(0xFF235D45)),
    'forest': MfPalette(background:Color(0xFF0C1610), surface:Color(0xFF142219), raised:Color(0xFF1A2D21), text:Color(0xFFF1F8F2), accent:Color(0xFF76C893), outline:Color(0xFF31503B)),
    'galaxy': MfPalette(background:Color(0xFF080719), surface:Color(0xFF12102B), raised:Color(0xFF1D1740), text:Color(0xFFF4F0FF), accent:Color(0xFF8C6CFF), outline:Color(0xFF42396E)),
    'gold': MfPalette(background:Color(0xFF100D05), surface:Color(0xFF211A08), raised:Color(0xFF32270B), text:Color(0xFFFFF8DD), accent:Color(0xFFF5C542), outline:Color(0xFF665017)),
    'iceberg': MfPalette(background:Color(0xFF08171D), surface:Color(0xFF10252D), raised:Color(0xFF173540), text:Color(0xFFEFFCFF), accent:Color(0xFF74D7EF), outline:Color(0xFF315B67)),
    'ink-neon': MfPalette(background:Color(0xFF08090F), surface:Color(0xFF0F111B), raised:Color(0xFF171A29), text:Color(0xFFF6F7FF), accent:Color(0xFF50E3FF), outline:Color(0xFF34394F)),
    'ivory': MfPalette(background:Color(0xFFF7F2E5), surface:Color(0xFFFFFDF7), raised:Color(0xFFECE4D2), text:Color(0xFF302C24), accent:Color(0xFF9A7438), outline:Color(0xFFC8BDA6)),
    'lavender': MfPalette(background:Color(0xFFF3EFFF), surface:Color(0xFFFBF9FF), raised:Color(0xFFE9E0FF), text:Color(0xFF2D2345), accent:Color(0xFF7C52D9), outline:Color(0xFFB8A4E5)),
    'lemon-sorbet': MfPalette(background:Color(0xFFFFF9D8), surface:Color(0xFFFFFDF0), raised:Color(0xFFFFF0A9), text:Color(0xFF302B18), accent:Color(0xFFD19B00), outline:Color(0xFFD5BF55)),
    'light': MfPalette(background:Color(0xFFF4F5F9), surface:Color(0xFFFFFFFF), raised:Color(0xFFEFF1F8), text:Color(0xFF182131), accent:Color(0xFFB64E78), outline:Color(0xFFD9DDE7)),
    'lilac-haze': MfPalette(background:Color(0xFFF6F1FF), surface:Color(0xFFFFFFFF), raised:Color(0xFFEAE0FF), text:Color(0xFF302542), accent:Color(0xFF8566CC), outline:Color(0xFFC1AFE8)),
    'matcha-cream': MfPalette(background:Color(0xFFF3F4E8), surface:Color(0xFFFFFEF5), raised:Color(0xFFE5EAD3), text:Color(0xFF26301F), accent:Color(0xFF718B52), outline:Color(0xFFB7C29A)),
    'matrix': MfPalette(background:Color(0xFF000500), surface:Color(0xFF001000), raised:Color(0xFF001A04), text:Color(0xFFCAFFCA), accent:Color(0xFF00FF41), outline:Color(0xFF0B4A17)),
    'midnight': MfPalette(background:Color(0xFF07111F), surface:Color(0xFF0D1B2D), raised:Color(0xFF13243A), text:Color(0xFFEDF5FF), accent:Color(0xFF69A7FF), outline:Color(0xFF243A55)),
    'mint': MfPalette(background:Color(0xFFEDFFF8), surface:Color(0xFFF9FFFC), raised:Color(0xFFD9F7EB), text:Color(0xFF173B30), accent:Color(0xFF1CA87A), outline:Color(0xFF9ED8C2)),
    'monochrome': MfPalette(background:Color(0xFF111111), surface:Color(0xFF1B1B1B), raised:Color(0xFF292929), text:Color(0xFFF4F4F4), accent:Color(0xFFFFFFFF), outline:Color(0xFF4A4A4A)),
    'morning-sky': MfPalette(background:Color(0xFFF3F8FF), surface:Color(0xFFFFFFFF), raised:Color(0xFFE5F0FF), text:Color(0xFF1E3047), accent:Color(0xFF4D86C6), outline:Color(0xFFAFC9E9)),
    'moss': MfPalette(background:Color(0xFF10150A), surface:Color(0xFF1A2210), raised:Color(0xFF253017), text:Color(0xFFF5FAE9), accent:Color(0xFF86A94F), outline:Color(0xFF465D2C)),
    'neon': MfPalette(background:Color(0xFF090611), surface:Color(0xFF130B20), raised:Color(0xFF1D1030), text:Color(0xFFFFF2FF), accent:Color(0xFFFF35E1), outline:Color(0xFF462260)),
    'nord': MfPalette(background:Color(0xFF242933), surface:Color(0xFF2E3440), raised:Color(0xFF3B4252), text:Color(0xFFECEFF4), accent:Color(0xFF88C0D0), outline:Color(0xFF4C566A)),
    'notebook': MfPalette(background:Color(0xFFF7F8F4), surface:Color(0xFFFFFEF9), raised:Color(0xFFEDF1F3), text:Color(0xFF172630), accent:Color(0xFF2F6DB0), outline:Color(0xFFAEBAC2)),
    'obsidian': MfPalette(background:Color(0xFF07090C), surface:Color(0xFF0D1117), raised:Color(0xFF151B23), text:Color(0xFFF1F4F8), accent:Color(0xFF8AA4C2), outline:Color(0xFF2D3744)),
    'ocean': MfPalette(background:Color(0xFF07181D), surface:Color(0xFF0D252B), raised:Color(0xFF123139), text:Color(0xFFEFFCFD), accent:Color(0xFF55D6BE), outline:Color(0xFF24505A)),
    'paper': MfPalette(background:Color(0xFFEEE9DD), surface:Color(0xFFFAF7EF), raised:Color(0xFFE5DED0), text:Color(0xFF2E2B27), accent:Color(0xFF4B6B88), outline:Color(0xFFC4B9A6)),
    'peach': MfPalette(background:Color(0xFFFFF1E8), surface:Color(0xFFFFF9F4), raised:Color(0xFFFFE1D1), text:Color(0xFF4B2D24), accent:Color(0xFFEF7F5B), outline:Color(0xFFEFB69A)),
    'pistachio': MfPalette(background:Color(0xFFF5F7E9), surface:Color(0xFFFFFEF8), raised:Color(0xFFE7ECCB), text:Color(0xFF2E341D), accent:Color(0xFF819A43), outline:Color(0xFFBDC98F)),
    'platform-anilist-dark': MfPalette(background:Color(0xFF0B0D10), surface:Color(0xFF12161B), raised:Color(0xFF1A2027), text:Color(0xFFF4F7FA), accent:Color(0xFF3DB4F2), outline:Color(0xFF343C46)),
    'platform-anilist-light': MfPalette(surface:Color(0xFFF8FAFB),background:Color(0xFFEEF2F5), raised:Color(0xFFF8FAFB), text:Color(0xFF202830), accent:Color(0xFF3DB4F2), outline:Color(0xFFCBD3DB)),
    'platform-anisearch-dark': MfPalette(background:Color(0xFF0B0D10), surface:Color(0xFF12161B), raised:Color(0xFF1A2027), text:Color(0xFFF4F7FA), accent:Color(0xFFE86C2F), outline:Color(0xFF343C46)),
    'platform-anisearch-light': MfPalette(surface:Color(0xFFF8FAFB),background:Color(0xFFEEF2F5), raised:Color(0xFFF8FAFB), text:Color(0xFF202830), accent:Color(0xFFE86C2F), outline:Color(0xFFCBD3DB)),
    'platform-aniwatch-dark': MfPalette(background:Color(0xFF0B0D10), surface:Color(0xFF12161B), raised:Color(0xFF1A2027), text:Color(0xFFF4F7FA), accent:Color(0xFFFFBADE), outline:Color(0xFF343C46)),
    'platform-aniwatch-light': MfPalette(surface:Color(0xFFF8FAFB),background:Color(0xFFEEF2F5), raised:Color(0xFFF8FAFB), text:Color(0xFF202830), accent:Color(0xFFFFBADE), outline:Color(0xFFCBD3DB)),
    'platform-betaseries-dark': MfPalette(background:Color(0xFF0B0D10), surface:Color(0xFF12161B), raised:Color(0xFF1A2027), text:Color(0xFFF4F7FA), accent:Color(0xFFFF4F4F), outline:Color(0xFF343C46)),
    'platform-betaseries-light': MfPalette(surface:Color(0xFFF8FAFB),background:Color(0xFFEEF2F5), raised:Color(0xFFF8FAFB), text:Color(0xFF202830), accent:Color(0xFFFF4F4F), outline:Color(0xFFCBD3DB)),
    'platform-criticker-dark': MfPalette(background:Color(0xFF0B0D10), surface:Color(0xFF12161B), raised:Color(0xFF1A2027), text:Color(0xFFF4F7FA), accent:Color(0xFFF39C12), outline:Color(0xFF343C46)),
    'platform-criticker-light': MfPalette(surface:Color(0xFFF8FAFB),background:Color(0xFFEEF2F5), raised:Color(0xFFF8FAFB), text:Color(0xFF202830), accent:Color(0xFFF39C12), outline:Color(0xFFCBD3DB)),
    'platform-crunchyroll-dark': MfPalette(background:Color(0xFF0B0D10), surface:Color(0xFF12161B), raised:Color(0xFF1A2027), text:Color(0xFFF4F7FA), accent:Color(0xFFF47521), outline:Color(0xFF343C46)),
    'platform-crunchyroll-light': MfPalette(surface:Color(0xFFF8FAFB),background:Color(0xFFEEF2F5), raised:Color(0xFFF8FAFB), text:Color(0xFF202830), accent:Color(0xFFF47521), outline:Color(0xFFCBD3DB)),
    'platform-episodecalendar-dark': MfPalette(background:Color(0xFF0B0D10), surface:Color(0xFF12161B), raised:Color(0xFF1A2027), text:Color(0xFFF4F7FA), accent:Color(0xFF4AA3DF), outline:Color(0xFF343C46)),
    'platform-episodecalendar-light': MfPalette(surface:Color(0xFFF8FAFB),background:Color(0xFFEEF2F5), raised:Color(0xFFF8FAFB), text:Color(0xFF202830), accent:Color(0xFF4AA3DF), outline:Color(0xFFCBD3DB)),
    'platform-hianime-dark': MfPalette(background:Color(0xFF0B0D10), surface:Color(0xFF12161B), raised:Color(0xFF1A2027), text:Color(0xFFF4F7FA), accent:Color(0xFFB9E36F), outline:Color(0xFF343C46)),
    'platform-hianime-light': MfPalette(surface:Color(0xFFF8FAFB),background:Color(0xFFEEF2F5), raised:Color(0xFFF8FAFB), text:Color(0xFF202830), accent:Color(0xFFB9E36F), outline:Color(0xFFCBD3DB)),
    'platform-imdb-dark': MfPalette(background:Color(0xFF0B0D10), surface:Color(0xFF12161B), raised:Color(0xFF1A2027), text:Color(0xFFF4F7FA), accent:Color(0xFFF5C518), outline:Color(0xFF343C46)),
    'platform-imdb-light': MfPalette(surface:Color(0xFFF8FAFB),background:Color(0xFFEEF2F5), raised:Color(0xFFF8FAFB), text:Color(0xFF202830), accent:Color(0xFFF5C518), outline:Color(0xFFCBD3DB)),
    'platform-kitsu-dark': MfPalette(background:Color(0xFF0B0D10), surface:Color(0xFF12161B), raised:Color(0xFF1A2027), text:Color(0xFFF4F7FA), accent:Color(0xFFF75239), outline:Color(0xFF343C46)),
    'platform-kitsu-light': MfPalette(surface:Color(0xFFF8FAFB),background:Color(0xFFEEF2F5), raised:Color(0xFFF8FAFB), text:Color(0xFF202830), accent:Color(0xFFF75239), outline:Color(0xFFCBD3DB)),
    'platform-letterboxd-dark': MfPalette(background:Color(0xFF0B0D10), surface:Color(0xFF12161B), raised:Color(0xFF1A2027), text:Color(0xFFF4F7FA), accent:Color(0xFF00E054), outline:Color(0xFF343C46)),
    'platform-letterboxd-light': MfPalette(surface:Color(0xFFF8FAFB),background:Color(0xFFEEF2F5), raised:Color(0xFFF8FAFB), text:Color(0xFF202830), accent:Color(0xFF00E054), outline:Color(0xFFCBD3DB)),
    'platform-livechart-dark': MfPalette(background:Color(0xFF0B0D10), surface:Color(0xFF12161B), raised:Color(0xFF1A2027), text:Color(0xFFF4F7FA), accent:Color(0xFFE84C4C), outline:Color(0xFF343C46)),
    'platform-livechart-light': MfPalette(surface:Color(0xFFF8FAFB),background:Color(0xFFEEF2F5), raised:Color(0xFFF8FAFB), text:Color(0xFF202830), accent:Color(0xFFE84C4C), outline:Color(0xFFCBD3DB)),
    'platform-malxml-dark': MfPalette(background:Color(0xFF0B0D10), surface:Color(0xFF12161B), raised:Color(0xFF1A2027), text:Color(0xFFF4F7FA), accent:Color(0xFF4F6BB5), outline:Color(0xFF343C46)),
    'platform-malxml-light': MfPalette(surface:Color(0xFFF8FAFB),background:Color(0xFFEEF2F5), raised:Color(0xFFF8FAFB), text:Color(0xFF202830), accent:Color(0xFF4F6BB5), outline:Color(0xFFCBD3DB)),
    'platform-moviesfad-dark': MfPalette(background:Color(0xFF0B0D10), surface:Color(0xFF12161B), raised:Color(0xFF1A2027), text:Color(0xFFF4F7FA), accent:Color(0xFFE74C3C), outline:Color(0xFF343C46)),
    'platform-moviesfad-light': MfPalette(surface:Color(0xFFF8FAFB),background:Color(0xFFEEF2F5), raised:Color(0xFFF8FAFB), text:Color(0xFF202830), accent:Color(0xFFE74C3C), outline:Color(0xFFCBD3DB)),
    'platform-myanimelist-dark': MfPalette(background:Color(0xFF0B0D10), surface:Color(0xFF12161B), raised:Color(0xFF1A2027), text:Color(0xFFF4F7FA), accent:Color(0xFF2E51A2), outline:Color(0xFF343C46)),
    'platform-myanimelist-light': MfPalette(surface:Color(0xFFF8FAFB),background:Color(0xFFEEF2F5), raised:Color(0xFFF8FAFB), text:Color(0xFF202830), accent:Color(0xFF2E51A2), outline:Color(0xFFCBD3DB)),
    'platform-netflix-dark': MfPalette(background:Color(0xFF0B0D10), surface:Color(0xFF12161B), raised:Color(0xFF1A2027), text:Color(0xFFF4F7FA), accent:Color(0xFFE50914), outline:Color(0xFF343C46)),
    'platform-netflix-light': MfPalette(surface:Color(0xFFF8FAFB),background:Color(0xFFEEF2F5), raised:Color(0xFFF8FAFB), text:Color(0xFF202830), accent:Color(0xFFE50914), outline:Color(0xFFCBD3DB)),
    'platform-primewire-dark': MfPalette(background:Color(0xFF0B0D10), surface:Color(0xFF12161B), raised:Color(0xFF1A2027), text:Color(0xFFF4F7FA), accent:Color(0xFF44C8F5), outline:Color(0xFF343C46)),
    'platform-primewire-light': MfPalette(surface:Color(0xFFF8FAFB),background:Color(0xFFEEF2F5), raised:Color(0xFFF8FAFB), text:Color(0xFF202830), accent:Color(0xFF44C8F5), outline:Color(0xFFCBD3DB)),
    'platform-seriesfad-dark': MfPalette(background:Color(0xFF0B0D10), surface:Color(0xFF12161B), raised:Color(0xFF1A2027), text:Color(0xFFF4F7FA), accent:Color(0xFF9B59B6), outline:Color(0xFF343C46)),
    'platform-seriesfad-light': MfPalette(surface:Color(0xFFF8FAFB),background:Color(0xFFEEF2F5), raised:Color(0xFFF8FAFB), text:Color(0xFF202830), accent:Color(0xFF9B59B6), outline:Color(0xFFCBD3DB)),
    'platform-simkl-dark': MfPalette(background:Color(0xFF0B0D10), surface:Color(0xFF12161B), raised:Color(0xFF1A2027), text:Color(0xFFF4F7FA), accent:Color(0xFF00A9E0), outline:Color(0xFF343C46)),
    'platform-simkl-light': MfPalette(surface:Color(0xFFF8FAFB),background:Color(0xFFEEF2F5), raised:Color(0xFFF8FAFB), text:Color(0xFF202830), accent:Color(0xFF00A9E0), outline:Color(0xFFCBD3DB)),
    'platform-stremio-dark': MfPalette(background:Color(0xFF0B0D10), surface:Color(0xFF12161B), raised:Color(0xFF1A2027), text:Color(0xFFF4F7FA), accent:Color(0xFF7B5CFF), outline:Color(0xFF343C46)),
    'platform-stremio-light': MfPalette(surface:Color(0xFFF8FAFB),background:Color(0xFFEEF2F5), raised:Color(0xFFF8FAFB), text:Color(0xFF202830), accent:Color(0xFF7B5CFF), outline:Color(0xFFCBD3DB)),
    'platform-trakt-new-dark': MfPalette(background:Color(0xFF0C0D0F), surface:Color(0xFF17191C), raised:Color(0xFF202226), text:Color(0xFFF7F7F7), accent:Color(0xFFED1C24), outline:Color(0xFF3A3D42)),
    'platform-trakt-new-light': MfPalette(surface:Color(0xFFFAFAFA),background:Color(0xFFF4F5F6), raised:Color(0xFFFAFAFA), text:Color(0xFF202124), accent:Color(0xFFED1C24), outline:Color(0xFFD5D7DA)),
    'platform-tviso-dark': MfPalette(background:Color(0xFF0B0D10), surface:Color(0xFF12161B), raised:Color(0xFF1A2027), text:Color(0xFFF4F7FA), accent:Color(0xFF00A7C4), outline:Color(0xFF343C46)),
    'platform-tviso-light': MfPalette(surface:Color(0xFFF8FAFB),background:Color(0xFFEEF2F5), raised:Color(0xFFF8FAFB), text:Color(0xFF202830), accent:Color(0xFF00A7C4), outline:Color(0xFFCBD3DB)),
    'platform-tvtime-dark': MfPalette(background:Color(0xFF0B0D10), surface:Color(0xFF12161B), raised:Color(0xFF1A2027), text:Color(0xFFF4F7FA), accent:Color(0xFFFF2D55), outline:Color(0xFF343C46)),
    'platform-tvtime-light': MfPalette(surface:Color(0xFFF8FAFB),background:Color(0xFFEEF2F5), raised:Color(0xFFF8FAFB), text:Color(0xFF202830), accent:Color(0xFFFF2D55), outline:Color(0xFFCBD3DB)),
    'platform-twee-dark': MfPalette(background:Color(0xFF0B0D10), surface:Color(0xFF12161B), raised:Color(0xFF1A2027), text:Color(0xFFF4F7FA), accent:Color(0xFFEC407A), outline:Color(0xFF343C46)),
    'platform-twee-light': MfPalette(surface:Color(0xFFF8FAFB),background:Color(0xFFEEF2F5), raised:Color(0xFFF8FAFB), text:Color(0xFF202830), accent:Color(0xFFEC407A), outline:Color(0xFFCBD3DB)),
    'porcelain': MfPalette(background:Color(0xFFF4F8FC), surface:Color(0xFFFFFFFF), raised:Color(0xFFEDF3F9), text:Color(0xFF182433), accent:Color(0xFF376F9F), outline:Color(0xFFB9C9D9)),
    'purple': MfPalette(background:Color(0xFF120E1D), surface:Color(0xFF1C162B), raised:Color(0xFF261D39), text:Color(0xFFF8F3FF), accent:Color(0xFFB892FF), outline:Color(0xFF463663)),
    'retro': MfPalette(background:Color(0xFF160D24), surface:Color(0xFF25143A), raised:Color(0xFF361C50), text:Color(0xFFFFF4D6), accent:Color(0xFFFF9F1C), outline:Color(0xFF613579)),
    'rose': MfPalette(background:Color(0xFF1A1016), surface:Color(0xFF271720), raised:Color(0xFF341F2A), text:Color(0xFFFFF4F8), accent:Color(0xFFF08FB3), outline:Color(0xFF583647)),
    'rose-milk': MfPalette(background:Color(0xFFFFF3F2), surface:Color(0xFFFFFDFC), raised:Color(0xFFF9DDDD), text:Color(0xFF3C2529), accent:Color(0xFFD86F7E), outline:Color(0xFFE1AFB1)),
    'sakura': MfPalette(background:Color(0xFFFFF4F7), surface:Color(0xFFFFFAFD), raised:Color(0xFFFFE8F0), text:Color(0xFF442B36), accent:Color(0xFFE96F9D), outline:Color(0xFFEAB8CA)),
    'seafoam-glass': MfPalette(background:Color(0xFFE9FBF7), surface:Color(0xFFFAFFFD), raised:Color(0xFFD6F3EA), text:Color(0xFF12372E), accent:Color(0xFF1F9F7F), outline:Color(0xFF92CFBD)),
    'sky': MfPalette(background:Color(0xFFDFF3FF), surface:Color(0xFFF7FCFF), raised:Color(0xFFCBEAFF), text:Color(0xFF18364A), accent:Color(0xFF168AD0), outline:Color(0xFF8BC6EA)),
    'slate': MfPalette(background:Color(0xFF11151B), surface:Color(0xFF19202A), raised:Color(0xFF212B37), text:Color(0xFFF3F6FA), accent:Color(0xFF8FB3D9), outline:Color(0xFF344252)),
    'solarized': MfPalette(background:Color(0xFF002B36), surface:Color(0xFF073642), raised:Color(0xFF0B4652), text:Color(0xFFFDF6E3), accent:Color(0xFFB58900), outline:Color(0xFF315B63)),
    'storm': MfPalette(background:Color(0xFF0D1118), surface:Color(0xFF171D27), raised:Color(0xFF222B38), text:Color(0xFFF0F4F9), accent:Color(0xFF6E8EAF), outline:Color(0xFF414E61)),
    'sunset': MfPalette(background:Color(0xFF1B1014), surface:Color(0xFF28171D), raised:Color(0xFF352027), text:Color(0xFFFFF4EF), accent:Color(0xFFFF9F68), outline:Color(0xFF5A3540)),
    'terminal': MfPalette(background:Color(0xFF050805), surface:Color(0xFF0A100A), raised:Color(0xFF101910), text:Color(0xFFE6FFE6), accent:Color(0xFF64FF64), outline:Color(0xFF244024)),
    'terracotta-studio': MfPalette(background:Color(0xFFFBF0E7), surface:Color(0xFFFFFAF6), raised:Color(0xFFF4D9C8), text:Color(0xFF3D2921), accent:Color(0xFFB95F3D), outline:Color(0xFFD2A184)),
    'toxic': MfPalette(background:Color(0xFF0A0D03), surface:Color(0xFF151B05), raised:Color(0xFF202909), text:Color(0xFFF5FFD8), accent:Color(0xFFB6FF2E), outline:Color(0xFF465A12)),
    'volcano': MfPalette(background:Color(0xFF120807), surface:Color(0xFF24100C), raised:Color(0xFF36160F), text:Color(0xFFFFF2E9), accent:Color(0xFFFF5B21), outline:Color(0xFF6B2B1B)),
    'wine': MfPalette(background:Color(0xFF14090E), surface:Color(0xFF251019), raised:Color(0xFF351722), text:Color(0xFFFFF1F6), accent:Color(0xFFB94A70), outline:Color(0xFF623047)),
  };
  static const count = 111;
  static Color? parseColor(dynamic value) {
    if(value is! String) return null;
    final normalized=value.trim().replaceFirst('#','');
    if(!RegExp(r'^(?:[a-fA-F0-9]{6}|[a-fA-F0-9]{8})$').hasMatch(normalized))return null;
    return Color(int.parse(normalized.length==6?'FF$normalized':normalized,radix:16));
  }
  static MfPalette resolve(String theme, Map<String,dynamic> settings,{bool? overrideDark}) {
    final key=theme.toLowerCase();
    var current=presets[key] ?? _fallbackDark;
    if(key=='custom') {
      final custom=settings['customTheme'];
      if(custom is Map) {
        current=current.copyWith(
          background:parseColor(custom['bg']),
          surface:parseColor(custom['panel']),
          raised:parseColor(custom['raised']),
          text:parseColor(custom['text']),
          accent:parseColor(custom['accent']),
          outline:parseColor(custom['border']),
        );
      }
    }
    // Website-wide optional accent overrides take precedence when configured.
    final customAccent=parseColor(settings['accentColor']??settings['customAccent']??settings['flowColor']);
    if(customAccent!=null)current=current.copyWith(accent:customAccent);
    if(overrideDark!=null && current.isLight==overrideDark) {
      final base=overrideDark?_fallbackDark:_fallbackLight;
      current=base.copyWith(accent:current.accent);
    }
    return current;
  }
}
