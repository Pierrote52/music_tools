import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_tools/features/metronome/data/services/drift_corrected_metronome_ticker.dart';
import 'package:music_tools/features/metronome/data/services/system_click_sound_player.dart';
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

    MetronomeViewModel readViewModel() =>
        container.read(metronomeViewModelProvider.notifier);

    MetronomeViewModel notifierWithListener() {
      // Keep the provider alive across the test by watching its state.
      container.listen(metronomeViewModelProvider, (_, _) {});
      return readViewModel();
    }

    test('starts stopped, at the default tempo, with no beat played yet', () {
      final state = container.read(metronomeViewModelProvider);

      expect(state.isPlaying, isFalse);
      expect(state.tempo, const Tempo(120));
      expect(state.currentBeat, isNull);
    });

    test('start() marks the metronome as playing and starts the ticker', () {
      final viewModel = notifierWithListener();

      viewModel.start();

      final state = container.read(metronomeViewModelProvider);
      expect(state.isPlaying, isTrue);
      expect(ticker.startedIntervals, [state.tempo.beatInterval]);
    });

    test('start() while already playing does not restart the ticker', () {
      final viewModel = notifierWithListener();

      viewModel.start();
      viewModel.start();

      expect(ticker.startedIntervals, hasLength(1));
    });

    test('each tick advances the current beat and plays its sound', () async {
      final viewModel = notifierWithListener();
      viewModel.start();

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

    test('stop() marks the metronome as not playing and stops the ticker', () {
      final viewModel = notifierWithListener();
      viewModel.start();

      viewModel.stop();

      final state = container.read(metronomeViewModelProvider);
      expect(state.isPlaying, isFalse);
      expect(state.currentBeat, isNull);
      expect(ticker.stopCallCount, 1);
    });

    test('setTempo() while playing restarts the ticker at the new interval', () {
      final viewModel = notifierWithListener();
      viewModel.start();

      viewModel.setTempo(const Tempo(90));

      expect(
        ticker.startedIntervals,
        [const Tempo(120).beatInterval, const Tempo(90).beatInterval],
      );
      expect(container.read(metronomeViewModelProvider).tempo, const Tempo(90));
    });

    test('setTempo() while stopped only updates the state, no ticker restart', () {
      final viewModel = notifierWithListener();

      viewModel.setTempo(const Tempo(90));

      expect(ticker.startedIntervals, isEmpty);
      expect(container.read(metronomeViewModelProvider).tempo, const Tempo(90));
    });

    test('incrementTempo()/decrementTempo() shift the tempo by one BPM', () {
      final viewModel = notifierWithListener();

      viewModel.incrementTempo();
      expect(container.read(metronomeViewModelProvider).tempo, const Tempo(121));

      viewModel.decrementTempo();
      viewModel.decrementTempo();
      expect(container.read(metronomeViewModelProvider).tempo, const Tempo(119));
    });

    test('setBeatsPerBar() updates the pattern and resets the current beat', () {
      final viewModel = notifierWithListener();
      viewModel.start();
      ticker.emitTick();

      viewModel.setBeatsPerBar(3);

      final state = container.read(metronomeViewModelProvider);
      expect(state.beatPattern.beatsPerBar, 3);
      expect(state.currentBeat, isNull);
    });
  });
}
