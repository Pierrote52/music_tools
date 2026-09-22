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

    TunerViewModel readViewModel() =>
        container.read(tunerViewModelProvider.notifier);

    TunerViewModel notifierWithListener() {
      // Keep the provider alive across the test by watching its state.
      container.listen(tunerViewModelProvider, (_, _) {});
      return readViewModel();
    }

    test('starts not listening, with no reading and no error', () {
      final state = container.read(tunerViewModelProvider);

      expect(state.isListening, isFalse);
      expect(state.reading, isNull);
      expect(state.errorMessage, isNull);
    });

    test('startListening() marks the tuner as listening and starts the detector', () {
      final viewModel = notifierWithListener();

      viewModel.startListening();

      expect(container.read(tunerViewModelProvider).isListening, isTrue);
      expect(detector.startCallCount, 1);
    });

    test('startListening() while already listening does not restart the detector', () {
      final viewModel = notifierWithListener();

      viewModel.startListening();
      viewModel.startListening();

      expect(detector.startCallCount, 1);
    });

    test('a detected frequency becomes a PitchReading in the state', () async {
      final viewModel = notifierWithListener();
      viewModel.startListening();

      detector.emitFrequency(440);
      await Future<void>.delayed(Duration.zero);

      final reading = container.read(tunerViewModelProvider).reading;
      expect(reading, isNotNull);
      expect(reading!.nearestNote.toString(), 'A4');
    });

    test('a null frequency (silence) clears the current reading', () async {
      final viewModel = notifierWithListener();
      viewModel.startListening();
      detector.emitFrequency(440);
      await Future<void>.delayed(Duration.zero);

      detector.emitFrequency(null);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(tunerViewModelProvider).reading, isNull);
    });

    test('a MicrophonePermissionDeniedException stops listening with a message', () async {
      final viewModel = notifierWithListener();
      viewModel.startListening();

      detector.emitError(const MicrophonePermissionDeniedException());
      await Future<void>.delayed(Duration.zero);

      final state = container.read(tunerViewModelProvider);
      expect(state.isListening, isFalse);
      expect(state.errorMessage, isNotNull);
    });

    test('stopListening() marks the tuner as not listening and stops the detector', () async {
      final viewModel = notifierWithListener();
      viewModel.startListening();

      await viewModel.stopListening();

      final state = container.read(tunerViewModelProvider);
      expect(state.isListening, isFalse);
      expect(state.reading, isNull);
      expect(detector.stopCallCount, 1);
    });
  });
}
