import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/beat_pattern.dart';
import '../viewmodel/metronome_view_model.dart';
import 'widgets/beat_indicator.dart';
import 'widgets/tempo_stepper.dart';

/// The metronome tool: shows the current tempo and beat, and lets the user
/// change the tempo and the beat pattern.
///
/// The beat plays as soon as the screen opens and stops when it closes;
/// that lifecycle is owned by [MetronomeViewModel], not by this widget.
///
/// Purely presentational: every piece of state comes from
/// [metronomeViewModelProvider] and every user action is forwarded to the
/// [MetronomeViewModel] — see docs/ARCHITECTURE.md.
class MetronomeScreen extends ConsumerWidget {
  /// Creates the metronome screen.
  const MetronomeScreen({super.key});

  static const List<int> _selectableBeatsPerBar = [2, 3, 4, 6];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(metronomeViewModelProvider);
    final viewModel = ref.read(metronomeViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Metronome')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            // Stretched so the Card/Wrap always span the same
            // width — otherwise a shrink-wrapped Card resizes (and the
            // whole layout visibly shifts) whenever its widest child
            // changes, e.g. the beat dot pulsing or the BPM digit count
            // changing from 2 to 3 digits.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 24,
                  ),
                  child: Column(
                    children: [
                      BeatIndicator(
                        beatsPerBar: state.beatPattern.beatsPerBar,
                        currentBeat: state.currentBeat,
                      ),
                      const SizedBox(height: 36),
                      TempoStepper(
                        tempo: state.tempo,
                        onDecrement: viewModel.decrementTempo,
                        onIncrement: viewModel.incrementTempo,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  for (final beatsPerBar in _selectableBeatsPerBar)
                    ChoiceChip(
                      label: Text('$beatsPerBar/4'),
                      selected:
                          state.beatPattern ==
                          BeatPattern(beatsPerBar: beatsPerBar),
                      onSelected: (_) => viewModel.setBeatsPerBar(beatsPerBar),
                    ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
