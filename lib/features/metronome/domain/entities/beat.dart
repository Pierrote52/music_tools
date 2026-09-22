import 'package:meta/meta.dart';

/// A single beat produced by the metronome while it is running.
@immutable
class Beat {
  /// Creates a [Beat] at [position] within its bar.
  const Beat({required this.position, required this.isAccented});

  /// Zero-based position of this beat within its bar (e.g. `0` for the
  /// first beat of a 4/4 bar, up to `3`).
  final int position;

  /// Whether this beat should be played louder/differently, marking the
  /// start of a new bar.
  final bool isAccented;

  @override
  bool operator ==(Object other) =>
      other is Beat &&
      other.position == position &&
      other.isAccented == isAccented;

  @override
  int get hashCode => Object.hash(position, isAccented);

  @override
  String toString() => 'Beat(position: $position, isAccented: $isAccented)';
}
