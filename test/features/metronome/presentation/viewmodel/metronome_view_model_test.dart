import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_tools/features/metronome/data/services/audio_click_sound_player.dart';
import 'package:music_tools/features/metronome/data/services/drift_corrected_metronome_ticker.dart';
import 'package:music_tools/features/metronome/domain/entities/tempo.dart';
import 'package:music_tools/features/metronome/presentation/viewmodel/metronome_view_model.dart';

import '../../fakes/fake_click_sound_player.dart';
import '../../fakes/fake_metronome_ticker.dart';

void main() {
  group('MetronomeViewModel', () {
    late FakeMetronomeTicker ticker;
    late FakeClickSoundPlayer player;
    late ProviderContainer container;

    setUp(() {
      ticker = FakeMetronomeTicker();
      player = FakeClickSoundPlayer();
      container = ProviderContainer(
        overrides: [
          metronomeTickerProvider.overrideWithValue(ticker),
          clickSoundPlayerProvider.overrideWithValue(player),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await ticker.dispose();
    });

    /// Simulates the metronome screen being shown: keeps the auto-disposed
    /// provider alive until the returned subscription is closed.
    ProviderSubscription<Object?> openScreen() =>
        container.listen(metronomeViewModelProvider, (_, _) {});

    /// Simulates the user leaving the metronome screen.
    Future<void> closeScreen(ProviderSubscription<Object?> screen) async {
      screen.close();
      await container.pump();
    }

    MetronomeViewModel readViewModel() =>
        container.read(metronomeViewModelProvider.notifier);

    test('starts ticking at the default tempo as soon as the screen opens', () {
      openScreen();

      final state = container.read(metronomeViewModelProvider);
      expect(state.tempo, const Tempo(120));
      expect(state.currentBeat, isNull);
      expect(ticker.startedIntervals, [const Tempo(120).beatInterval]);
    });

    test('stops the ticker when the screen closes', () async {
      final screen = openScreen();

      await closeScreen(screen);

      expect(ticker.stopCallCount, 1);
    });

    test('each tick advances the current beat and plays its sound', () async {
      openScreen();

      ticker.emitTick();
      await Future<void>.delayed(Duration.zero);
      var state = container.read(metronomeViewModelProvider);
      expect(state.currentBeat?.position, 0);
      expect(state.currentBeat?.isAccented, isTrue);
      expect(player.accentedCount, 1);

      ticker.emitTick();
      await Future<void>.delayed(Duration.zero);
      state = container.read(metronomeViewModelProvider);
      expect(state.currentBeat?.position, 1);
      expect(state.currentBeat?.isAccented, isFalse);
      expect(player.regularCount, 1);
    });

    test('setTempo() restarts the ticker at the new interval', () {
      openScreen();

      readViewModel().setTempo(const Tempo(90));

      expect(ticker.startedIntervals, [
        const Tempo(120).beatInterval,
        const Tempo(90).beatInterval,
      ]);
      expect(container.read(metronomeViewModelProvider).tempo, const Tempo(90));
    });

    test('incrementTempo()/decrementTempo() shift the tempo by one BPM', () {
      openScreen();
      final viewModel = readViewModel();

      viewModel.incrementTempo();
      expect(
        container.read(metronomeViewModelProvider).tempo,
        const Tempo(121),
      );

      viewModel.decrementTempo();
      viewModel.decrementTempo();
      expect(
        container.read(metronomeViewModelProvider).tempo,
        const Tempo(119),
      );
    });

    test(
      'setBeatsPerBar() updates the pattern and resets the current beat',
      () async {
        openScreen();
        ticker.emitTick();
        await Future<void>.delayed(Duration.zero);

        readViewModel().setBeatsPerBar(3);

        final state = container.read(metronomeViewModelProvider);
        expect(state.beatPattern.beatsPerBar, 3);
        expect(state.currentBeat, isNull);
      },
    );

    test(
      'reopening the screen restores the last tempo and beat pattern',
      () async {
        final firstVisit = openScreen();
        readViewModel()
          ..setTempo(const Tempo(90))
          ..setBeatsPerBar(3);
        await closeScreen(firstVisit);

        openScreen();

        final state = container.read(metronomeViewModelProvider);
        expect(state.tempo, const Tempo(90));
        expect(state.beatPattern.beatsPerBar, 3);
        expect(state.currentBeat, isNull);
        expect(ticker.startedIntervals.last, const Tempo(90).beatInterval);
      },
    );
  });
}
