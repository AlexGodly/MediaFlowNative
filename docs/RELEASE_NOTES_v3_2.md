# MediaFlow Native v3.2 — Visual Design Candidate

## Implemented in this candidate
- Premium media-first Dashboard using actual account data and real title covers.
- Responsive desktop navigation and touch-friendly Android bottom navigation.
- Account login branded as MediaFlow by Alex Godly, with redesigned authentication screen.
- Built-in palette token bridge derived from **111 MediaFlow website v372 themes**, plus custom-theme color map.
- Searchable native theme chooser; per-account local preference, **not** written into website settings.
- Shared card, badge, feature-panel, metric, and section-heading components.
- Existing v3.1 Library, Collections, History, Personal Order staging, native account, and safe-edit behavior retained.

## Not achieved
This is **not** a 100% functional port of MediaFlow v372. Native official Logging/XP/History writes, complete Settings handlers, Batch Log, advanced Personal Order queues, XP missions, backups/restore and other features are incomplete. Website remains the canonical implementation for these workflows.

## Data safety
The redesign does not change cloud schemas. It does not enable unsafe logging, XP, or other previously withheld write actions. UI theme changes remain device-local.

## Platform identifiers
Android: com.alexgodly.mediaflow
Windows executable: MediaFlow by Alex Godly.exe

## Test scope
Static verification, Flutter analyzer, Flutter widget/unit tests and GitHub Actions builds; physical-device smoke testing remains required.
