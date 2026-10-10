# MediaFlow Native v2 — Incremental parity release

**Baseline:** Native v1 + MediaFlow website v372 compatibility. **Developer:** Alex Godly.

## Implemented in this development pass

- Full native Collections editing surface: create, rename, edit description/cover, add/remove Library titles, reorder membership, and delete Collections.
- Offline staged Collection writes using original Collection snapshot baselines, with explicit Upload edits control.
- v372 Collection `titleIds`, `order`, `updatedAt` and `collectionTombstones` compatibility.
- Supabase per-object conflict validation and conditional timestamp write; no blind overwrite of unrelated MediaFlow fields.
- Expanded native Consumption History search, category filtering, date order, and itemized unit inspection from existing saved History entries.
- Added Collection mutation tests covering ordering, tombstones, unknown field preservation and conflict refusal.
- Maintained native Android and Windows installers and website coexistence.

## Not yet complete

Canonical consumption commits, XP/streak engine, complete Library editing, cloud offline merge, full settings, advanced dashboard, personal order editing, full exports and iOS signed build. They are still targets, not included features. Continue to use the website for official logging.

## Test status

Flutter analyzer, tests and Android/Windows release build verification must pass in GitHub Actions; physical device validation remains necessary.
