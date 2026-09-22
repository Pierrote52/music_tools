import 'package:flutter/material.dart';

import '../../../domain/entities/pitch_reading.dart';

/// A horizontal gauge showing how far off pitch [reading] is, from -50
/// (flat) to +50 (sharp) cents, with a centered marker turning green when
/// within [PitchReading.inTuneToleranceCents].
class CentsGauge extends StatelessWidget {
  /// Creates a [CentsGauge] for the current [reading] (or `null` if
  /// nothing has been detected, which centers the marker without
  /// highlighting it).
  const CentsGauge({required this.reading, super.key});

  static const double _displayRangeCents = 50;
  static const double _markerDiameter = 18;

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

    return SizedBox(
      height: 32,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final markerLeft =
              fraction * constraints.maxWidth - _markerDiameter / 2;

          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Container(width: 2, height: 20, color: colorScheme.outline),
              if (reading != null)
                Positioned(
                  left: markerLeft.clamp(
                    0,
                    constraints.maxWidth - _markerDiameter,
                  ),
                  child: Container(
                    width: _markerDiameter,
                    height: _markerDiameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: reading!.isInTune
                          ? Colors.green
                          : colorScheme.error,
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
