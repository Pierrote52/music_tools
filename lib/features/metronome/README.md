# features/metronome/

Metronome: plays an audible click at a configurable tempo (BPM) and beat
pattern, with an accent on the first beat of each bar.

Follows the feature's MVVM layering (see
[docs/ARCHITECTURE.md](../../../docs/ARCHITECTURE.md) for the full
rationale):

| Folder | Purpose |
|---|---|
| `domain/` | Pure Dart entities (`Tempo`, `BeatPattern`, ...) and the interfaces the ViewModel depends on (`MetronomeTicker`, `ClickPlayer`). No Flutter, no plugin imports. |
| `data/` | Concrete implementations of those interfaces, backed by a high-precision timer and an audio player. |
| `presentation/view/` | `MetronomeScreen` and its widgets. Reads state from, and forwards user actions to, the ViewModel. No business logic. |
| `presentation/viewmodel/` | `MetronomeViewModel`, exposing an immutable `MetronomeViewState` and orchestrating the `domain/` use cases. |

Empty for now — this is the first feature to be implemented, since it needs
no microphone/runtime permission.
