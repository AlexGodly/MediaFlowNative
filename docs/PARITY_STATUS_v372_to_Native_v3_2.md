# MediaFlow v372 Website → Native v3.2: Functional Parity Review

**Assessment date:** 2026-10-10  
**Website source:** MediaFlow v372 modular project (`272` JavaScript modules)  
**Native source:** MediaFlow Native Flutter v3.2 design candidate  
**Completion:** **NOT 100%**. Do not describe this app as a feature-complete website replacement.

## How this audit is scored

- **Working (subset)** means a native control exists and its intended current behavior has source and automated test coverage, although full live-device validation may remain.
- **Partial** means the native page/function exists but the website has additional features or behaviors not ported.
- **Absent** means no native functional equivalent of the corresponding website workflow is implemented.
- Visual representation and a read-only settings inspector **never** count as functional parity.

| Website capability | Native v3.2 status | Exact scope / blockers |
|---|---|---|
| Authentication and existing Supabase account | Working subset | Email/password and password reset; real-device login still needs smoke testing |
| Shared compressed `mediaflow_states` snapshot read | Working subset | gzip-wrapped JSONB decoder, per-account local cache, validation |
| Offline local cache | Partial | Local cache and queued supported metadata edits; canonical offline logging and multi-device merges missing |
| Concurrent cloud change protection | Partial | CAS for supported metadata, Collections and direct Personal Order; entire web sync engine not ported |
| Dashboard overview | Partial | Actual Library, sessions, collections and progress summaries; numerous web widgets/tools absent |
| Dashboard recommendations | Partial | Actual title cover / featured or active title; web recommendation algorithms & reroll controls not ported |
| Stopwatch / runtime calculator / goals / Rate Your Library | Absent | Web components and preferences require functional Dart port |
| Library list/compact/cards/covers/covers+titles | Working subset | v3.1 native views with filters and sorting |
| Library Normal / Dynamic behavioral parity | Partial | Missing all Dynamic specific ordering/dragging and controls |
| Library title search, category/status/priority, cover filtering | Working subset | UI and filtering, not every web sort/filter variation |
| Library covers, category art & icon choices | Partial | Actual cover URLs, some category icons; all overlay controls and missing-art parity incomplete |
| Library add/delete/status/progress/total/seasons editing | Absent or partial | Protected: official web XP/History/save pipeline still needed |
| Library safe metadata edits | Working subset | Stage/upload covers, tags, description, rating, priority with conflict checks |
| Library batch controls | Partial | Batch priority staging; status/category/delete/restore workflows absent |
| Logging Per unit | Partial | Local draft editing; **no official cloud consumption commit** |
| Logging Quick — Amount Consumed | Partial | Local draft UI only |
| Logging Quick — Last Progress | Partial | Local draft UI only |
| Seasons/rewatch, per-unit timestamps, runtime/XP | Partial | Draft fields; canonical actions and repeat XP are not ported |
| XP levels, streaks, History side-effects | Absent | Read-only XP inspector is not a calculation engine |
| Missions, achievements, daily goals | Absent | Website behavior not ported |
| Collections create/edit/delete/title membership/order | Working subset | Locally staged and conflict-checked cloud upload; advanced layouts and some batch features absent |
| Collections Queue & more advanced controls | Partial or absent | Web-specific queue controls and full batch workflows missing |
| Personal Order direct titles add/remove/reorder | Working subset | Locally staged and conflict-checked |
| Personal Order assigned Collection queues and per-category queues | Absent | Web queue algorithms, presentation and exports need exact port |
| Batch Log | Absent | No native equivalent yet |
| Consumption History | Partial | Read/search/filter/itemized inspection, no complete History edits or official logged commits |
| Library History | Absent or partial | Web actions and exports not ported |
| Statistics / XP charts | Partial | Basic status/category summaries; complete calculations and charts missing |
| Settings Center | Partial | Saved-values read-only explorer; **not** every native setting handler |
| Website v372 built-in themes | Partial | **111 static color palettes mapped**; other CSS effects, dynamic cover-based themes and layout presets not ported |
| Custom theme color palette | Partial | Native renders common website custom colors, with local-only override picker |
| Category create/edit/recover/default icon management | Absent | UI and mutation parity require port |
| Full Data backup / restore, automatic backups | Absent | Native local snapshot JSON export only; not a verified full backup/restore |
| MAL/SIMKL and CSV/XML/JSON importers | Absent | Parsing, provider data and merge behavior missing |
| Settings Presets / export/import | Absent | No full native version of website presets |
| PWA install, Service Worker & browser updates | N/A | Correct native equivalent is installable app and platform update mechanism; no WebView |
| Windows executable and Android package identity | Working subset | Windows `MediaFlow by Alex Godly.exe`; Android `com.alexgodly.mediaflow`; continuous signed release update key still needed |
| iPhone/iPad installed app | Unverified | Flutter shared source exists; macOS Xcode and signing/device test required |
| Low-end device performance, 50k Library | Unverified | Synthetic 30k filter test, no physical performance or memory verification |

## Visual design progress in v3.2

- New theme-derived color system, including **111** source-mapped website theme palettes and custom base colors.
- New premium responsive desktop rail, branded app bar and mobile bottom navigation.
- Actual account Library cover-led Dashboard, wide highlighted title, progress insight cards and active-title poster rail.
- Account appearance picker with per-account local persistence; does not overwrite website settings.
- New authentication presentation with Android/Windows branding.
- Shared native panels, accent surfaces, badges, headers and focus styling.

## Hard release gate to claim 100%

1. Extract every relevant v372 Settings control and every website action, with tests and expected data side effects.
2. Port canonical Logging / XP / Progress / History and repeat/rewatch/streak algorithms to Dart with cross-language reference fixtures.
3. Port full Library CRUD, all batch actions, queues, data management and importers.
4. Validate multi-device concurrent cloud writes, offline queue reconciliation and zero-loss migration/backups against a staging account.
5. Run platform UI and integration tests on physical Android phones, Windows PCs, and signed iOS devices, including low-end benchmarks.
6. Complete keyboard, accessibility, responsiveness, light/dark, dynamic cover-theme and custom theme edge cases.

**Parities checked are not parities passed.** This report is deliberately conservative to protect existing MediaFlow account data.
