import 'package:flutter/material.dart';

/// Entry screen of the application.
///
/// Acts as the registry of available tools: this is the single place that
/// needs to change when a new tool (beyond tuner and metronome) is added to
/// the app, per the extensibility mechanism described in
/// docs/ARCHITECTURE.md. It currently only renders a placeholder, the tool
/// list will be wired in once the Tuner and Metronome features exist.
class HomeScreen extends StatelessWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Music Tools')),
      body: const Center(
        child: Text('Tools will appear here.'),
      ),
    );
  }
}
