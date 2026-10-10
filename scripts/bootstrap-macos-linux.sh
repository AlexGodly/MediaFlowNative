#!/usr/bin/env bash
set -euo pipefail
if ! command -v flutter >/dev/null 2>&1; then
  echo 'Flutter SDK not found. Install it first: https://docs.flutter.dev/get-started/install'
  exit 1
fi
if [[ "$(uname -s)" == "Darwin" ]]; then
  flutter create --platforms=ios,android --org com.alexgodly --project-name mediaflow_native .
else
  flutter create --platforms=android --org com.alexgodly --project-name mediaflow_native .
fi
flutter pub get
if [[ "$(uname -s)" == "Darwin" ]]; then
  dart run flutter_launcher_icons -f flutter_launcher_icons_ios.yaml
else
  dart run flutter_launcher_icons -f flutter_launcher_icons_android.yaml
fi
dart format lib test
flutter analyze --no-fatal-infos
flutter test
echo 'Native MediaFlow project is ready.'
