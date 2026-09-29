import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/record_pitch_detector.dart';
import '../../domain/entities/pitch_reading.dart';
import '../../domain/services/pitch_detector.dart';
import 'tuner_view_state.dart';

/// Drives the tuner screen: listens to the microphone for as long as the
/// screen is shown and keeps [TunerViewState] in sync with each detected
/// pitch.
///
/// Its lifecycle *is* the listening session: [tunerViewModelProvider] is
/// auto-disposed, so the microphone starts when the screen first watches
/// it and is released as soon as the screen leaves the widget tree — no
/// start/stop command for the View to get wrong.
///
/// Depends on [PitchDetector] only through its domain interface (read via
/// [pitchDetectorProvider]), so tests can override that provider with a
/// fake instead of requesting real microphone access — see
/// `test/features/tuner/presentation/`.
class TunerViewModel extends Notifier<TunerViewState> {
  StreamSubscription<double?>? _subscription;

  @override
  TunerViewState build() {
    // Captured here rather than read in the callback: `ref` can no longer
    // be used once the provider is being disposed.
    final detector = _detector;
    ref.onDispose(() {
      unawaited(_subscription?.cancel());
      unawaited(detector.stop());
    });

    _startDetection();
    return TunerViewState.initial();
  }

  PitchDetector get _detector => ref.read(pitchDetectorProvider);

  /// Listens to the microphone again after an error (e.g. once the user
  /// has granted the microphone permission). Does nothing if already
  /// listening.
  void retry() {
    if (state.isListening) {
      return;
    }

    state = TunerViewState.initial();
    _startDetection();
  }

  void _startDetection() {
    unawaited(_subscription?.cancel());
    _subscription = _detector.start().listen(_onFrequency, onError: _onError);
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
///
/// Auto-disposed so that leaving the tuner screen releases the microphone
/// (see [TunerViewModel]).
final tunerViewModelProvider =
    NotifierProvider.autoDispose<TunerViewModel, TunerViewState>(
      TunerViewModel.new,
    );
