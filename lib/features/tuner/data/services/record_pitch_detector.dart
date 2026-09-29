import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';

import '../../domain/services/pitch_detector.dart';
import 'autocorrelation_pitch_estimator.dart';

/// A [PitchDetector] backed by the device microphone (via the `record`
/// package) and [estimateFrequency] for the actual signal analysis.
///
/// Buffers incoming PCM16 audio into fixed-size windows and emits one
/// frequency estimate per window, so the concrete audio-plumbing (mic
/// permission, byte decoding, buffering) stays entirely separate from the
/// pitch-estimation algorithm it delegates to.
class RecordPitchDetector implements PitchDetector {
  /// Creates a [RecordPitchDetector]. An [AudioRecorder] can be injected
  /// for testing; production code should use the default.
  RecordPitchDetector({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  static const int _sampleRate = 44100;

  /// ~93 ms of audio: long enough to contain several periods of even a low
  /// guitar E (82 Hz), short enough to feel responsive.
  static const int _windowSizeInSamples = 4096;

  final AudioRecorder _recorder;
  final List<double> _sampleBuffer = [];
  StreamSubscription<Uint8List>? _micSubscription;
  StreamController<double?>? _controller;

  @override
  Stream<double?> start() {
    final controller = StreamController<double?>();
    _controller = controller;
    unawaited(_startCapturing(controller));
    return controller.stream;
  }

  Future<void> _startCapturing(StreamController<double?> controller) async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      controller.addError(const MicrophonePermissionDeniedException());
      return;
    }

    final micStream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        // Explicit despite matching RecordConfig's current default: the
        // estimator below relies on knowing the exact capture rate, so
        // this must never silently drift from _sampleRate.
        // ignore: avoid_redundant_argument_values
        sampleRate: _sampleRate,
        numChannels: 1,
      ),
    );

    _sampleBuffer.clear();
    _micSubscription = micStream.listen(
      (chunk) => _onAudioChunk(chunk, controller),
    );
  }

  void _onAudioChunk(Uint8List chunk, StreamController<double?> controller) {
    _sampleBuffer.addAll(_decodePcm16(chunk));

    while (_sampleBuffer.length >= _windowSizeInSamples) {
      final window = _sampleBuffer.sublist(0, _windowSizeInSamples);
      _sampleBuffer.removeRange(0, _windowSizeInSamples);

      controller.add(estimateFrequency(window, sampleRate: _sampleRate));
    }
  }

  /// Decodes little-endian, 16-bit signed PCM bytes into samples
  /// normalized to `[-1, 1]`.
  List<double> _decodePcm16(Uint8List bytes) {
    final byteData = ByteData.sublistView(bytes);
    return [
      for (var offset = 0; offset + 1 < bytes.length; offset += 2)
        byteData.getInt16(offset, Endian.little) / 32768,
    ];
  }

  @override
  Future<void> stop() async {
    await _micSubscription?.cancel();
    _micSubscription = null;
    await _recorder.stop();
    _sampleBuffer.clear();
    await _controller?.close();
    _controller = null;
  }
}

/// Provides the [PitchDetector] implementation used by the app.
///
/// The ViewModel depends on the [PitchDetector] interface, never on
/// [RecordPitchDetector] directly, so tests can override this provider
/// with a fake instead of requesting real microphone access.
final pitchDetectorProvider = Provider<PitchDetector>((ref) {
  return RecordPitchDetector();
});
