import 'package:flutter/material.dart';

import '../../../metronome/presentation/view/metronome_screen.dart';
import '../../../tuner/presentation/view/tuner_screen.dart';

/// Entry screen of the application.
///
/// Acts as the registry of available tools: this is the single place that
/// needs to change when a new tool is added to the app, per the
/// extensibility mechanism described in docs/ARCHITECTURE.md — add a
/// [_ToolEntry] to [_tools], nothing else in this feature changes.
class HomeScreen extends StatelessWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  static final List<_ToolEntry> _tools = [
    _ToolEntry(
      label: 'Metronome',
      icon: Icons.av_timer,
      builder: (context) => const MetronomeScreen(),
    ),
    _ToolEntry(
      label: 'Tuner',
      icon: Icons.graphic_eq,
      builder: (context) => const TunerScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Music Tools')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final tool in _tools)
            Card(
              child: ListTile(
                leading: Icon(tool.icon),
                title: Text(tool.label),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: tool.builder),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A single entry in the home screen's tool registry.
class _ToolEntry {
  const _ToolEntry({
    required this.label,
    required this.icon,
    required this.builder,
  });

  final String label;
  final IconData icon;
  final WidgetBuilder builder;
}
