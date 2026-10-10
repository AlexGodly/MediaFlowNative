#!/usr/bin/env python3
"""Apply MediaFlow product branding to Flutter-generated native host projects.

Run AFTER `flutter create --platforms=...` and BEFORE `flutter build`.
Idempotent: harmless if applied more than once.
"""
from __future__ import annotations

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
WINDOWS_NAME = 'MediaFlow by Alex Godly'
ANDROID_ID = 'com.alexgodly.mediaflow'


def replace_in(path: Path, replacements: list[tuple[str, str]], *, required: bool = True) -> None:
    if not path.exists():
        if required:
            raise FileNotFoundError(path)
        return
    before = path.read_text(encoding='utf-8')
    after = before
    for original, replacement in replacements:
        after = after.replace(original, replacement)
    if after == before and required:
        print(f'Branding already applied or no matching patterns in {path.relative_to(ROOT)}')
    path.write_text(after, encoding='utf-8')


def android() -> None:
    gradle = ROOT / 'android/app/build.gradle.kts'
    if not gradle.exists():
        return
    source = gradle.read_text(encoding='utf-8')
    source = re.sub(r'(?m)^\s*namespace\s*=\s*"[^"]+"', f'    namespace = "{ANDROID_ID}"', source)
    source = re.sub(r'(?m)^\s*applicationId\s*=\s*"[^"]+"', f'        applicationId = "{ANDROID_ID}"', source)
    if f'applicationId = "{ANDROID_ID}"' not in source or f'namespace = "{ANDROID_ID}"' not in source:
        raise RuntimeError('Android applicationId/namespace could not be configured')
    gradle.write_text(source, encoding='utf-8')

    manifest = ROOT / 'android/app/src/main/AndroidManifest.xml'
    contents = manifest.read_text(encoding='utf-8')
    if 'android.permission.INTERNET' not in contents:
        contents = contents.replace('<application', '<uses-permission android:name="android.permission.INTERNET" />\n    <application', 1)
    contents = re.sub(r'android:label="[^"]*"', 'android:label="MediaFlow"', contents, count=1)
    manifest.write_text(contents, encoding='utf-8')

    # Change Kotlin MainActivity's package as well (not only the Gradle app ID).
    kotlin_dir = ROOT / 'android/app/src/main/kotlin'
    activities = list(kotlin_dir.rglob('MainActivity.kt'))
    if len(activities) != 1:
        raise RuntimeError(f'Expected one Kotlin MainActivity, found {len(activities)}')
    existing = activities[0]
    target = kotlin_dir / 'com/alexgodly/mediaflow/MainActivity.kt'
    activity_code = existing.read_text(encoding='utf-8')
    activity_code = re.sub(r'(?m)^package\s+[^\s]+', f'package {ANDROID_ID}', activity_code, count=1)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(activity_code, encoding='utf-8')
    if existing != target:
        existing.unlink()
    print(f'Android application ID and Kotlin namespace: {ANDROID_ID}')


def windows() -> None:
    cmake = ROOT / 'windows/CMakeLists.txt'
    if not cmake.exists():
        return
    cmake_text = cmake.read_text(encoding='utf-8')
    cmake_text, updated = re.subn(r'set\(BINARY_NAME\s+"[^"]+"\)', 'set(BINARY_NAME "MediaFlow")', cmake_text, count=1)
    if updated != 1:
        raise RuntimeError('Cannot locate Flutter Windows BINARY_NAME')
    if '_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS' not in cmake_text:
        cmake_text = 'add_compile_definitions(_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS)\n' + cmake_text
    cmake.write_text(cmake_text, encoding='utf-8')

    runner_cpp = ROOT / 'windows/runner/main.cpp'
    cpp_text = runner_cpp.read_text(encoding='utf-8')
    cpp_text, title_updates = re.subn(r'window\.Create\(L"[^"]+"', f'window.Create(L"{WINDOWS_NAME}"', cpp_text, count=1)
    if title_updates != 1:
        raise RuntimeError('Cannot find Windows window.Create title')
    runner_cpp.write_text(cpp_text, encoding='utf-8')

    rc = ROOT / 'windows/runner/Runner.rc'
    source = rc.read_text(encoding='utf-8')
    # Flutter uses BINARY_NAME in generated VERSIONINFO; explicitly supply user-facing metadata.
    values = {
        'FileDescription': WINDOWS_NAME,
        'ProductName': WINDOWS_NAME,
        'InternalName': 'MediaFlow',
        'OriginalFilename': f'{WINDOWS_NAME}.exe',
    }
    for key, name in values.items():
        # Examples from Flutter templates: VALUE "FileDescription", "${BINARY_NAME}" "\\0"
        pattern = rf'(VALUE\s+"{key}"\s*,\s*)"[^"]*"'
        source, count = re.subn(pattern, lambda match: f'{match.group(1)}"{name}"', source, count=1)
        if not count:
            raise RuntimeError(f'Cannot find Windows VERSIONINFO key {key}')
    rc.write_text(source, encoding='utf-8')
    print(f'Windows window title, product metadata, and exe branding: {WINDOWS_NAME}')


if __name__ == '__main__':
    android()
    windows()
