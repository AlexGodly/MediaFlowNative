# MediaFlow Native v2

**Independent cross-platform Flutter app for Android, iOS and Windows.**  
**Developed for the MediaFlow ecosystem by Alex Godly.**  
**Existing website baseline:** MediaFlow v372.

This is a real Flutter application, **not a WebView or PWA wrapper**. The existing MediaFlow website remains in place and uses the same Supabase account/database. Native v1 is a functional foundation and **does not yet contain every web feature**. Read `docs/FEATURE_PARITY.md` before using the app with important account data.

## Current functionality

- Native Supabase email/password login and sign-up using MediaFlow's existing backend.
- Read private `mediaflow_states` cloud snapshot, including v372's `__mediaflowCompressed:'gzip'` wrapper.
- Read-only Dashboard, Library, Collections, Personal Order, History and basic Statistics.
- Library title metadata edits (cover URL, priority, tags) staged locally with guarded, explicit cloud upload.
- Native Per unit and Quick Logging local-draft editor; **does not write incomplete XP/History/progress records to Supabase**.
- Offline per-account compressed snapshot cache and local logging-draft persistence.
- Theme-aware native Material 3 UI, bottom navigation on phones and navigation rail on wider layouts.
- Export a local JSON copy of the full snapshot to application documents.

## Website + native app side by side

The website is not changed or redirected. A user can sign into the native app using the same email/password. The Library displayed in the app comes from the existing cloud account, not a second database. Normal MediaFlow logging and the other features not yet ported should continue on the website until native parity is complete. Native metadata uploads include field-level conflict checks and conditional database updates; conflicting writes are rejected instead of overwriting newer cloud state.

## Build requirements

- Flutter stable SDK (Dart included).
- Android Studio / Android SDK and Java for Android.
- Visual Studio C++ Desktop workload on Windows for the native Windows executable.
- macOS + Xcode for iOS builds and Apple signing for install/distribution.
- Network access for `flutter pub get` and first build.

This ZIP contains the complete Flutter/Dart source, bundled MediaFlow branding and platform-generation/build scripts. It deliberately omits checked-in generated platform scaffolds; `flutter create` generates native Android/iOS/Windows host projects from this source.

### Build on Windows

```powershell
cd MediaFlow_Native_v1
powershell -ExecutionPolicy Bypass -File scripts/bootstrap-windows.ps1
flutter build windows --release
flutter build apk --release
```

### Build Android on Linux/macOS

```bash
cd MediaFlow_Native_v1
bash scripts/bootstrap-macos-linux.sh
flutter build apk --release
```

### Build for iPhone/iPad on macOS

```bash
cd MediaFlow_Native_v1
bash scripts/bootstrap-macos-linux.sh
flutter build ios --release
```

The iOS app requires signing with your Apple development team before it can be installed on physical devices. Unsigned CI builds are for validation only.

### Build through GitHub Actions

Upload this project into its own GitHub repository (recommended `MediaFlow-Native`, separate from your Pages site). Open **Actions → Build MediaFlow Native → Run workflow**. The included workflow generates host projects, analyzes code, runs tests and attempts Android APK, Windows executable and unsigned iOS build artifacts. **This workflow has been prepared but has not been run or certified yet.** The first CI build may reveal Flutter/SDK compatibility fixes that must be addressed.

## Supabase configuration

Uses the same **publishable** Supabase project URL/key as the v372 website (see `lib/core/config.dart`). Never place a `service_role` key in the application. Override public settings when building another environment:

```bash
flutter run --dart-define=MEDIAFLOW_SUPABASE_URL=https://YOURPROJECT.supabase.co --dart-define=MEDIAFLOW_SUPABASE_KEY=sb_publishable_...
```

There is **no Supabase SQL migration** included. Existing RLS policies must remain active. The native app will not create a cloud row on empty/error responses and will not silently replace a cloud snapshot with local defaults.

## Data-safe metadata workflow

1. Sign in and wait for the same Supabase Library to load.
2. Open any title, edit **cover URL, priority or tags**, then select **Save locally**.
3. On Account / Settings choose **Upload metadata edits** and confirm.
4. App refetches the current remote snapshot, rejects edited fields changed by the website since the edit was started, and conditionally updates the row only if `updated_at` still matches. If anything conflicts, it preserves your local edits instead of overwriting cloud data.

**Do not treat local native logging drafts as saved MediaFlow consumption sessions.** Official XP, History and progress are still posted via the website during this milestone.

## Privacy & limitations

Local compressed cache/drafts are stored in the user's application support directory. They are not encrypted at rest. Authentication uses the official Supabase client (tokens are never written into this repository). App release signing, store submissions, production cloud testing and real-device profiling remain outstanding.

See `docs/FEATURE_PARITY.md` for the exact implemented/incomplete matrix.

## Native v2 additions

Native Collections CRUD (including member editing and ordering), guarded cloud upload and History search/filters/per-unit inspection. **Native v2 is not full v372 parity yet; official consumption/XP commits remain on the website.** Read `docs/FEATURE_PARITY.md`.

### Native application identity

- Windows user-facing product and file name: **MediaFlow by Alex Godly** (`MediaFlow by Alex Godly.exe`).
- Android application ID: **`com.alexgodly.mediaflow`**; launcher label: **MediaFlow**.
- Run `python scripts/brand_platforms.py` after `flutter create` and before building. It updates platform host code and must be repeated if host folders are regenerated.
- Important: Android builds previously distributed as `com.alexgodly.mediaflow_native` are a **different application**; the newly named app can coexist with the old app, with separate local storage. Your existing Supabase account remains the same. Back up unsynced local changes before deleting the old app.
