import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/audio_click_sound_player.dart';
import '../../data/services/drift_corrected_metronome_ticker.dart';
import '../../domain/entities/beat_pattern.dart';
import '../../domain/entities/metronome_settings.dart';
import '../../domain/entities/tempo.dart';
import '../../domain/services/click_sound_player.dart';
import '../../domain/services/metronome_ticker.dart';
import 'metronome_settings_store.dart';
import 'metronome_view_state.dart';

/// Drives the metronome screen: plays the beat for as long as the screen is
/// shown, changes tempo and beat pattern, and keeps [MetronomeViewState] in
/// sync with each tick.
///
/// Its lifecycle *is* the playback session: [metronomeViewModelProvider] is
/// auto-disposed, so the beat starts when the screen first watches it and
/// stops as soon as the screen leaves the widget tree — no start/stop
/// command for the View to get wrong. Tempo and beat pattern survive that
/// disposal through [metronomeSettingsStoreProvider].
///
/// Depends on [MetronomeTicker] and [ClickSoundPlayer] only through their
/// domain interfaces (read via [metronomeTickerProvider] and
/// [clickSoundPlayerProvider]), so tests can override those providers with
/// fakes instead of driving a real timer or playing real audio — see
/// `test/features/metronome/presentation/`.
class MetronomeViewModel extends Notifier<MetronomeViewState> {
  StreamSubscription<void>? _tickSubscription;
  int _tickCount = 0;

  @override
  MetronomeViewState build() {
    // Captured here rather than read in the callback: `ref` can no longer
    // be used once the provider is being disposed.
    final ticker = _ticker;
    ref.onDispose(() {
      unawaited(_tickSubscription?.cancel());
      ticker.stop();
    });

    final settings = ref.read(metronomeSettingsStoreProvider);
    _listenToTicks(settings.tempo);
    return MetronomeViewState(settings: settings, currentBeat: null);
  }

  MetronomeTicker get _ticker => ref.read(metronomeTickerProvider);

  ClickSoundPlayer get _player => ref.read(clickSoundPlayerProvider);

  /// Sets an absolute [tempo]. Ticking restarts at the new tempo without
  /// losing the current bar position.
  void setTempo(Tempo tempo) {
    _updateSettings(state.settings.copyWith(tempo: tempo));
    _listenToTicks(tempo);
  }

  /// Increases the tempo by one BPM, clamped to [Tempo.maxBpm].
  void incrementTempo() => setTempo(state.tempo.shiftedBy(1));

  /// Decreases the tempo by one BPM, clamped to [Tempo.minBpm].
  void decrementTempo() => setTempo(state.tempo.shiftedBy(-1));

  /// Changes how many beats make up a bar. Restarts the bar count from its
  /// first (accented) beat.
  void setBeatsPerBar(int beatsPerBar) {
    _tickCount = 0;
    _updateSettings(
      state.settings.copyWith(
        beatPattern: BeatPattern(beatsPerBar: beatsPerBar),
      ),
      clearCurrentBeat: true,
    );
  }

  void _updateSettings(
    MetronomeSettings settings, {
    bool clearCurrentBeat = false,
  }) {
    state = state.copyWith(
      settings: settings,
      clearCurrentBeat: clearCurrentBeat,
    );
    ref.read(metronomeSettingsStoreProvider.notifier).save(settings);
  }

  void _listenToTicks(Tempo tempo) {
    unawaited(_tickSubscription?.cancel());
    _tickSubscription = _ticker
        .start(interval: tempo.beatInterval)
        .listen((_) => _onTick());
  }

  void _onTick() {
    final beat = state.beatPattern.beatAt(_tickCount);
    _tickCount++;

    unawaited(beat.isAccented ? _player.playAccented() : _player.playRegular());
    state = state.copyWith(currentBeat: beat);
  }
}

/// Exposes the [MetronomeViewModel] and its [MetronomeViewState] to the
/// View, and provides the dependency-injection point tests override to
/// substitute fake ticker/player implementations.
///
/// Auto-disposed so that leaving the metronome screen stops the beat (see
/// [MetronomeViewModel]).
final metronomeViewModelProvider =
    NotifierProvider.autoDispose<MetronomeViewModel, MetronomeViewState>(
      MetronomeViewModel.new,
    );
