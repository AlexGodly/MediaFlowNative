#!/usr/bin/env python3
"""Offline package checks. These do not replace flutter analyze/test/build."""
import sys, pathlib, re, yaml, json, base64, gzip, zipfile
root = pathlib.Path(__file__).resolve().parent.parent
ref = pathlib.Path('/mnt/data/v372_project/src/js/core/constants/001-constants.js')
src = (root/'lib/core/config.dart').read_text()
assert 'SUPABASE_URL' not in src or 'supabaseUrl' in src
assert 'wgeijxfdpgehesxialxm' in src
assert 'sb_publishable_' in src
assert 'service_role' not in src.lower()
expected = ['lib/main.dart','lib/ui/auth.dart','lib/ui/shell.dart','lib/ui/pages.dart',
 'lib/ui/logging.dart','lib/data/mediaflow_repository.dart',
 'lib/data/mediaflow_snapshot.dart','test/snapshot_test.dart',
 '.github/workflows/build-native.yml','docs/FEATURE_PARITY.md']
for f in expected:
 assert (root/f).exists(),f
pubspec=yaml.safe_load((root/'pubspec.yaml').read_text())
assert pubspec['name']=='mediaflow_native'
assert 'supabase_flutter' in pubspec['dependencies']
assert 'path_provider' in pubspec['dependencies']
assert (root/'assets/mediaflow.png').exists()
assert len(list((root/'assets/category-icons').glob('*.png'))) == 22
workflow=yaml.safe_load((root/'.github/workflows/build-native.yml').read_text())
assert {'android','ios','windows'}<=set(workflow['jobs'])
code='\n'.join(p.read_text() for p in (root/'lib').rglob('*.dart'))
assert not re.search(r'(?i)webview|inappwebview|htmlrenderer|flutter_inappwebview',code)
assert "from('mediaflow_states')" in code
assert "'__mediaflowCompressed': 'gzip'" in code
assert "'updated_at', row['updated_at']" in code
assert 'uploadPendingMetadata' in code and 'stageTitleMetadata' in code
assert 'NativeDraftStore' in code
sample={'library':[{'id':'a1','title':'Sample','status':'watching','futureProperty':{'hello':'world'}}],
 'settings':{'theme':'dark'},'xpLedger':{'libraryAdditions':{}},'sessions':[],
 'unknownFutureTopLevel':[1,2,3]}
wrapped={'__mediaflowCompressed':'gzip','data':base64.b64encode(gzip.compress(json.dumps(sample).encode())).decode()}
assert json.loads(gzip.decompress(base64.b64decode(wrapped['data'])))==sample
print('PASS: native source layout, Supabase URL/key type, JSONB codec contract markers, safe-edit markers, bundled assets, 3 build workflows and no WebView.')
print('NOTE: Flutter SDK is unavailable here. Dart compilation, Flutter tests and actual binaries are NOT verified.')
