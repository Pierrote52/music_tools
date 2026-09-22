# features/metronome/

Metronome: plays an audible click at a configurable tempo (BPM) and beat
pattern, with a haptic accent on the first beat of each bar.

Follows the feature's MVVM layering (see
[docs/ARCHITECTURE.md](../../../docs/ARCHITECTURE.md) for the full
rationale):

| Folder | Contents |
|---|---|
| `domain/entities/` | `Tempo` (validated BPM, converts to a beat interval), `Beat` and `BeatPattern` (which tick is the accented downbeat). Pure Dart, no Flutter import. |
| `domain/services/` | `MetronomeTicker` and `ClickSoundPlayer` interfaces the ViewModel depends on. |
| `data/services/` | `DriftCorrectedMetronomeTicker` (schedules ticks against an absolute target time so the beat doesn't drift) and `SystemClickSoundPlayer` (platform system sound + haptic accent, no bundled audio assets). Each exposes a Riverpod provider over its domain interface. |
| `presentation/viewmodel/` | `MetronomeViewModel` / `MetronomeViewState`: start/stop, tempo changes, beat pattern changes. |
| `presentation/view/` | `MetronomeScreen` and its `widgets/` (`BeatIndicator`, `TempoStepper`). |

Tests mirror this structure under
[test/features/metronome/](../../../test/features/metronome/), including
shared test doubles (`fakes/FakeMetronomeTicker`, `fakes/FakeClickSoundPlayer`)
used by both the ViewModel and View tests.

**Known limitation**: since this project ships no audio assets, every beat
currently reuses the platform's built-in click sound
(`SystemSoundType.click`); the accent is only distinguishable by an added
haptic pulse. Swapping in real click/accent audio files only requires a new
`ClickSoundPlayer` implementation in `data/services/` — the domain and
presentation layers wouldn't change.
