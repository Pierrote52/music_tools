import 'package:meta/meta.dart';

import 'beat_pattern.dart';
import 'tempo.dart';

/// The user-chosen configuration of the metronome: its [tempo] and
/// [beatPattern].
///
/// Kept separate from the playback state (current beat, tick count) so it
/// can outlive a single metronome session, e.g. be restored the next time
/// the metronome screen opens.
@immutable
class MetronomeSettings {
  /// Creates [MetronomeSettings], defaulting to 120 BPM in 4/4.
  const MetronomeSettings({
    this.tempo = const Tempo(120),
    this.beatPattern = const BeatPattern(),
  });

  /// The tempo to play at.
  final Tempo tempo;

  /// How many beats make up a bar.
  final BeatPattern beatPattern;

  /// Returns a copy of these settings with the given fields replaced.
  MetronomeSettings copyWith({Tempo? tempo, BeatPattern? beatPattern}) {
    return MetronomeSettings(
      tempo: tempo ?? this.tempo,
      beatPattern: beatPattern ?? this.beatPattern,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MetronomeSettings &&
      other.tempo == tempo &&
      other.beatPattern == beatPattern;

  @override
  int get hashCode => Object.hash(tempo, beatPattern);

  @override
  String toString() =>
      'MetronomeSettings(tempo: $tempo, beatPattern: $beatPattern)';
}
