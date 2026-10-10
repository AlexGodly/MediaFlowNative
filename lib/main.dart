import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:file_saver/file_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'shell_config.dart';
import 'web_export_bridge.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF0E111A), statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0E111A), systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const MediaFlowApp());
}
class MediaFlowApp extends StatelessWidget {
  const MediaFlowApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    title: 'MediaFlow by Alex Godly', debugShowCheckedModeBanner: false,
    theme: ThemeData(brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0E111A),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8FAAFF), brightness: Brightness.dark)),
    home: const MediaFlowWebsite(),
  );
}
class _ExportState {
  _ExportState(this.path, this.filename, this.expected, this.sink);
  final String path, filename;
  final int expected;
  final IOSink sink;
  int received = 0;
}
class MediaFlowWebsite extends StatefulWidget {
  const MediaFlowWebsite({super.key});
  @override State<MediaFlowWebsite> createState() => _MediaFlowWebsiteState();
}
class _MediaFlowWebsiteState extends State<MediaFlowWebsite> {
  static const maxExportSize = 512 * 1024 * 1024;
  InAppWebViewController? _browser;
  final Map<int, _ExportState> _exports = {};
  int _exportSequence = 0;
  bool _loaded = false, _offline = false;
  Future<bool> _authorized() async {
    final value = await _browser?.getUrl();
    return ShellConfig.isMediaFlowPage(value == null ? null : Uri.tryParse(value.toString()));
  }
  Future<int> _begin(List<dynamic> args) async {
    if (!await _authorized()) throw StateError('Untrusted export page');
    if (args.length != 2 || args[0] is! String || args[1] is! num) {
      throw const FormatException('Invalid export request');
    }
    final length = (args[1] as num).toInt();
    if (length < 0 || length > maxExportSize) throw StateError('Export too large');
    final folder = await getTemporaryDirectory();
    final id = ++_exportSequence;
    final path = folder.path + Platform.pathSeparator + 'mediaflow-export-' + id.toString() + '.tmp';
    _exports[id] = _ExportState(path, ShellConfig.safeFilename(args[0] as String),
      length, File(path).openWrite());
    return id;
  }
  Future<bool> _append(List<dynamic> args) async {
    if (!await _authorized()) throw StateError('Untrusted export page');
    if (args.length != 2 || args[0] is! num || args[1] is! String) {
      throw const FormatException('Invalid export chunk');
    }
    final state = _exports[(args[0] as num).toInt()];
    if (state == null) throw StateError('Export no longer active');
    final b64 = args[1] as String;
    if (b64.length > 200000) throw StateError('Chunk too large');
    final data = base64Decode(b64);
    if (state.received + data.length > state.expected) throw StateError('Export size mismatch');
    state.sink.add(data);
    state.received += data.length;
    return true;
  }
  Future<bool> _finish(List<dynamic> args) async {
    if (!await _authorized()) throw StateError('Untrusted export page');
    if (args.length != 1 || args[0] is! num) throw const FormatException('Invalid export ID');
    final state = _exports.remove((args[0] as num).toInt());
    if (state == null) throw StateError('Export no longer active');
    try {
      await state.sink.flush();
      await state.sink.close();
      if (state.received != state.expected) throw StateError('Incomplete export');
      final dot = state.filename.lastIndexOf('.');
      final name = dot > 0 ? state.filename.substring(0, dot) : state.filename;
      final ext = dot > 0 ? state.filename.substring(dot + 1) : '';
      final saved = await FileSaver.instance.saveAs(
        name: name, filePath: state.path, fileExtension: ext, mimeType: MimeType.other);
      return saved != null;
    } finally {
      try { await File(state.path).delete(); } catch (_) {}
    }
  }
  Future<bool> _cancel(List<dynamic> args) async {
    if (args.length != 1 || args[0] is! num) return false;
    final state = _exports.remove((args[0] as num).toInt());
    if (state == null) return false;
    await state.sink.close();
    try { await File(state.path).delete(); } catch (_) {}
    return true;
  }
  Future<void> _download(DownloadStartRequest request) async {
    final url = Uri.tryParse(request.url.toString());
    if (url != null && url.scheme == 'https') {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
  Future<void> _goBack() async {
    final controller = _browser;
    if (controller != null && await controller.canGoBack()) {
      await controller.goBack();
    } else {
      await SystemNavigator.pop();
    }
  }
  @override void dispose() {
    for (final state in _exports.values) {
      state.sink.close();
      File(state.path).delete().catchError((Object error) => File(state.path));
    }
    super.dispose();
  }
  @override Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) { if (!didPop) _goBack(); },
    child: Scaffold(body: SafeArea(child: Stack(children: [
      InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(ShellConfig.homepage)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true, domStorageEnabled: true, databaseEnabled: true,
          cacheEnabled: true, transparentBackground: false,
          mediaPlaybackRequiresUserGesture: false, useOnDownloadStart: true,
          javaScriptCanOpenWindowsAutomatically: true, supportMultipleWindows: true,
          allowFileAccessFromFileURLs: false, allowUniversalAccessFromFileURLs: false,
        ),
        initialUserScripts: UnmodifiableListView<UserScript>([
          UserScript(source: webExportBridge,
            injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
            forMainFrameOnly: true,
            allowedOriginRules: {'https://alexgodly.github.io'}),
        ]),
        onWebViewCreated: (controller) {
          _browser = controller;
          controller.addJavaScriptHandler(handlerName: 'mfBeginExport', callback: _begin);
          controller.addJavaScriptHandler(handlerName: 'mfAppendExport', callback: _append);
          controller.addJavaScriptHandler(handlerName: 'mfFinishExport', callback: _finish);
          controller.addJavaScriptHandler(handlerName: 'mfCancelExport', callback: _cancel);
        },
        onLoadStop: (controller, url) {
          if (mounted) setState(() { _loaded = true; _offline = false; });
        },
        onReceivedError: (controller, request, error) {
          if (request.isForMainFrame == true && mounted) setState(() => _offline = true);
        },
        onDownloadStartRequest: (controller, request) => _download(request),
        onCreateWindow: (controller, action) async {
          final url = Uri.tryParse(action.request.url?.toString() ?? '');
          if (url != null && (url.scheme == 'http' || url.scheme == 'https')) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
          return false;
        },
      ),
      if (!_loaded && !_offline)
        const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      if (_offline) ColoredBox(color: const Color(0xFF0E111A),
        child: Center(child: Padding(padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off_rounded, size: 40),
            const SizedBox(height: 16),
            const Text('MediaFlow is unavailable',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
            const SizedBox(height: 8),
            const Text('Check your connection and try again.', textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () async {
                setState(() => _offline = false);
                await _browser?.reload();
              },
              icon: const Icon(Icons.refresh_rounded), label: const Text('Retry'),
            ),
          ])))),
    ]))),
  );
}
