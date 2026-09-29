import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodel/tuner_view_model.dart';
import 'widgets/cents_gauge.dart';
import 'widgets/note_display.dart';

/// The tuner tool: listens to the microphone and shows the detected note
/// and how far off pitch it is.
///
/// Listening starts as soon as the screen opens and stops when it closes;
/// that lifecycle is owned by [TunerViewModel], not by this widget.
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

    return Scaffold(
      appBar: AppBar(title: const Text('Tuner')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              NoteDisplay(reading: state.reading),
              const SizedBox(height: 40),
              CentsGauge(reading: state.reading),
              const Spacer(),
              if (state.errorMessage case final message?)
                _ErrorPanel(message: message, onRetry: viewModel.retry),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Explains why the tuner stopped listening (e.g. microphone permission
/// denied) and offers to try again.
class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onErrorContainer),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
          ),
        ],
      ),
    );
  }
}
