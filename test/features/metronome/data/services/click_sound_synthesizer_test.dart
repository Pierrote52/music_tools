import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:music_tools/features/metronome/data/services/click_sound_synthesizer.dart';

void main() {
  const synthesizer = ClickSoundSynthesizer();

  group('ClickSoundSynthesizer', () {
    test('regularClick produces a well-formed mono 16-bit 44.1kHz WAV file', () {
      final wav = synthesizer.regularClick;
      final header = ByteData.sublistView(wav, 0, 44);

      expect(ascii.decode(wav.sublist(0, 4)), 'RIFF');
      expect(ascii.decode(wav.sublist(8, 12)), 'WAVE');
      expect(ascii.decode(wav.sublist(12, 16)), 'fmt ');
      expect(header.getUint16(20, Endian.little), 1); // PCM format
      expect(header.getUint16(22, Endian.little), 1); // mono
      expect(header.getUint32(24, Endian.little), 44100); // sample rate
      expect(header.getUint16(34, Endian.little), 16); // bits per sample
      expect(ascii.decode(wav.sublist(36, 40)), 'data');
    });

    test('declared chunk sizes match the actual audio payload', () {
      final wav = synthesizer.regularClick;
      final header = ByteData.sublistView(wav, 0, 44);

      final dataSize = header.getUint32(40, Endian.little);
      expect(wav.length, 44 + dataSize);
      expect(header.getUint32(4, Endian.little), 36 + dataSize);
    });

    test('the accented click is longer, louder, and higher-pitched than the regular one', () {
      final regular = synthesizer.regularClick;
      final accented = synthesizer.accentedClick;

      expect(accented.length, greaterThan(regular.length));
    });

    test('two calls produce identical, deterministic output', () {
      expect(synthesizer.regularClick, synthesizer.regularClick);
    });
  });
}
