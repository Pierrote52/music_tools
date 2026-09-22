import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodel/tuner_view_model.dart';
import 'widgets/cents_gauge.dart';
import 'widgets/note_display.dart';

/// The tuner tool: listens to the microphone and shows the detected note
/// and how far off pitch it is.
///
/// Purely presentational: every piece of state comes from
/// [tunerViewModelProvider] and every user action is forwarded to the
/// [TunerViewModel] — see docs/ARCHITECTURE.md.
class TunerScreen extends ConsumerWidget {
  /// Creates the tuner screen.
  const TunerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tunerViewModelProvider);
    final viewModel = ref.read(tunerViewModelProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Tuner')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NoteDisplay(reading: state.reading),
              const SizedBox(height: 24),
              CentsGauge(reading: state.reading),
              const SizedBox(height: 32),
              if (state.errorMessage case final message?) ...[
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.error),
                ),
                const SizedBox(height: 16),
              ],
              FilledButton.icon(
                onPressed: state.isListening
                    ? viewModel.stopListening
                    : viewModel.startListening,
                icon: Icon(state.isListening ? Icons.mic : Icons.mic_none),
                label: Text(state.isListening ? 'Stop' : 'Start'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
