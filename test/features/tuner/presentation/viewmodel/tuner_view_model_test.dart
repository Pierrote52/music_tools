import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_tools/features/tuner/data/services/record_pitch_detector.dart';
import 'package:music_tools/features/tuner/domain/services/pitch_detector.dart';
import 'package:music_tools/features/tuner/presentation/viewmodel/tuner_view_model.dart';

import '../../fakes/fake_pitch_detector.dart';

void main() {
  group('TunerViewModel', () {
    late FakePitchDetector detector;
    late ProviderContainer container;

    setUp(() {
      detector = FakePitchDetector();
      container = ProviderContainer(
        overrides: [pitchDetectorProvider.overrideWithValue(detector)],
      );
    });

    tearDown(() async {
      container.dispose();
      await detector.dispose();
    });

    /// Simulates the tuner screen being shown: keeps the auto-disposed
    /// provider alive until the returned subscription is closed.
    ProviderSubscription<Object?> openScreen() =>
        container.listen(tunerViewModelProvider, (_, _) {});

    TunerViewModel readViewModel() =>
        container.read(tunerViewModelProvider.notifier);

    test('starts listening as soon as the screen opens', () {
      openScreen();

      final state = container.read(tunerViewModelProvider);
      expect(state.isListening, isTrue);
      expect(state.reading, isNull);
      expect(state.errorMessage, isNull);
      expect(detector.startCallCount, 1);
    });

    test('stops the detector when the screen closes', () async {
      final screen = openScreen();

      screen.close();
      await container.pump();

      expect(detector.stopCallCount, 1);
    });

    test('a detected frequency becomes a PitchReading in the state', () async {
      openScreen();

      detector.emitFrequency(440);
      await Future<void>.delayed(Duration.zero);

      final reading = container.read(tunerViewModelProvider).reading;
      expect(reading, isNotNull);
      expect(reading!.nearestNote.toString(), 'A4');
    });

    test('a null frequency (silence) clears the current reading', () async {
      openScreen();
      detector.emitFrequency(440);
      await Future<void>.delayed(Duration.zero);

      detector.emitFrequency(null);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(tunerViewModelProvider).reading, isNull);
    });

    test(
      'a MicrophonePermissionDeniedException stops listening with a message',
      () async {
        openScreen();

        detector.emitError(const MicrophonePermissionDeniedException());
        await Future<void>.delayed(Duration.zero);

        final state = container.read(tunerViewModelProvider);
        expect(state.isListening, isFalse);
        expect(state.errorMessage, isNotNull);
      },
    );

    test('retry() after an error listens again and clears the error', () async {
      openScreen();
      detector.emitError(const MicrophonePermissionDeniedException());
      await Future<void>.delayed(Duration.zero);

      readViewModel().retry();

      final state = container.read(tunerViewModelProvider);
      expect(state.isListening, isTrue);
      expect(state.errorMessage, isNull);
      expect(detector.startCallCount, 2);
    });

    test(
      'retry() while already listening does not restart the detector',
      () async {
        openScreen();

        readViewModel().retry();

        expect(detector.startCallCount, 1);
      },
    );
  });
}
