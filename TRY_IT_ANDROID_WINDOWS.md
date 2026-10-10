# Try MediaFlow Native v2 on your Android phone and Windows laptop

This is a real native Flutter preview, not a WebView or PWA. The website remains unchanged, and you sign in with the same MediaFlow account.

## Android

1. Download `MediaFlow_Native_v2_Android.apk`.
2. Copy it to your Android phone or download it directly from your phone.
3. Open the APK from your Files app, allow the installation source if your phone asks, and install.
4. Launch **MediaFlow** and sign in with your existing account.

The APK comes from the separate `native/v2-parity-development` branch in your GitHub repository. Only install the artifact you downloaded from the known source.

## Windows

1. Download `MediaFlow_Native_v2_Windows_Portable.zip`.
2. Extract the entire ZIP to a new folder.
3. Run `mediaflow_native.exe` while leaving every DLL and the `data` directory in place.
4. Sign in with your existing MediaFlow account.

This is a portable development build, not a signed MSI installer. Windows may display a warning for unsigned software.

## What to try in v2

- Browse your complete cloud Library, search/filter it, open titles and stage cover/priority/tag edits.
- Open **Collections**, create one, add existing Library titles, change the order, edit description/cover, or delete it.
- In **Settings**, use **Upload native edits** to synchronize staged Collections or metadata changes. The app first checks that the website/another device has not changed the same Collection or edited metadata field.
- In **History**, search for titles, filter by category, change chronological order, and expand a saved v369+ itemized logging session to inspect individual units.
- Test offline reloading of the cached Library and local logging drafts.

## Important limitations and safety

- v2 is not yet feature-complete. Official consumption logging, progress/XP/History commits, full custom themes, complete Personal Order editing, all Dashboard widgets and data import/restore are not ported.
- The website is still the authoritative interface for full-featured MediaFlow consumption and XP.
- The app never posts local-only logging drafts into the web History.
- Collection cloud edits are explicit and guarded, but this remains a development build. Make a Full Backup on the website before live testing. Use a test Collection first.
- iOS builds require a Mac, Xcode and signing; this package targets Android and Windows.

Full feature coverage: `docs/FEATURE_PARITY.md`.
Build status and downloadable CI artifacts: https://github.com/AlexGodly/MediaFlow/actions/workflows/native-installable-preview.yml
