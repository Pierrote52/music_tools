import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:music_tools/features/tuner/domain/entities/note.dart';
import 'package:music_tools/features/tuner/domain/entities/pitch_reading.dart';

void main() {
  group('PitchReading.fromFrequency', () {
    test('an exact A4 (440 Hz) is A4 with zero cents offset', () {
      final reading = PitchReading.fromFrequency(440);

      expect(reading.nearestNote, const Note(name: 'A', octave: 4));
      expect(reading.centsOffset, closeTo(0, 0.001));
      expect(reading.isInTune, isTrue);
    });

    test('an exact C4 (261.63 Hz, middle C) is recognized', () {
      final reading = PitchReading.fromFrequency(261.6256);

      expect(reading.nearestNote, const Note(name: 'C', octave: 4));
      expect(reading.centsOffset, closeTo(0, 0.5));
    });

    test('a frequency 20 cents sharp of A4 still reads as A4, offset +20', () {
      final sharpFrequency = 440 * math.pow(2, 20 / 1200);

      final reading = PitchReading.fromFrequency(sharpFrequency.toDouble());

      expect(reading.nearestNote, const Note(name: 'A', octave: 4));
      expect(reading.centsOffset, closeTo(20, 0.5));
    });

    test('a frequency slightly below A4 is flat and outside tolerance', () {
      final reading = PitchReading.fromFrequency(438);

      expect(reading.nearestNote, const Note(name: 'A', octave: 4));
      expect(reading.centsOffset, lessThan(0));
      expect(reading.isInTune, isFalse);
    });

    test('a custom reference pitch shifts the whole scale', () {
      // With A4 tuned to 432 Hz instead of 440 Hz, 432 Hz itself must read
      // as A4 in tune.
      final reading = PitchReading.fromFrequency(432, referenceA4Hz: 432);

      expect(reading.nearestNote, const Note(name: 'A', octave: 4));
      expect(reading.centsOffset, closeTo(0, 0.001));
    });
  });
}
