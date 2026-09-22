import 'package:meta/meta.dart';

import '../../domain/entities/beat.dart';
import '../../domain/entities/beat_pattern.dart';
import '../../domain/entities/tempo.dart';

/// Immutable snapshot of everything the metronome screen needs to render.
@immutable
class MetronomeViewState {
  /// Creates a [MetronomeViewState].
  const MetronomeViewState({
    required this.tempo,
    required this.beatPattern,
    required this.isPlaying,
    required this.currentBeat,
  });

  /// The state the metronome screen starts in: stopped, at a default 120
  /// BPM / 4-beats-per-bar pattern, with no beat played yet.
  factory MetronomeViewState.initial() => const MetronomeViewState(
    tempo: Tempo(120),
    beatPattern: BeatPattern(),
    isPlaying: false,
    currentBeat: null,
  );

  /// The current tempo.
  final Tempo tempo;

  /// The current beat pattern (beats per bar).
  final BeatPattern beatPattern;

  /// Whether the metronome is currently ticking.
  final bool isPlaying;

  /// The most recently played beat, or `null` if the metronome hasn't
  /// played one yet (e.g. right after [MetronomeViewState.initial] or a
  /// [MetronomeViewModel.stop] — see `metronome_view_model.dart`).
  final Beat? currentBeat;

  /// Returns a copy of this state with the given fields replaced.
  ///
  /// [currentBeat] follows the usual "omit to keep, pass to replace"
  /// convention; pass [clearCurrentBeat] to explicitly reset it to `null`,
  /// since a plain `null` argument can't be distinguished from "not
  /// provided".
  MetronomeViewState copyWith({
    Tempo? tempo,
    BeatPattern? beatPattern,
    bool? isPlaying,
    Beat? currentBeat,
    bool clearCurrentBeat = false,
  }) {
    return MetronomeViewState(
      tempo: tempo ?? this.tempo,
      beatPattern: beatPattern ?? this.beatPattern,
      isPlaying: isPlaying ?? this.isPlaying,
      currentBeat: clearCurrentBeat ? null : (currentBeat ?? this.currentBeat),
    );
  }
}
