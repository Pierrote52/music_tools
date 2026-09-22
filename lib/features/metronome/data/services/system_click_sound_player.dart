import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/click_sound_player.dart';

/// A [ClickSoundPlayer] backed by the platform's built-in click sound.
///
/// Flutter has no bundled "metronome click" asset and this project ships
/// no audio files, so this implementation reuses [SystemSoundType.click]
/// for every beat, adding a haptic pulse to distinguish the accented
/// (first) beat of a bar. Because the ViewModel only depends on the
/// [ClickSoundPlayer] interface, swapping this for a custom-sound player
/// (e.g. backed by `audioplayers` and real click/accent audio assets)
/// later is a one-file change — see docs/ARCHITECTURE.md.
///
/// System sound and haptics support varies by platform (e.g. desktop
/// support is inconsistent); failures are swallowed rather than crashing
/// the metronome, since missing audio/haptic feedback should never stop
/// the beat from advancing.
class SystemClickSoundPlayer implements ClickSoundPlayer {
  @override
  Future<void> playRegular() => _playSystemClick();

  @override
  Future<void> playAccented() async {
    await _playSystemClick();
    await _tryOrIgnore(() => HapticFeedback.mediumImpact());
  }

  Future<void> _playSystemClick() =>
      _tryOrIgnore(() => SystemSound.play(SystemSoundType.click));

  Future<void> _tryOrIgnore(Future<void> Function() action) async {
    try {
      await action();
    } on PlatformException {
      // Best-effort feedback: an unsupported platform must not interrupt
      // the beat.
    }
  }
}

/// Provides the [ClickSoundPlayer] implementation used by the app.
final clickSoundPlayerProvider = Provider<ClickSoundPlayer>((ref) {
  return SystemClickSoundPlayer();
});
