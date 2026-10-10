# MediaFlow Native v3 — Development Feature Parity

Baseline: website MediaFlow v372. v3 is a native Android/Windows development release and is **not yet 100% feature-parity**.

| Area | Native v3 status | Notes |
|---|---|---|
| Android / Windows standalone applications | Built by GitHub Actions | Flutter native, no WebView |
| iPhone / iPad | Flutter source target | Requires macOS/Xcode/signing |
| Login + existing Supabase | Functional source | Same project, same account, user-scoped RLS |
| Cloud snapshot gzip JSONB | Implemented | Preserves unknown JSON properties |
| Offline snapshot | Implemented | Per-account cache, device-local, not encrypted at rest |
| Library browsing/filtering | Implemented | Lazy list/grid, 30k+ title focus |
| Title detail metadata edits | Partial, cloud-safe | Cover, priority, tags only, staged with CAS |
| Collections | **Native v3 retained** | Create/edit/delete, membership add/remove, title reordering, safe cloud upload with tombstones |
| Consumption History | **Native v3 retained** | Search, category filter, sort, itemized unit inspection (read-only) |
| Dashboard | Partial | Basic overview and continue titles |
| Personal Order | **Partial edit support** | Add/remove/reorder direct titles; category queues and assigned-Collection actions remain website-only; safe staged updates with whole-object conflict checks |
| Statistics | Partial | Status/category summary |
| Per unit Logging | Local drafts | Official v372 XP/History/save engine **NOT** yet ported |
| Quick Logging | Local drafts | Two modes; official log commits **NOT** yet ported |
| Full Library CRUD | Incomplete | Website maintains canonical progress/status/XP writes |
| Batch Log | Not ported | Must match canonical website logging pipeline |
| XP / levels / streaks / missions | Incomplete | Safe read-only audit of persisted XP and library-addition XP, no canonical engine or mutation |
| Custom themes / full Settings Center | Incomplete | Native settings inspector now searches and displays every stored account preference (read-only); web settings controls and theme engine not ported |
| Full backup/import/restore | Incomplete | Native local JSON snapshot export only |
| Rewatch/season History | Partial | Read-only detail inspection |
| Online data loss protection | Implemented for supported edits | Conditional updated_at CAS, per-object original baseline; rejects conflicts |
| Web and native coexistence | Supported | Same backend, separate apps, do not deploy over website |

## Security and correctness

- Collection changes, direct Personal Order changes, and safe title metadata edits remain local until explicitly uploaded.
- Each upload fetches the latest remote snapshot, verifies original Collection objects, Personal Order snapshot and title metadata fields, and applies changes only after all checks pass.
- Supabase conditional row update with prior `updated_at` prevents overwriting concurrent saves.
- Collection deletion creates v372 `collectionTombstones` and does not delete Library titles.
- Missing cloud snapshot is **never replaced** with a blank native one.
- Local caches are not encrypted at rest. Avoid installing on shared or untrusted devices until protected storage is added.
- Native v2 logging remains local drafts. Never confuse drafts with official web-synced records.

## Remaining parity milestones

1. Port canonical v372 logging, progress, timestamp, XP, repeat XP, History and streak engines with cross-language golden fixtures.
2. Full Library mutation pipeline and batch actions.
3. Complete Personal Order assigned-Collection queues, category queues, and advanced Collections tools; direct title reorder now staged.
4. Dashboard, Statistics, missions, achievements and every settings control.
5. Full data export/import, backup/restore, cloud/offline conflict merge and custom themes.
6. Actual Android and Windows device smoke tests and signed iOS build.

Do not label this feature-complete until the website v372 parity matrix and golden tests are genuinely satisfied.

## v3 acceptance gate

Full parity is **not achieved**. The next build is a tested incremental development milestone. To claim EVERYTHING, every web-side page, option, workflow and side effect must be mapped to a native implementation with data compatibility tests, plus installed Android, Windows and iOS checks. Do not conflate visibility of web settings or local log drafts with working native functionality.

## Updated APK signing note

GitHub Actions Flutter default Android release builds may be signed with an ephemeral debug key. Two builds having the same `com.alexgodly.mediaflow` package ID does **not** guarantee Android accepts an in-place update. Configure a persistent signing key in GitHub Actions secrets for reliable upgrades; otherwise export local draft data before uninstalling the prior build.
