import 'package:flutter/material.dart';

import '../../../domain/entities/pitch_reading.dart';

/// A color used for an in-tune reading, matching [NoteDisplay]'s badge so
/// the two widgets read as one consistent signal.
const Color _inTuneColor = Color(0xFF2ECC71);

/// A horizontal gauge showing how far off pitch [reading] is, from -50
/// (flat) to +50 (sharp) cents, with a marker that glides to its position
/// and turns green within [PitchReading.inTuneToleranceCents].
class CentsGauge extends StatelessWidget {
  /// Creates a [CentsGauge] for the current [reading] (or `null` if
  /// nothing has been detected, which centers the marker without
  /// highlighting it).
  const CentsGauge({required this.reading, super.key});

  static const double _displayRangeCents = 50;
  static const double _markerDiameter = 22;
  static const double _trackHeight = 10;

  /// The most recently detected pitch, or `null`.
  final PitchReading? reading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final clampedCents = (reading?.centsOffset ?? 0).clamp(
      -_displayRangeCents,
      _displayRangeCents,
    );
    final fraction =
        (clampedCents + _displayRangeCents) / (2 * _displayRangeCents);
    final markerColor = switch (reading) {
      null => colorScheme.onSurfaceVariant,
      final currentReading when currentReading.isInTune => _inTuneColor,
      _ => colorScheme.tertiary,
    };

    return SizedBox(
      height: 40,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final markerLeft =
              (fraction * constraints.maxWidth - _markerDiameter / 2).clamp(
                0.0,
                constraints.maxWidth - _markerDiameter,
              );

          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: _trackHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_trackHeight / 2),
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.tertiary.withValues(alpha: 0.45),
                      _inTuneColor.withValues(alpha: 0.5),
                      colorScheme.tertiary.withValues(alpha: 0.45),
                    ],
                  ),
                ),
              ),
              Container(
                width: 2,
                height: 24,
                color: colorScheme.outlineVariant,
              ),
              if (reading != null)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  left: markerLeft,
                  child: Container(
                    width: _markerDiameter,
                    height: _markerDiameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: markerColor,
                      boxShadow: [
                        BoxShadow(
                          color: markerColor.withValues(alpha: 0.45),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
