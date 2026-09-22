import 'dart:async';

import 'package:music_tools/features/tuner/domain/services/pitch_detector.dart';

/// A [PitchDetector] test double that only emits values when the test
/// explicitly calls [emitFrequency] or [emitError], instead of listening
/// to a real microphone.
class FakePitchDetector implements PitchDetector {
  final StreamController<double?> _controller =
      StreamController<double?>.broadcast();

  /// How many times [start] was called.
  int startCallCount = 0;

  /// How many times [stop] was called.
  int stopCallCount = 0;

  @override
  Stream<double?> start() {
    startCallCount++;
    return _controller.stream;
  }

  @override
  Future<void> stop() async => stopCallCount++;

  /// Simulates the detector reporting a frequency (or `null` for silence).
  void emitFrequency(double? frequencyHz) => _controller.add(frequencyHz);

  /// Simulates the detector's stream failing (e.g. permission denied).
  void emitError(Object error) => _controller.addError(error);

  /// Releases the underlying controller.
  Future<void> dispose() => _controller.close();
}
