import 'package:meta/meta.dart';

import '../../domain/entities/pitch_reading.dart';

/// Immutable snapshot of everything the tuner screen needs to render.
@immutable
class TunerViewState {
  /// Creates a [TunerViewState].
  const TunerViewState({
    required this.isListening,
    required this.reading,
    required this.errorMessage,
  });

  /// The state the tuner screen starts in: listening, no reading yet, no
  /// error.
  factory TunerViewState.initial() => const TunerViewState(
    isListening: true,
    reading: null,
    errorMessage: null,
  );

  /// Whether the microphone is currently being listened to. Only `false`
  /// after an error, until [TunerViewModel.retry] — see
  /// `tuner_view_model.dart`.
  final bool isListening;

  /// The most recent pitch detected, or `null` if nothing has been
  /// detected yet (including brief silence between notes).
  final PitchReading? reading;

  /// A user-facing message describing why listening stopped/failed (e.g.
  /// microphone permission denied), or `null` if there's no error.
  final String? errorMessage;

  /// Returns a copy of this state with the given fields replaced.
  ///
  /// [reading] and [errorMessage] follow the usual "omit to keep, pass to
  /// replace" convention; pass [clearReading]/[clearErrorMessage] to
  /// explicitly reset them to `null`, since a plain `null` argument can't
  /// be distinguished from "not provided".
  TunerViewState copyWith({
    bool? isListening,
    PitchReading? reading,
    bool clearReading = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return TunerViewState(
      isListening: isListening ?? this.isListening,
      reading: clearReading ? null : (reading ?? this.reading),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}
