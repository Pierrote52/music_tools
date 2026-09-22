import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/click_sound_player.dart';
import 'click_sound_synthesizer.dart';

/// A [ClickSoundPlayer] that plays short click sounds synthesized at
/// runtime by [ClickSoundSynthesizer], through the device's media volume
/// stream.
///
/// An earlier version of this class used [SystemSound.play], which turned
/// out to be silent on many devices: it's tied to the system's "touch
/// sounds" setting and its own (often muted) volume stream, neither of
/// which an app controls. Playing real audio bytes through `audioplayers`
/// sidesteps both problems.
///
/// One [AudioPlayer] is kept per sound (regular/accented) and replayed on
/// every matching beat, rather than creating a new player per tick.
class AudioClickSoundPlayer implements ClickSoundPlayer {
  static const ClickSoundSynthesizer _synthesizer = ClickSoundSynthesizer();

  final AudioPlayer _regularPlayer = AudioPlayer();
  final AudioPlayer _accentedPlayer = AudioPlayer();

  @override
  Future<void> playRegular() =>
      _play(_regularPlayer, _synthesizer.regularClick);

  @override
  Future<void> playAccented() async {
    await _play(_accentedPlayer, _synthesizer.accentedClick);
    await _tryOrIgnore(() => HapticFeedback.mediumImpact());
  }

  Future<void> _play(AudioPlayer player, Uint8List wavBytes) async {
    // Restarting from a stopped player, rather than letting a rapid tempo
    // queue plays up, keeps every click landing exactly on its beat.
    await player.stop();
    await player.play(BytesSource(wavBytes, mimeType: 'audio/wav'));
  }

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
  return AudioClickSoundPlayer();
});
