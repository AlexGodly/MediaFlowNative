# MediaFlow Native v2 — Development Feature Parity

Baseline: website MediaFlow v372. v2 is a native Android/Windows development release and is **not yet 100% feature-parity**.

| Area | Native v2 status | Notes |
|---|---|---|
| Android / Windows standalone applications | Built by GitHub Actions | Flutter native, no WebView |
| iPhone / iPad | Flutter source target | Requires macOS/Xcode/signing |
| Login + existing Supabase | Functional source | Same project, same account, user-scoped RLS |
| Cloud snapshot gzip JSONB | Implemented | Preserves unknown JSON properties |
| Offline snapshot | Implemented | Per-account cache, device-local, not encrypted at rest |
| Library browsing/filtering | Implemented | Lazy list/grid, 30k+ title focus |
| Title detail metadata edits | Partial, cloud-safe | Cover, priority, tags only, staged with CAS |
| Collections | **Native v2 improved** | Create/edit/delete, membership add/remove, title reordering, safe cloud upload with tombstones |
| Consumption History | **Native v2 improved** | Search, category filter, sort, itemized unit inspection (read-only) |
| Dashboard | Partial | Basic overview and continue titles |
| Personal Order | Read-only | Direct title order display, not collection queue editing |
| Statistics | Partial | Status/category summary |
| Per unit Logging | Local drafts | Official v372 XP/History/save engine **NOT** yet ported |
| Quick Logging | Local drafts | Two modes; official log commits **NOT** yet ported |
| Full Library CRUD | Incomplete | Website maintains canonical progress/status/XP writes |
| Batch Log | Not ported | Must match canonical website logging pipeline |
| XP / levels / streaks / missions | Not ported | Viewing metrics is not equivalent to implementing rewards |
| Custom themes / full Settings Center | Incomplete | Partial native styling and account controls |
| Full backup/import/restore | Incomplete | Native local JSON snapshot export only |
| Rewatch/season History | Partial | Read-only detail inspection |
| Online data loss protection | Implemented for supported edits | Conditional updated_at CAS, per-object original baseline; rejects conflicts |
| Web and native coexistence | Supported | Same backend, separate apps, do not deploy over website |

## Security and correctness

- Collection changes and safe title metadata changes remain local until explicitly uploaded.
- Each upload fetches the latest remote snapshot, verifies original Collection objects (and metadata fields), and applies changes only after all checks pass.
- Supabase conditional row update with prior `updated_at` prevents overwriting concurrent saves.
- Collection deletion creates v372 `collectionTombstones` and does not delete Library titles.
- Missing cloud snapshot is **never replaced** with a blank native one.
- Local caches are not encrypted at rest. Avoid installing on shared or untrusted devices until protected storage is added.
- Native v2 logging remains local drafts. Never confuse drafts with official web-synced records.

## Remaining parity milestones

1. Port canonical v372 logging, progress, timestamp, XP, repeat XP, History and streak engines with cross-language golden fixtures.
2. Full Library mutation pipeline and batch actions.
3. Personal Order queues/drag-and-drop and advanced Collections tools.
4. Dashboard, Statistics, missions, achievements and every settings control.
5. Full data export/import, backup/restore, cloud/offline conflict merge and custom themes.
6. Actual Android and Windows device smoke tests and signed iOS build.

Do not label this feature-complete until the website v372 parity matrix and golden tests are genuinely satisfied.
