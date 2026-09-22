import 'package:meta/meta.dart';

import 'beat.dart';

/// The rhythmic pattern the metronome repeats: how many beats make up one
/// bar, with the first beat of each bar accented.
///
/// This is where "which tick is the downbeat" is decided, independently of
/// *when* ticks happen (that's [MetronomeTicker]'s job) and of *how* a beat
/// sounds (that's [ClickSoundPlayer]'s job) — see
/// docs/ARCHITECTURE.md for the full layering rationale.
@immutable
class BeatPattern {
  /// Creates a [BeatPattern] of [beatsPerBar] beats per bar (defaults to a
  /// common 4/4 time signature).
  ///
  /// Asserts that [beatsPerBar] is within [minBeatsPerBar]..[maxBeatsPerBar].
  const BeatPattern({this.beatsPerBar = 4})
    : assert(
        beatsPerBar >= minBeatsPerBar && beatsPerBar <= maxBeatsPerBar,
        'beatsPerBar must be between $minBeatsPerBar and $maxBeatsPerBar',
      );

  /// Fewest beats a bar can have.
  static const int minBeatsPerBar = 1;

  /// Most beats a bar can have.
  static const int maxBeatsPerBar = 12;

  /// How many beats make up one bar (e.g. `4` for a 4/4 time signature).
  final int beatsPerBar;

  /// Returns the [Beat] for the given zero-based [tickIndex] since the
  /// metronome started, wrapping around every [beatsPerBar] ticks.
  Beat beatAt(int tickIndex) {
    final position = tickIndex % beatsPerBar;
    return Beat(position: position, isAccented: position == 0);
  }

  @override
  bool operator ==(Object other) =>
      other is BeatPattern && other.beatsPerBar == beatsPerBar;

  @override
  int get hashCode => beatsPerBar.hashCode;

  @override
  String toString() => 'BeatPattern(beatsPerBar: $beatsPerBar)';
}
