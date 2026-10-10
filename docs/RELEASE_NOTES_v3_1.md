# MediaFlow Native v3.1 — Library functionality parity milestone

**Not a 100% parity release.** The target is feature-for-feature compatibility with the MediaFlow website v372, but this build improves native Library coverage only. Do not assume it includes the website's full logging, XP, dashboard, scheduler, settings, import/export, and backup engines.

## New in this development build

- Native Library views: List, Compact, Cards, Covers, Covers+Titles.
- Search across titles and saved tags.
- Filters by status, category, priority, cover presence.
- Sorting by title, progress, total, rating, priority, and modification date; ascending/descending.
- Expandable Library filter area and reset controls.
- Multi-title selection with Select Visible, Clear, and bulk priority staging.
- Device-local persistence of view, sort, cover filter and filter visibility, scoped to the signed-in account.
- Title Details also support rating (0–10) and description editing, staged locally alongside cover, priority and tags.
- Existing metadata upload uses v372 Supabase snapshot refetch, per-field baseline conflict checks, and conditional row update. No undocumented progress or XP writes were enabled.
- Tests include a synthetic 30,000-title Library filter stress case, sorting and combined filter contracts.

## Existing from v3

- Native Windows and Android apps, Supabase sign-in and existing snapshot loading, local cache.
- Collections editing and deletions staged with per-object conflict checks and tombstones.
- Direct-title Personal Order editing with conflict checks.
- Consumption History browsing, read-only XP audit and Settings inspector.
- Local-only logging draft editor (NOT official consumption/XP/History logging).

## Remaining critical parity gaps

Complete official Logging/XP/History commits, streaks, achievements and missions; full Library title creation/progress/deletion; Batch Log; advanced Personal Order queues; the entire functional Settings Center and theme catalog; importers and lossless backup restoration; offline reconciliation; and iOS signed testing. Real-device performance and cloud concurrency remain to be verified.

**App identities unchanged:** Windows `MediaFlow by Alex Godly.exe`; Android `com.alexgodly.mediaflow`. Website and live database are not changed by building this release.
