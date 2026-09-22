import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/drift_corrected_metronome_ticker.dart';
import '../../data/services/system_click_sound_player.dart';
import '../../domain/entities/beat_pattern.dart';
import '../../domain/entities/tempo.dart';
import '../../domain/services/click_sound_player.dart';
import '../../domain/services/metronome_ticker.dart';
import 'metronome_view_state.dart';

/// Drives the metronome screen: starts/stops the beat, changes tempo and
/// beat pattern, and keeps [MetronomeViewState] in sync with each tick.
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
    ref.onDispose(() => _tickSubscription?.cancel());
    return MetronomeViewState.initial();
  }

  MetronomeTicker get _ticker => ref.read(metronomeTickerProvider);

  ClickSoundPlayer get _player => ref.read(clickSoundPlayerProvider);

  /// Starts the metronome at the current tempo and beat pattern. Does
  /// nothing if it's already playing.
  void start() {
    if (state.isPlaying) {
      return;
    }

    _tickCount = 0;
    _listenToTicks(state.tempo);
    state = state.copyWith(isPlaying: true, clearCurrentBeat: true);
  }

  /// Stops the metronome.
  void stop() {
    _tickSubscription?.cancel();
    _tickSubscription = null;
    _ticker.stop();
    state = state.copyWith(isPlaying: false, clearCurrentBeat: true);
  }

  /// Sets an absolute [tempo]. If the metronome is currently playing, it
  /// restarts ticking at the new tempo without losing the current bar
  /// position.
  void setTempo(Tempo tempo) {
    state = state.copyWith(tempo: tempo);
    if (state.isPlaying) {
      _listenToTicks(tempo);
    }
  }

  /// Increases the tempo by one BPM, clamped to [Tempo.maxBpm].
  void incrementTempo() => setTempo(state.tempo.shiftedBy(1));

  /// Decreases the tempo by one BPM, clamped to [Tempo.minBpm].
  void decrementTempo() => setTempo(state.tempo.shiftedBy(-1));

  /// Changes how many beats make up a bar. Restarts the bar count from its
  /// first (accented) beat.
  void setBeatsPerBar(int beatsPerBar) {
    _tickCount = 0;
    state = state.copyWith(
      beatPattern: BeatPattern(beatsPerBar: beatsPerBar),
      clearCurrentBeat: true,
    );
  }

  void _listenToTicks(Tempo tempo) {
    _tickSubscription?.cancel();
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
final metronomeViewModelProvider =
    NotifierProvider<MetronomeViewModel, MetronomeViewState>(
      MetronomeViewModel.new,
    );
