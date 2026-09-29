import 'package:meta/meta.dart';

import '../../domain/entities/beat.dart';
import '../../domain/entities/beat_pattern.dart';
import '../../domain/entities/metronome_settings.dart';
import '../../domain/entities/tempo.dart';

/// Immutable snapshot of everything the metronome screen needs to render.
///
/// There is no "is playing" flag: the metronome plays for as long as the
/// screen is shown (see `metronome_view_model.dart`).
@immutable
class MetronomeViewState {
  /// Creates a [MetronomeViewState].
  const MetronomeViewState({required this.settings, required this.currentBeat});

  /// The user-chosen tempo and beat pattern.
  final MetronomeSettings settings;

  /// The most recently played beat, or `null` if no beat of the current
  /// bar pattern has been played yet (e.g. right after the screen opens or
  /// the beat pattern changes).
  final Beat? currentBeat;

  /// The current tempo.
  Tempo get tempo => settings.tempo;

  /// The current beat pattern (beats per bar).
  BeatPattern get beatPattern => settings.beatPattern;

  /// Returns a copy of this state with the given fields replaced.
  ///
  /// [currentBeat] follows the usual "omit to keep, pass to replace"
  /// convention; pass [clearCurrentBeat] to explicitly reset it to `null`,
  /// since a plain `null` argument can't be distinguished from "not
  /// provided".
  MetronomeViewState copyWith({
    MetronomeSettings? settings,
    Beat? currentBeat,
    bool clearCurrentBeat = false,
  }) {
    return MetronomeViewState(
      settings: settings ?? this.settings,
      currentBeat: clearCurrentBeat ? null : (currentBeat ?? this.currentBeat),
    );
  }
}
