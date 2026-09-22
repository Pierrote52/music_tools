# core/

Cross-cutting code shared by every feature, with no dependency on any
specific feature.

| Folder | Purpose |
|---|---|
| `constants/` | Domain-agnostic constants used across tools (e.g. the reference pitch A4 = 440 Hz, note name tables). |
| `errors/` | Shared exception / failure types (e.g. a denied microphone permission) that features can catch and map to UI state. |
| `theme/` | `AppTheme`: the app's single source of colors, typography, and component defaults, derived from one seed color (see `AppTheme.light`). Feature widgets read from `Theme.of(context)` rather than hardcoding colors, so this is the one place to change to re-skin the whole app. |
| `utils/` | Small, pure helper functions with no Flutter or feature dependency. |

Nothing here should import from `features/`. If a helper is only useful to
one feature, it belongs in that feature's own folder instead — see
[docs/ARCHITECTURE.md](../../docs/ARCHITECTURE.md).
