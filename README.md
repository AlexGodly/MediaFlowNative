# MediaFlow Native v3 — Active Full-Parity Port (Development Build)

**Target:** All website v372 functions, Android (`com.alexgodly.mediaflow`), Windows (`MediaFlow by Alex Godly.exe`), and iOS (requires Apple signing). **Full parity is not yet achieved**. This is a *real Flutter native project*, not a WebView.

## Implemented in this iteration

- Direct-title Personal Order: search/add, remove, drag reorder and stage in offline cache. Save to the SAME Supabase state only on explicit user upload; compare full original orderPlan and row updated_at before writing. All unrelated assignments/queues remain unchanged.
- A searchable native inspector for every saved account Settings key, including nested objects. **Read-only:** viewing a setting is not implementing its associated action.
- Read-only persisted XP audit, with streak XP precedence where present; legacy sessions without XP stay labeled unknown.
- Same native Library, Collections editing, History, statistics, cloud account, and draft functionality from v2.
- Pure Dart unit tests for ordering/conflict rejection, unchanged XP/session records and XP field precedence.

## Not implemented

Full official XP/Logging/History mutation and its dynamic settings, missions, every Library view, advanced Collection/Personal Order queues, full Dashboard, full import/export/restore, all web themes/settings, iOS installation and signing. See `docs/FEATURE_PARITY.md`.

## Installation, data protection

Download Android and Windows artifacts from the GitHub Actions run for the `native/v3-full-parity` branch. Preserve device drafts before uninstalling an older APK; ephemeral debug signing may block upgrades. For actual logging and XP, **continue using the website** until native cross-language golden fixtures and Supabase conflict tests pass. Back up your website data before testing cloud writes.

## Branding

Android application ID: `com.alexgodly.mediaflow`.
Windows executable, product name, and window title: `MediaFlow by Alex Godly`.
