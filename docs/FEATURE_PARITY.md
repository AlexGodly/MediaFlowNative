# MediaFlow Native v1 — Feature Parity Matrix

**Baseline:** Web MediaFlow v372 · **Goal:** full native Flutter parity on Android, iOS, Windows.  
**Status:** first functional source milestone, not a feature-complete replacement.

| MediaFlow subsystem | Native v1 status | Notes |
|---|---|---|
| Supabase email/password authentication | Implemented in source | Existing project and public publishable key; same accounts |
| Web `mediaflow_states` JSONB cloud read | Implemented in source | gzip and uncompressed format |
| Cloud data-loss guard | Implemented in source | Existing row never initialized/overwritten from empty defaults |
| Local snapshot recovery cache | Implemented in source | Per-account gzip local files; not encrypted at rest |
| Library 30k+ browsing | Implemented in source | Lazy ListView/GridView; search/status/category filters |
| Full Library editing | Partial | Cover, priority, tags only. Do not edit progress/status via native yet |
| Native metadata cloud write | Implemented in source | Explicit upload, original-field conflict check, conditional `updated_at` update |
| Dashboard | Partial | Library counts and active titles; web recommendation/XP dashboard not ported |
| Collections | Read-only | Collection names, covers and assigned title lists |
| Personal Order | Read-only | Direct ordered titles; queue and drag behavior not ported |
| Consumption History | Read-only | Basic sessions and amounts; detailed itemized history not ported |
| Statistics | Partial | Counts by category/status; advanced stats not ported |
| Per unit Logging | Local draft editor | Can add/remove units, runtimes, repeat flag; **does not post official logs** |
| Quick Logging | Local draft editor | Amount consumed / Last Progress; **does not post official logs** |
| XP, streak engine and confirmed progress | Not ported | Keep using website for authoritative commits |
| History and XP writes | Not ported | **Protected by design:** native app never makes incomplete writes |
| Themes | Partial | Native dark/light and subset of shared theme colors; full custom theme parity pending |
| Offline mode | Partial | Cached snapshot and local logging drafts; offline authentication depends on existing session |
| Sync Now merge | Partial | Cloud read and guarded metadata upload, not full website merge engine |
| Imports / export / backup | Partial | Export current snapshot JSON into app Documents; no full import/restore |
| Category icons | Partial | Bundled or URL-based category icons displayed in title badges; further category UI parity pending |
| Mobile, tablet, desktop navigation | Implemented in source | Bottom navigation phones, native NavigationRail on Windows/tablet |
| Desktop drag and drop | Not ported | Requires native implementation |
| PWA / website | Unchanged | Website and native app coexist |

## Why write access is limited

MediaFlow v372 is not a simple CRUD database. Saving one logging session can update multiple coupled fields including progress, History, timestamps, XP ledger, streaks and offline/cloud merges. Directly writing only one field would produce inconsistent website data. The native app's initial release intentionally restricts cloud writes to metadata fields that can be preserved independently, with a concurrent-update check.

## Next milestones to reach true parity

1. Formal MediaFlow state-contract fixtures and migration compatibility suite from anonymized v372 backups.
2. Port canonical XP/History/Library mutation services; compare Dart and JS outcomes in golden fixtures before enabling cloud logging writes.
3. Offline operation queue with conflict-proof per-object merges and deletion tombstones.
4. Native Collections CRUD, Batch Log, dynamic Library, Personal Order drag/drop and queue workflows.
5. Full themes, Settings Center, exports/imports, Statistics, recommendation engine, achievements, missions, profile and additional systems.
6. Real Android/iOS/Windows release builds, performance profiling and staging sync tests.

Do not mark the app feature-complete until all mandatory workflows have equivalent behavior and migration testing.
