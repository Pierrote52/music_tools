import 'package:flutter/material.dart';

import '../../../domain/entities/tempo.dart';

/// Displays the current [tempo] with +/- buttons to change it by one BPM.
class TempoStepper extends StatelessWidget {
  /// Creates a [TempoStepper] for [tempo], calling [onDecrement] /
  /// [onIncrement] when the corresponding button is pressed.
  const TempoStepper({
    required this.tempo,
    required this.onDecrement,
    required this.onIncrement,
    super.key,
  });

  /// The tempo currently displayed.
  final Tempo tempo;

  /// Called when the user taps the decrease-tempo button.
  final VoidCallback onDecrement;

  /// Called when the user taps the increase-tempo button.
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onDecrement,
          icon: const Icon(Icons.remove_circle_outline),
          tooltip: 'Decrease tempo',
        ),
        SizedBox(
          width: 120,
          child: Text(
            '${tempo.bpm} BPM',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        IconButton(
          onPressed: onIncrement,
          icon: const Icon(Icons.add_circle_outline),
          tooltip: 'Increase tempo',
        ),
      ],
    );
  }
}
