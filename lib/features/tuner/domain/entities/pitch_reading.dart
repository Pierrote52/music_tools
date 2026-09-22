import 'dart:math' as math;

import 'package:meta/meta.dart';

import 'note.dart';

/// A single pitch measurement: a detected frequency, the closest note in
/// 12-tone equal temperament, and how far off that note the frequency is,
/// in cents (1/100th of a semitone).
@immutable
class PitchReading {
  /// Creates a [PitchReading]. Prefer [PitchReading.fromFrequency], which
  /// derives [nearestNote] and [centsOffset] for you.
  const PitchReading({
    required this.frequencyHz,
    required this.nearestNote,
    required this.centsOffset,
  });

  /// Computes the [PitchReading] for a detected [frequencyHz], relative to
  /// the standard concert pitch [referenceA4Hz].
  factory PitchReading.fromFrequency(
    double frequencyHz, {
    double referenceA4Hz = PitchReading.referenceA4Hz,
  }) {
    assert(frequencyHz > 0, 'frequencyHz must be positive');

    // MIDI note number 69 is A4 by convention; each semitone away from it
    // multiplies the frequency by 2^(1/12).
    final exactMidiNumber =
        69 + 12 * (math.log(frequencyHz / referenceA4Hz) / math.ln2);
    final nearestMidiNumber = exactMidiNumber.round();
    final centsOffset = (exactMidiNumber - nearestMidiNumber) * 100;

    return PitchReading(
      frequencyHz: frequencyHz,
      nearestNote: Note.fromMidiNumber(nearestMidiNumber),
      centsOffset: centsOffset,
    );
  }

  /// The standard concert pitch reference: A4 = 440 Hz.
  static const double referenceA4Hz = 440.0;

  /// A reading within this many cents of its [nearestNote] is considered
  /// in tune.
  static const double inTuneToleranceCents = 5;

  /// The detected frequency, in Hz.
  final double frequencyHz;

  /// The closest note to [frequencyHz].
  final Note nearestNote;

  /// How far [frequencyHz] is from [nearestNote], in cents. Negative means
  /// flat (too low), positive means sharp (too high).
  final double centsOffset;

  /// Whether [centsOffset] is within [inTuneToleranceCents] of zero.
  bool get isInTune => centsOffset.abs() <= inTuneToleranceCents;

  @override
  bool operator ==(Object other) =>
      other is PitchReading &&
      other.frequencyHz == frequencyHz &&
      other.nearestNote == nearestNote &&
      other.centsOffset == centsOffset;

  @override
  int get hashCode => Object.hash(frequencyHz, nearestNote, centsOffset);

  @override
  String toString() =>
      'PitchReading($frequencyHz Hz, $nearestNote, ${centsOffset.toStringAsFixed(1)} cents)';
}
