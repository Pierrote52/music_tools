import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_tools/features/tuner/data/services/record_pitch_detector.dart';
import 'package:music_tools/features/tuner/domain/services/pitch_detector.dart';
import 'package:music_tools/features/tuner/presentation/view/tuner_screen.dart';

import '../../fakes/fake_pitch_detector.dart';

void main() {
  group('TunerScreen', () {
    late FakePitchDetector detector;

    setUp(() {
      detector = FakePitchDetector();
    });

    Future<void> pumpScreen(WidgetTester tester) {
      return tester.pumpWidget(
        ProviderScope(
          overrides: [pitchDetectorProvider.overrideWithValue(detector)],
          child: const MaterialApp(home: TunerScreen()),
        ),
      );
    }

    testWidgets('starts listening on open, without any Start/Stop button', (
      tester,
    ) async {
      await pumpScreen(tester);

      expect(find.text('—'), findsOneWidget);
      expect(detector.startCallCount, 1);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('stops listening when the screen is closed', (tester) async {
      await pumpScreen(tester);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [pitchDetectorProvider.overrideWithValue(detector)],
          child: const MaterialApp(home: SizedBox()),
        ),
      );
      await tester.pump();

      expect(detector.stopCallCount, 1);
    });

    testWidgets('a detected frequency updates the displayed note', (
      tester,
    ) async {
      await pumpScreen(tester);

      detector.emitFrequency(440);
      await tester.pump();

      expect(find.text('A4'), findsOneWidget);
      expect(find.text('440.0 Hz'), findsOneWidget);
    });

    testWidgets(
      'a denied permission shows an error message and a retry button',
      (tester) async {
        await pumpScreen(tester);

        detector.emitError(const MicrophonePermissionDeniedException());
        await tester.pump();

        expect(
          find.text('Microphone permission is required to use the tuner.'),
          findsOneWidget,
        );
        expect(find.text('Try again'), findsOneWidget);
      },
    );

    testWidgets('tapping Try again listens again and hides the error', (
      tester,
    ) async {
      await pumpScreen(tester);
      detector.emitError(const MicrophonePermissionDeniedException());
      await tester.pump();

      await tester.tap(find.text('Try again'));
      await tester.pump();

      expect(detector.startCallCount, 2);
      expect(find.text('Try again'), findsNothing);
    });
  });
}
