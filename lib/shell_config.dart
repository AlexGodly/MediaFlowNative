class ShellConfig {
  static const homepage = 'https://alexgodly.github.io/MediaFlow/';
  static final homeUri = Uri.parse(homepage);
  static bool isMediaFlowPage(Uri? uri) =>
      uri != null && uri.scheme == 'https' && uri.host == homeUri.host &&
      (uri.path == '/MediaFlow' || uri.path.startsWith('/MediaFlow/'));
  static String safeFilename(String name) {
    var clean = name.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1f]'), '_').trim();
    clean = clean.replaceAll(RegExp(r'[. ]+$'), '');
    if (clean.isEmpty || clean == '.' || clean == '..') {
      return 'MediaFlow-export.json';
    }
    if (clean.length > 125) {
      final dot = clean.lastIndexOf('.');
      final ext = dot > 0 ? clean.substring(dot).substring(0, 12) : '';
      clean = clean.substring(0, 125 - ext.length) + ext;
    }
    return clean;
  }
}
