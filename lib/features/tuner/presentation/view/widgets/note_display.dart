import 'package:flutter/material.dart';

import '../../../domain/entities/pitch_reading.dart';

/// A color used for an in-tune reading, distinct from the theme's palette
/// so "in tune" reads as an unambiguous, universally green signal.
const Color _inTuneColor = Color(0xFF2ECC71);

/// Shows the detected note name in a colored badge — green when in tune,
/// the theme's accent color otherwise — plus the raw frequency, or a
/// placeholder when nothing has been detected yet.
class NoteDisplay extends StatelessWidget {
  /// Creates a [NoteDisplay] for the current [reading] (or `null` if
  /// nothing has been detected).
  const NoteDisplay({required this.reading, super.key});

  static const double _badgeDiameter = 180;

  /// The most recently detected pitch, or `null`.
  final PitchReading? reading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accentColor = switch (reading) {
      null => colorScheme.onSurfaceVariant,
      final currentReading when currentReading.isInTune => _inTuneColor,
      _ => colorScheme.tertiary,
    };

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: _badgeDiameter,
          height: _badgeDiameter,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accentColor.withValues(alpha: 0.12),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.5),
              width: 3,
            ),
          ),
          child: Text(
            reading?.nearestNote.toString() ?? '—',
            style: textTheme.displayLarge?.copyWith(color: accentColor),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          reading == null
              ? 'Play a note'
              : '${reading!.frequencyHz.toStringAsFixed(1)} Hz',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
