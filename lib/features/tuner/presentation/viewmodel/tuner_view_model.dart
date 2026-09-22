import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/record_pitch_detector.dart';
import '../../domain/entities/pitch_reading.dart';
import '../../domain/services/pitch_detector.dart';
import 'tuner_view_state.dart';

/// Drives the tuner screen: starts/stops listening to the microphone and
/// keeps [TunerViewState] in sync with each detected pitch.
///
/// Depends on [PitchDetector] only through its domain interface (read via
/// [pitchDetectorProvider]), so tests can override that provider with a
/// fake instead of requesting real microphone access — see
/// `test/features/tuner/presentation/`.
class TunerViewModel extends Notifier<TunerViewState> {
  StreamSubscription<double?>? _subscription;

  @override
  TunerViewState build() {
    ref.onDispose(() => _subscription?.cancel());
    return TunerViewState.initial();
  }

  PitchDetector get _detector => ref.read(pitchDetectorProvider);

  /// Starts listening to the microphone. Does nothing if already
  /// listening.
  void startListening() {
    if (state.isListening) {
      return;
    }

    state = state.copyWith(
      isListening: true,
      clearReading: true,
      clearErrorMessage: true,
    );
    _subscription = _detector.start().listen(
      _onFrequency,
      onError: _onError,
    );
  }

  /// Stops listening to the microphone.
  Future<void> stopListening() async {
    await _subscription?.cancel();
    _subscription = null;
    await _detector.stop();
    state = state.copyWith(isListening: false, clearReading: true);
  }

  void _onFrequency(double? frequencyHz) {
    state = frequencyHz == null
        ? state.copyWith(clearReading: true)
        : state.copyWith(reading: PitchReading.fromFrequency(frequencyHz));
  }

  void _onError(Object error) {
    state = state.copyWith(
      isListening: false,
      clearReading: true,
      errorMessage: error is MicrophonePermissionDeniedException
          ? 'Microphone permission is required to use the tuner.'
          : 'Something went wrong while listening to the microphone.',
    );
  }
}

/// Exposes the [TunerViewModel] and its [TunerViewState] to the View, and
/// provides the dependency-injection point tests override to substitute a
/// fake pitch detector.
final tunerViewModelProvider =
    NotifierProvider<TunerViewModel, TunerViewState>(TunerViewModel.new);
