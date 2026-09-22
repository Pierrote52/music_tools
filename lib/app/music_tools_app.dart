import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/home/presentation/view/home_screen.dart';

/// Root widget of the Music Tools application.
///
/// This is the only place [MaterialApp]-level concerns (theme, title,
/// initial route) are configured. It stays intentionally thin: routing to
/// individual tools is delegated to [HomeScreen], which acts as the
/// registry of available tools (see docs/ARCHITECTURE.md).
class MusicToolsApp extends StatelessWidget {
  /// Creates the root widget of the application.
  const MusicToolsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Tools',
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
