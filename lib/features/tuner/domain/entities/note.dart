import 'package:meta/meta.dart';

/// A musical note in standard scientific pitch notation (e.g. `A4`, `C#5`),
/// using 12-tone equal temperament.
@immutable
class Note {
  /// Creates a [Note] named [name] (e.g. `'A'`, `'C#'`) in the given
  /// [octave] (using scientific pitch notation, where middle C is `C4`).
  const Note({required this.name, required this.octave});

  /// Builds the [Note] closest to the given (rounded) MIDI note number,
  /// e.g. `69` -> `A4`, `60` -> `C4`.
  factory Note.fromMidiNumber(int midiNumber) {
    final chromaticIndex = midiNumber % chromaticScale.length;
    final octave = (midiNumber ~/ chromaticScale.length) - 1;
    return Note(name: chromaticScale[chromaticIndex], octave: octave);
  }

  /// Names of the 12 semitones of an octave, starting at C — matching the
  /// convention where MIDI note number 60 is `C4` (see [fromMidiNumber]).
  static const List<String> chromaticScale = [
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B',
  ];

  /// The note's name without octave, e.g. `'A'` or `'C#'`.
  final String name;

  /// The note's octave in scientific pitch notation, e.g. `4` for middle C.
  final int octave;

  @override
  bool operator ==(Object other) =>
      other is Note && other.name == name && other.octave == octave;

  @override
  int get hashCode => Object.hash(name, octave);

  @override
  String toString() => '$name$octave';
}
