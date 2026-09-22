import 'package:flutter/material.dart';

import '../../../domain/entities/pitch_reading.dart';

/// Shows the detected note name and frequency, or a placeholder when
/// nothing has been detected yet.
class NoteDisplay extends StatelessWidget {
  /// Creates a [NoteDisplay] for the current [reading] (or `null` if
  /// nothing has been detected).
  const NoteDisplay({required this.reading, super.key});

  /// The most recently detected pitch, or `null`.
  final PitchReading? reading;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          reading?.nearestNote.toString() ?? '—',
          style: textTheme.displayLarge,
        ),
        const SizedBox(height: 8),
        Text(
          reading == null
              ? 'Play a note'
              : '${reading!.frequencyHz.toStringAsFixed(1)} Hz',
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}
