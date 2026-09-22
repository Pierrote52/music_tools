import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

/// Synthesizes short "click" sounds as in-memory WAV audio, entirely at
/// runtime — no bundled audio asset files needed.
///
/// Each click is a brief sine burst shaped by a fade-in/fade-out envelope
/// (a hard-edged burst would produce an audible pop). The regular and
/// accented clicks differ in pitch, duration and loudness so they stay
/// distinguishable by ear.
class ClickSoundSynthesizer {
  /// Creates a [ClickSoundSynthesizer].
  const ClickSoundSynthesizer();

  static const int _sampleRate = 44100;
  static const int _bitsPerSample = 16;

  /// A short, lower-pitched blip for a regular beat.
  Uint8List get regularClick =>
      _synthesizeClick(frequencyHz: 1000, durationMs: 30, amplitude: 0.7);

  /// A short, higher-pitched, louder blip for the accented (first) beat.
  Uint8List get accentedClick =>
      _synthesizeClick(frequencyHz: 1600, durationMs: 35, amplitude: 0.9);

  Uint8List _synthesizeClick({
    required double frequencyHz,
    required int durationMs,
    required double amplitude,
  }) {
    final sampleCount = (_sampleRate * durationMs / 1000).round();
    final samples = Int16List(sampleCount);

    for (var i = 0; i < sampleCount; i++) {
      final progress = i / sampleCount;
      final envelope = _fadeInOutEnvelope(progress);
      final wave = math.sin(2 * math.pi * frequencyHz * i / _sampleRate);
      samples[i] = (wave * envelope * amplitude * 32767).round();
    }

    return _asWavFile(samples);
  }

  /// Ramps up over the first 10% of the click, holds, then ramps down
  /// over the last 30% — avoids the audible "click pop" a sudden
  /// start/stop would cause.
  double _fadeInOutEnvelope(double progress) {
    const fadeIn = 0.1;
    const fadeOutStart = 0.7;
    if (progress < fadeIn) {
      return progress / fadeIn;
    }
    if (progress > fadeOutStart) {
      return (1 - progress) / (1 - fadeOutStart);
    }
    return 1;
  }

  /// Wraps mono, 16-bit PCM [samples] in a minimal WAV (RIFF) file header,
  /// producing bytes ready to hand to an audio player.
  Uint8List _asWavFile(Int16List samples) {
    const channelCount = 1;
    final dataSize = samples.length * (_bitsPerSample ~/ 8);
    final byteRate = _sampleRate * channelCount * _bitsPerSample ~/ 8;
    final blockAlign = channelCount * _bitsPerSample ~/ 8;

    final header = BytesBuilder()
      ..add(ascii.encode('RIFF'))
      ..add(_uint32le(36 + dataSize))
      ..add(ascii.encode('WAVE'))
      ..add(ascii.encode('fmt '))
      ..add(_uint32le(16)) // fmt chunk size, fixed for PCM
      ..add(_uint16le(1)) // audio format: 1 = PCM
      ..add(_uint16le(channelCount))
      ..add(_uint32le(_sampleRate))
      ..add(_uint32le(byteRate))
      ..add(_uint16le(blockAlign))
      ..add(_uint16le(_bitsPerSample))
      ..add(ascii.encode('data'))
      ..add(_uint32le(dataSize));

    return (BytesBuilder()
          ..add(header.toBytes())
          ..add(_littleEndianBytes(samples)))
        .toBytes();
  }

  Uint8List _littleEndianBytes(Int16List samples) {
    final bytes = ByteData(samples.length * 2);
    for (var i = 0; i < samples.length; i++) {
      bytes.setInt16(i * 2, samples[i], Endian.little);
    }
    return bytes.buffer.asUint8List();
  }

  Uint8List _uint32le(int value) =>
      Uint8List(4)..buffer.asByteData().setUint32(0, value, Endian.little);

  Uint8List _uint16le(int value) =>
      Uint8List(2)..buffer.asByteData().setUint16(0, value, Endian.little);
}
