/// Plays the audible/haptic feedback for a metronome beat.
///
/// Kept as a domain-level interface (rather than calling a sound package
/// directly from the ViewModel) so the concrete playback mechanism — a
/// system sound today, custom audio assets later — can change without
/// touching `presentation/`. See `data/services/` for the implementation.
abstract class ClickSoundPlayer {
  /// Plays the sound for a regular (non-accented) beat.
  Future<void> playRegular();

  /// Plays the sound for an accented beat (the first beat of a bar).
  Future<void> playAccented();
}
