import 'package:flutter_test/flutter_test.dart';
import 'package:mediaflow_native/shell_config.dart';
void main() {
  test('only original MediaFlow pages are allowed to export', () {
    expect(ShellConfig.isMediaFlowPage(Uri.parse(ShellConfig.homepage)), isTrue);
    expect(ShellConfig.isMediaFlowPage(Uri.parse('https://alexgodly.github.io/MediaFlow/?page=library')), isTrue);
    expect(ShellConfig.isMediaFlowPage(Uri.parse('https://alexgodly.github.io/MediaFlowX/')), isFalse);
    expect(ShellConfig.isMediaFlowPage(Uri.parse('http://alexgodly.github.io/MediaFlow/')), isFalse);
    expect(ShellConfig.isMediaFlowPage(Uri.parse('https://other-site.com/MediaFlow/')), isFalse);
  });
  test('file names are sanitized', () {
    expect(ShellConfig.safeFilename('title/export.json'), 'title_export.json');
    expect(ShellConfig.safeFilename('...'), 'MediaFlow-export.json');
  });
}
