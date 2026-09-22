import 'package:flutter/material.dart';

import '../../../domain/entities/beat.dart';

/// Renders one dot per beat of the current bar, animating whichever beat
/// last played into a larger, colored circle. The accented (first) beat
/// uses a distinct color so the downbeat stays visually obvious.
class BeatIndicator extends StatelessWidget {
  /// Creates a [BeatIndicator] for a bar of [beatsPerBar] beats,
  /// highlighting [currentBeat] (or none, if `null`).
  const BeatIndicator({
    required this.beatsPerBar,
    required this.currentBeat,
    super.key,
  });

  static const double _restingDiameter = 14;
  static const double _activeDiameter = 24;
  static const Duration _animationDuration = Duration(milliseconds: 110);

  /// How many beats make up the bar, i.e. how many dots to draw.
  final int beatsPerBar;

  /// The most recently played beat, or `null` before the first tick.
  final Beat? currentBeat;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var position = 0; position < beatsPerBar; position++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _BeatDot(
              isActive: currentBeat?.position == position,
              isAccent: position == 0,
              colorScheme: colorScheme,
            ),
          ),
      ],
    );
  }
}

class _BeatDot extends StatelessWidget {
  const _BeatDot({
    required this.isActive,
    required this.isAccent,
    required this.colorScheme,
  });

  final bool isActive;
  final bool isAccent;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final activeColor = isAccent ? colorScheme.tertiary : colorScheme.primary;

    return AnimatedContainer(
      duration: BeatIndicator._animationDuration,
      curve: Curves.easeOut,
      width: isActive
          ? BeatIndicator._activeDiameter
          : BeatIndicator._restingDiameter,
      height: isActive
          ? BeatIndicator._activeDiameter
          : BeatIndicator._restingDiameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? activeColor : colorScheme.onSurface.withValues(alpha: 0.12),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}
