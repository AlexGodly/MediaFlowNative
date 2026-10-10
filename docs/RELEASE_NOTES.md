# MediaFlow Native v1 — Foundation Release Notes

**Project:** MediaFlow Native · **Platform codebase:** Flutter / Dart  
**MediaFlow Website Baseline:** v372 · **Developer:** Alex Godly  
**Status:** Uncompiled source development candidate (Flutter SDK unavailable in packaging environment)

## 1. Separate App, Existing Website Preserved

- New Flutter native source project, separate from the GitHub Pages website.
- Does not change web MediaFlow's source, deployed assets, authentication, SQL schema, or existing cloud row.
- Android APK, Windows desktop, and iOS build workflows provided; they must still run successfully on supported toolchains.

## 2. Existing Supabase Compatibility

- Uses the publishable endpoint and key from the actual v372 website source.
- Email/password auth uses the existing Supabase Auth account.
- Cloud state is read from `mediaflow_states` using the authenticated user's ID.
- Supports v372's plain JSONB and `__mediaflowCompressed: gzip` Base64+gzip formats.
- Unknown data fields are preserved through decoding and re-encoding.
- Cloud load failures retain local data and do not initialize empty state remotely.

## 3. Native Interface

- Responsive Material 3 appearance with custom MediaFlow brand icon.
- Phone bottom navigation and desktop navigation rail.
- Dashboard, Library with filtering and lazy lists, Collections, Personal Order, Consumption History, basic Statistics, Settings / Account and Logging.
- Title covers, priority labels, category icons, statuses and title details.

## 4. Offline Support

- Per-account gzip snapshot caching in application support directory.
- Per-account local logging drafts, safely isolated from the web's canonical XP/History data.
- Local-only metadata staging supports cover URL, priority, and tags.

## 5. Guarded Metadata Synchronization

- Explicit user confirmation before upload.
- Refetches the remote snapshot immediately before upload.
- Checks edited field values against original baselines.
- Uses conditional update on `updated_at` to reject intervening cloud writes.
- Does not write progress/status/logs/XP without a parity-tested engine.

## 6. Known Gaps

Full web feature parity is **not yet implemented**. Refer to `FEATURE_PARITY.md`. Specifically, no website-equivalent XP/History mutations, comprehensive backups/imports, full custom themes, Batch Log, full Collection and Personal Order editors, achievements, or advanced Statistics have been ported. A native local draft does not count as a saved web consumption record.

## 7. Verification Performed

- File manifest, package/dependency YAML, asset count and workflows checked locally.
- Verified v372 Supabase endpoint matches native configuration.
- Verified gzip JSON wrapper structure with Python synthetic-data round-trip.
- Checked source has no WebView package or renderer.

**Not performed:** `flutter pub get`, `flutter analyze`, Dart unit/widget test execution, Android APK compilation, iOS compilation, Windows compilation, authenticated cloud sessions, or physical-device tests. Build readiness has not been certified.

## 8. Next Engineering Release

Compile through the provided CI, resolve analyzer/runtime issues, validate authenticated read-only cloud data on a staging account, and port canonical logging/XP/History before exposing full native writes.
