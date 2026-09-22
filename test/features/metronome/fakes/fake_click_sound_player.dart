import 'package:music_tools/features/metronome/domain/services/click_sound_player.dart';

/// A [ClickSoundPlayer] test double that records calls instead of playing
/// real audio.
class FakeClickSoundPlayer implements ClickSoundPlayer {
  /// How many times [playRegular] was called.
  int regularCount = 0;

  /// How many times [playAccented] was called.
  int accentedCount = 0;

  @override
  Future<void> playRegular() async => regularCount++;

  @override
  Future<void> playAccented() async => accentedCount++;
}
