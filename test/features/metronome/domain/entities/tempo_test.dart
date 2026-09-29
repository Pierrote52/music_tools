import 'package:flutter_test/flutter_test.dart';
import 'package:music_tools/features/metronome/domain/entities/tempo.dart';

void main() {
  group('Tempo', () {
    test('rejects a bpm below minBpm', () {
      expect(() => Tempo(Tempo.minBpm - 1), throwsA(isA<AssertionError>()));
    });

    test('rejects a bpm above maxBpm', () {
      expect(() => Tempo(Tempo.maxBpm + 1), throwsA(isA<AssertionError>()));
    });

    test('beatInterval converts bpm to the correct duration', () {
      expect(const Tempo(60).beatInterval, const Duration(seconds: 1));
      expect(const Tempo(120).beatInterval, const Duration(milliseconds: 500));
      expect(const Tempo(240).beatInterval, const Duration(milliseconds: 250));
    });

    test('shiftedBy adds the delta within range', () {
      expect(const Tempo(120).shiftedBy(5), const Tempo(125));
      expect(const Tempo(120).shiftedBy(-5), const Tempo(115));
    });

    test('shiftedBy clamps at the supported boundaries', () {
      expect(
        const Tempo(Tempo.minBpm).shiftedBy(-100),
        const Tempo(Tempo.minBpm),
      );
      expect(
        const Tempo(Tempo.maxBpm).shiftedBy(100),
        const Tempo(Tempo.maxBpm),
      );
    });

    test('two tempos with the same bpm are equal', () {
      expect(const Tempo(90), const Tempo(90));
    });
  });
}
