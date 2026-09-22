import 'package:flutter_test/flutter_test.dart';
import 'package:music_tools/features/metronome/domain/entities/beat_pattern.dart';

void main() {
  group('BeatPattern', () {
    test('defaults to 4 beats per bar', () {
      expect(const BeatPattern().beatsPerBar, 4);
    });

    test('rejects a beatsPerBar outside the supported range', () {
      expect(
        () => BeatPattern(beatsPerBar: BeatPattern.minBeatsPerBar - 1),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => BeatPattern(beatsPerBar: BeatPattern.maxBeatsPerBar + 1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('marks only the first beat of each bar as accented', () {
      const pattern = BeatPattern();

      final accents = [
        for (var tick = 0; tick < 8; tick++) pattern.beatAt(tick).isAccented,
      ];

      expect(accents, [true, false, false, false, true, false, false, false]);
    });

    test('wraps the beat position around beatsPerBar', () {
      const pattern = BeatPattern(beatsPerBar: 3);

      final positions = [
        for (var tick = 0; tick < 6; tick++) pattern.beatAt(tick).position,
      ];

      expect(positions, [0, 1, 2, 0, 1, 2]);
    });
  });
}
