import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:music_tools/features/tuner/data/services/autocorrelation_pitch_estimator.dart';

/// Builds a pure sine wave at [frequencyHz], sampled at [sampleRate], as a
/// window of [sampleCount] normalized samples — a controlled stand-in for
/// real microphone input.
List<double> _sineWave({
  required double frequencyHz,
  required int sampleRate,
  required int sampleCount,
  double amplitude = 0.5,
}) {
  return [
    for (var i = 0; i < sampleCount; i++)
      amplitude * math.sin(2 * math.pi * frequencyHz * i / sampleRate),
  ];
}

void main() {
  const sampleRate = 44100;
  const sampleCount = 4096;

  group('estimateFrequency', () {
    test('finds the frequency of a 440 Hz sine wave (A4)', () {
      final samples = _sineWave(
        frequencyHz: 440,
        sampleRate: sampleRate,
        sampleCount: sampleCount,
      );

      final frequency = estimateFrequency(samples, sampleRate: sampleRate);

      expect(frequency, isNotNull);
      expect(frequency, closeTo(440, 440 * 0.02));
    });

    test('finds the frequency of a low 82.41 Hz sine wave (guitar low E)', () {
      final samples = _sineWave(
        frequencyHz: 82.41,
        sampleRate: sampleRate,
        sampleCount: sampleCount,
      );

      final frequency = estimateFrequency(samples, sampleRate: sampleRate);

      expect(frequency, isNotNull);
      expect(frequency, closeTo(82.41, 82.41 * 0.02));
    });

    test('finds the frequency of a high 987.77 Hz sine wave (B5)', () {
      final samples = _sineWave(
        frequencyHz: 987.77,
        sampleRate: sampleRate,
        sampleCount: sampleCount,
      );

      final frequency = estimateFrequency(samples, sampleRate: sampleRate);

      expect(frequency, isNotNull);
      expect(frequency, closeTo(987.77, 987.77 * 0.02));
    });

    test('detects the fundamental even with a strong 2nd harmonic present', () {
      // Real instruments rarely produce a pure sine: this mixes a 220 Hz
      // fundamental with a loud 440 Hz overtone, which is exactly the
      // scenario the local-maximum peak picking guards against — without
      // it, the estimator could lock onto the harmonic instead.
      final samples = [
        for (var i = 0; i < sampleCount; i++)
          0.5 * math.sin(2 * math.pi * 220 * i / sampleRate) +
              0.3 * math.sin(2 * math.pi * 440 * i / sampleRate),
      ];

      final frequency = estimateFrequency(samples, sampleRate: sampleRate);

      expect(frequency, isNotNull);
      expect(frequency, closeTo(220, 220 * 0.02));
    });

    test('returns null for silence', () {
      final silence = List<double>.filled(sampleCount, 0);

      expect(estimateFrequency(silence, sampleRate: sampleRate), isNull);
    });

    test('returns null for very low amplitude noise-floor samples', () {
      final quietNoise = _sineWave(
        frequencyHz: 440,
        sampleRate: sampleRate,
        sampleCount: sampleCount,
        amplitude: 0.001,
      );

      expect(estimateFrequency(quietNoise, sampleRate: sampleRate), isNull);
    });

    test('returns null when given too few samples', () {
      expect(estimateFrequency([0.1], sampleRate: sampleRate), isNull);
      expect(estimateFrequency(<double>[], sampleRate: sampleRate), isNull);
    });
  });
}
