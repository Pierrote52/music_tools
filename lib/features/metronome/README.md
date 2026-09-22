# features/metronome/

Metronome: plays an audible click at a configurable tempo (BPM) and beat
pattern, with a distinct sound (and a haptic pulse) on the accented first
beat of each bar.

Follows the feature's MVVM layering (see
[docs/ARCHITECTURE.md](../../../docs/ARCHITECTURE.md) for the full
rationale):

| Folder | Contents |
|---|---|
| `domain/entities/` | `Tempo` (validated BPM, converts to a beat interval), `Beat` and `BeatPattern` (which tick is the accented downbeat). Pure Dart, no Flutter import. |
| `domain/services/` | `MetronomeTicker` and `ClickSoundPlayer` interfaces the ViewModel depends on. |
| `data/services/` | `DriftCorrectedMetronomeTicker` (schedules ticks against an absolute target time so the beat doesn't drift); `ClickSoundSynthesizer` (generates short click sounds as in-memory WAV audio, no bundled asset files) and `AudioClickSoundPlayer` (plays them via `audioplayers`, on the media volume stream, plus a haptic pulse on the accent). Each service exposes a Riverpod provider over its domain interface. |
| `presentation/viewmodel/` | `MetronomeViewModel` / `MetronomeViewState`: start/stop, tempo changes, beat pattern changes. |
| `presentation/view/` | `MetronomeScreen` and its `widgets/` (`BeatIndicator`, `TempoStepper`). |

Tests mirror this structure under
[test/features/metronome/](../../../test/features/metronome/), including
shared test doubles (`fakes/FakeMetronomeTicker`, `fakes/FakeClickSoundPlayer`)
used by both the ViewModel and View tests.

**Note on the click sound**: an earlier version played the platform's
built-in `SystemSoundType.click`, which turned out to be silent on many
devices — it depends on the system's "touch sounds" setting and its own
volume stream, neither of which an app controls. `AudioClickSoundPlayer`
instead plays a real (synthesized, not asset-based) sound through the
media volume stream, which is reliable regardless of that system setting.
