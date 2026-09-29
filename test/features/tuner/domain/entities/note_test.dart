import 'package:flutter_test/flutter_test.dart';
import 'package:music_tools/features/tuner/domain/entities/note.dart';

void main() {
  group('Note.fromMidiNumber', () {
    test('maps MIDI 69 to A4 (concert pitch reference)', () {
      expect(Note.fromMidiNumber(69), const Note(name: 'A', octave: 4));
    });

    test('maps MIDI 60 to C4 (middle C)', () {
      expect(Note.fromMidiNumber(60), const Note(name: 'C', octave: 4));
    });

    test('maps MIDI 61 to C#4', () {
      expect(Note.fromMidiNumber(61), const Note(name: 'C#', octave: 4));
    });

    test('wraps to the next octave at B -> C', () {
      expect(Note.fromMidiNumber(71), const Note(name: 'B', octave: 4));
      expect(Note.fromMidiNumber(72), const Note(name: 'C', octave: 5));
    });
  });

  group('Note', () {
    test('toString renders name followed by octave', () {
      expect(const Note(name: 'A', octave: 4).toString(), 'A4');
      expect(const Note(name: 'C#', octave: 5).toString(), 'C#5');
    });

    test('two notes with the same name and octave are equal', () {
      expect(
        const Note(name: 'A', octave: 4),
        const Note(name: 'A', octave: 4),
      );
    });
  });
}
