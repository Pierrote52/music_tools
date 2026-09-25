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

  /// Transparent-background crop of the app mark (circle + metronome,
  /// no wordmark), reused both as the small AppBar logo and as the
  /// source for the tinted background watermark.
  static const String _logoMarkAsset = 'assets/icon/icon_transparent.png';

  static final List<_ToolEntry> _tools = [
    _ToolEntry(
      label: 'Metronome',
      description: 'Keep the beat, at any tempo',
      icon: Icons.av_timer_rounded,
      accentColor: const Color(0xFFFF6B6B),
      builder: (context) => const MetronomeScreen(),
    ),
    _ToolEntry(
      label: 'Tuner',
      description: 'Get every string in tune',
      icon: Icons.graphic_eq_rounded,
      accentColor: const Color(0xFF00B894),
      builder: (context) => const TunerScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final watermarkSize = MediaQuery.sizeOf(context).width * 0.9;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(_logoMarkAsset, width: 28, height: 28),
            const SizedBox(width: 10),
            const Text('Music Tools'),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Faint, tinted brand mark bleeding off the bottom-right corner.
          // IgnorePointer keeps it from intercepting taps meant for the
          // list above it.
          Positioned(
            right: -watermarkSize * 0.25,
            bottom: -watermarkSize * 0.25,
            child: IgnorePointer(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  colorScheme.primary.withValues(alpha: 0.06),
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  _logoMarkAsset,
                  width: watermarkSize,
                  height: watermarkSize,
                ),
              ),
            ),
          ),
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            itemCount: _tools.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _ToolCard(tool: _tools[index]),
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
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.builder,
  });

  final String label;
  final String description;
  final IconData icon;
  final Color accentColor;
  final WidgetBuilder builder;
}

/// A colorful, tappable card for one [_ToolEntry].
class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool});

  final _ToolEntry tool;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: tool.builder)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: tool.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(tool.icon, color: tool.accentColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tool.label, style: textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      tool.description,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
