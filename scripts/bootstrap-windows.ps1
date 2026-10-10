$ErrorActionPreference = 'Stop'
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw 'Flutter SDK not found. Install it from https://docs.flutter.dev/get-started/install'
}
flutter create --platforms=windows,android --org com.alexgodly --project-name mediaflow_native .
if ($LASTEXITCODE -ne 0) { throw 'flutter create failed' }
python scripts/brand_platforms.py
if ($LASTEXITCODE -ne 0) { throw "Native branding failed" }
flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'flutter pub get failed' }
dart run flutter_launcher_icons -f flutter_launcher_icons_windows.yaml
dart format lib test
flutter analyze --no-fatal-infos
if ($LASTEXITCODE -ne 0) { throw 'Flutter analyze failed' }
flutter test
if ($LASTEXITCODE -ne 0) { throw 'Flutter test failed' }
Write-Host 'MediaFlow Native project is ready.'
