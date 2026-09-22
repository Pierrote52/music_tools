import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/music_tools_app.dart';

/// Application entry point.
///
/// Wraps the app in a [ProviderScope] so that every Riverpod provider
/// declared across the `features/` and `core/` layers becomes available to
/// the widget tree below it. No business logic lives here on purpose: this
/// file only wires the Flutter binding to the app's root widget.
void main() {
  runApp(const ProviderScope(child: MusicToolsApp()));
}
