import 'package:meta/meta.dart';

/// A tempo expressed in beats per minute (BPM).
///
/// The valid range ([minBpm]..[maxBpm]) is enforced at construction time so
/// that every other layer (ViewModel, View) can trust a [Tempo] instance
/// without re-validating it.
@immutable
class Tempo {
  /// Creates a [Tempo] of [bpm] beats per minute.
  ///
  /// Asserts that [bpm] is within [minBpm]..[maxBpm].
  const Tempo(this.bpm)
    : assert(
        bpm >= minBpm && bpm <= maxBpm,
        'bpm must be between $minBpm and $maxBpm',
      );

  /// Slowest tempo the metronome supports, in BPM.
  static const int minBpm = 20;

  /// Fastest tempo the metronome supports, in BPM.
  static const int maxBpm = 300;

  static const int _microsecondsPerMinute = 60 * 1000 * 1000;

  /// Beats per minute.
  final int bpm;

  /// The duration between two consecutive beats at this tempo.
  Duration get beatInterval =>
      Duration(microseconds: (_microsecondsPerMinute / bpm).round());

  /// Returns a copy of this tempo shifted by [deltaBpm], clamped to
  /// [minBpm]..[maxBpm] so it always produces a valid [Tempo].
  Tempo shiftedBy(int deltaBpm) =>
      Tempo((bpm + deltaBpm).clamp(minBpm, maxBpm));

  @override
  bool operator ==(Object other) => other is Tempo && other.bpm == bpm;

  @override
  int get hashCode => bpm.hashCode;

  @override
  String toString() => 'Tempo($bpm BPM)';
}
