import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/metronome_settings.dart';

/// Remembers the last [MetronomeSettings] for the rest of the app session,
/// so the metronome screen reopens at the tempo and beat pattern the user
/// left it at.
///
/// Exists because [metronomeViewModelProvider] is auto-disposed (playback
/// must stop when the screen closes), which would otherwise reset the
/// settings on every visit. In-memory only: persisting across app restarts
/// would mean a storage-backed service in `data/` behind a domain
/// interface instead.
class MetronomeSettingsStore extends Notifier<MetronomeSettings> {
  @override
  MetronomeSettings build() => const MetronomeSettings();

  /// Replaces the remembered settings.
  void save(MetronomeSettings settings) => state = settings;
}

/// Exposes the [MetronomeSettingsStore]. Deliberately *not* auto-disposed,
/// so its value outlives the metronome screen.
final metronomeSettingsStoreProvider =
    NotifierProvider<MetronomeSettingsStore, MetronomeSettings>(
      MetronomeSettingsStore.new,
    );
