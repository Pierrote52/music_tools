# features/tuner/

Chromatic tuner: listens to the microphone, detects the pitch being played,
and shows the closest note plus the tuning offset in cents.

Follows the feature's MVVM layering (see
[docs/ARCHITECTURE.md](../../../docs/ARCHITECTURE.md) for the full
rationale):

| Folder | Purpose |
|---|---|
| `domain/` | Pure Dart entities (`Pitch`, `Note`, ...) and the interfaces the ViewModel depends on (`PitchDetector`, `AudioInputSource`). No Flutter, no plugin imports. |
| `data/` | Concrete implementations of those interfaces, backed by the microphone and a pitch-detection algorithm/plugin. |
| `presentation/view/` | `TunerScreen` and its widgets. Reads state from, and forwards user actions to, the ViewModel. No business logic. |
| `presentation/viewmodel/` | `TunerViewModel`, exposing an immutable `TunerViewState` and orchestrating the `domain/` use cases. |

Empty for now — implemented once the walking skeleton (step 4) is in place.
