/// Listens to an audio input and reports the fundamental frequency it
/// detects.
///
/// This is the only abstraction the ViewModel depends on for pitch
/// detection: how audio is captured (microphone) and how the frequency is
/// estimated (signal processing algorithm) are `data/`-layer details — see
/// docs/ARCHITECTURE.md.
abstract class PitchDetector {
  /// Starts listening and returns a stream that emits the detected
  /// frequency in Hz for each analysis window, or `null` when no clear
  /// pitch could be found (silence, noise, or an unpitched sound).
  ///
  /// May emit a [MicrophonePermissionDeniedException] as a stream error if
  /// the user hasn't granted microphone access.
  Stream<double?> start();

  /// Stops listening. Safe to call even if not currently listening.
  Future<void> stop();
}

/// Thrown (as a [Stream] error from [PitchDetector.start]) when the user
/// has not granted microphone permission.
class MicrophonePermissionDeniedException implements Exception {
  /// Creates a [MicrophonePermissionDeniedException].
  const MicrophonePermissionDeniedException();

  @override
  String toString() =>
      'MicrophonePermissionDeniedException: microphone access was denied';
}
