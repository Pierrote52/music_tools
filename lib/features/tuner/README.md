# features/tuner/

Chromatic tuner: listens to the microphone, detects the pitch being played,
and shows the closest note plus the tuning offset in cents.

Follows the feature's MVVM layering (see
[docs/ARCHITECTURE.md](../../../docs/ARCHITECTURE.md) for the full
rationale):

| Folder | Contents |
|---|---|
| `domain/entities/` | `Note` (scientific pitch notation, e.g. `A4`) and `PitchReading` (a detected frequency converted into the nearest note plus a cents offset, against a configurable A4 reference). Pure Dart, no Flutter import. |
| `domain/services/` | `PitchDetector` interface the ViewModel depends on, and `MicrophonePermissionDeniedException`. |
| `data/services/` | `estimateFrequency` (a dependency-free autocorrelation pitch estimator, unit-tested against synthetic sine waves) and `RecordPitchDetector` (captures microphone audio via the `record` package and feeds it to the estimator). Exposes a Riverpod provider over the domain interface. |
| `presentation/viewmodel/` | `TunerViewModel` / `TunerViewState`: start/stop listening, tracks the current reading and any error. |
| `presentation/view/` | `TunerScreen` and its `widgets/` (`NoteDisplay`, `CentsGauge`). |

Tests mirror this structure under
[test/features/tuner/](../../../test/features/tuner/), including a shared
test double (`fakes/FakePitchDetector`) used by both the ViewModel and
View tests.

**Known limitation**: pitch detection uses a simple time-domain
autocorrelation algorithm, not a more robust one like YIN. It performs
well on a clean, monophonic signal (a single plucked/sung note) but can be
thrown off by heavy background noise or multiple simultaneous notes.
Swapping in a different algorithm only requires a new `PitchDetector`
implementation in `data/services/` — the domain and presentation layers
wouldn't change.
