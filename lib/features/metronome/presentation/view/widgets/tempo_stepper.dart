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
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepButton(
          icon: Icons.remove_rounded,
          tooltip: 'Decrease tempo',
          onPressed: onDecrement,
        ),
        SizedBox(
          width: 160,
          child: Text(
            '${tempo.bpm} BPM',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(color: colorScheme.primary),
          ),
        ),
        _StepButton(
          icon: Icons.add_rounded,
          tooltip: 'Increase tempo',
          onPressed: onIncrement,
        ),
      ],
    );
  }
}

/// A round, tonal +/- button used on either side of the tempo display.
class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton.filledTonal(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        minimumSize: const Size(48, 48),
      ),
    );
  }
}
