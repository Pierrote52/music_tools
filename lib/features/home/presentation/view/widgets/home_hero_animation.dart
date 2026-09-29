import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

/// Whether [HomeHeroAnimation] loads and plays its Rive file.
///
/// Overridden to `false` in widget tests, where the Rive native library
/// is not available.
final homeHeroAnimationEnabledProvider = Provider<bool>((ref) => true);

/// Animated jazz manouche character shown at the top of the home screen.
///
/// Purely decorative: while the .riv file loads, if it fails to load, or
/// when disabled through [homeHeroAnimationEnabledProvider], it simply
/// reserves its space and shows nothing.
class HomeHeroAnimation extends ConsumerWidget {
  /// Creates the home hero animation.
  const HomeHeroAnimation({super.key, this.height = 550});

  /// Height reserved for the animation.
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: height,
      child: ref.watch(homeHeroAnimationEnabledProvider)
          ? const _RiveCharacter()
          : null,
    );
  }
}

class _RiveCharacter extends StatefulWidget {
  const _RiveCharacter();

  @override
  State<_RiveCharacter> createState() => _RiveCharacterState();
}

class _RiveCharacterState extends State<_RiveCharacter> {
  static const String _asset =
      'assets/rive/jazz_manouche_character.riv';

  late final FileLoader _fileLoader = FileLoader.fromAsset(
    _asset,
    riveFactory: Factory.rive,
  );

  @override
  void dispose() {
    _fileLoader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RiveWidgetBuilder(
      fileLoader: _fileLoader,
      onFailed: (error, stackTrace) =>
          debugPrint('Home animation failed to load: $error'),
      builder: (context, state) => switch (state) {
        RiveLoaded() => RiveWidget(controller: state.controller),
        RiveLoading() || RiveFailed() => const SizedBox.shrink(),
      },
    );
  }
}
