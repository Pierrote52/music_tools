import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_tools/features/metronome/data/services/audio_click_sound_player.dart';
import 'package:music_tools/features/metronome/data/services/drift_corrected_metronome_ticker.dart';
import 'package:music_tools/features/metronome/presentation/view/metronome_screen.dart';

import '../../fakes/fake_click_sound_player.dart';
import '../../fakes/fake_metronome_ticker.dart';

void main() {
  group('MetronomeScreen', () {
    late FakeMetronomeTicker ticker;
    late FakeClickSoundPlayer player;

    setUp(() {
      ticker = FakeMetronomeTicker();
      player = FakeClickSoundPlayer();
    });

    Future<void> pumpScreen(WidgetTester tester) {
      return tester.pumpWidget(
        ProviderScope(
          overrides: [
            metronomeTickerProvider.overrideWithValue(ticker),
            clickSoundPlayerProvider.overrideWithValue(player),
          ],
          child: const MaterialApp(home: MetronomeScreen()),
        ),
      );
    }

    testWidgets('starts ticking on open, without any Start/Stop button', (
      tester,
    ) async {
      await pumpScreen(tester);

      expect(find.text('120 BPM'), findsOneWidget);
      expect(ticker.startedIntervals, hasLength(1));
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('stops ticking when the screen is closed', (tester) async {
      await pumpScreen(tester);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            metronomeTickerProvider.overrideWithValue(ticker),
            clickSoundPlayerProvider.overrideWithValue(player),
          ],
          child: const MaterialApp(home: SizedBox()),
        ),
      );
      await tester.pump();

      expect(ticker.stopCallCount, 1);
    });

    testWidgets('tapping the increment button raises the displayed tempo', (
      tester,
    ) async {
      await pumpScreen(tester);

      await tester.tap(find.byTooltip('Increase tempo'));
      await tester.pump();

      expect(find.text('121 BPM'), findsOneWidget);
    });

    testWidgets('selecting a beat pattern updates the chip selection', (
      tester,
    ) async {
      await pumpScreen(tester);

      await tester.tap(find.text('3/4'));
      await tester.pump();

      final chip = tester.widget<ChoiceChip>(
        find.ancestor(of: find.text('3/4'), matching: find.byType(ChoiceChip)),
      );
      expect(chip.selected, isTrue);
    });
  });
}
