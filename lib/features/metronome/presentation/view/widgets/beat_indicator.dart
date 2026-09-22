import 'package:flutter/material.dart';

import '../../../domain/entities/beat.dart';

/// Renders one dot per beat of the current bar, highlighting whichever
/// beat last played. The first (accented) beat is drawn larger.
class BeatIndicator extends StatelessWidget {
  /// Creates a [BeatIndicator] for a bar of [beatsPerBar] beats,
  /// highlighting [currentBeat] (or none, if `null`).
  const BeatIndicator({
    required this.beatsPerBar,
    required this.currentBeat,
    super.key,
  });

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
            child: CircleAvatar(
              radius: position == 0 ? 10 : 7,
              backgroundColor: currentBeat?.position == position
                  ? colorScheme.primary
                  : colorScheme.primary.withValues(alpha: 0.25),
            ),
          ),
      ],
    );
  }
}
