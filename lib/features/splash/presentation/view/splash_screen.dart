import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

import '../../../home/presentation/view/home_screen.dart';

/// Whether the app starts on [SplashScreen] before [HomeScreen].
///
/// Overridden to `false` in widget tests, where the Rive native library
/// is not available.
final splashScreenEnabledProvider = Provider<bool>((ref) => true);

/// First screen of the application: plays the animated logo, then fades
/// into [HomeScreen].
///
/// Moves on after [duration], or earlier if the user taps the screen. If
/// the .riv file fails to load, it moves on immediately.
class SplashScreen extends StatefulWidget {
  /// Creates the splash screen.
  const SplashScreen({
    super.key,
    this.duration = const Duration(milliseconds: 6000),
  });

  /// How long the logo animation is shown before opening the home screen.
  final Duration duration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String _asset = 'assets/rive/logo.riv';

  late final FileLoader _fileLoader = FileLoader.fromAsset(
    _asset,
    riveFactory: Factory.rive,
  );

  late final Timer _timer;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, _openHome);
  }

  @override
  void dispose() {
    _timer.cancel();
    _fileLoader.dispose();
    super.dispose();
  }

  void _openHome() {
    if (_leaving || !mounted) return;
    _leaving = true;
    _timer.cancel();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _openHome,
        child: Center(
          child: RiveWidgetBuilder(
            fileLoader: _fileLoader,
            onFailed: (error, stackTrace) {
              debugPrint('Splash animation failed to load: $error');
              WidgetsBinding.instance.addPostFrameCallback((_) => _openHome());
            },
            builder: (context, state) => switch (state) {
              RiveLoaded() => RiveWidget(controller: state.controller),
              RiveLoading() || RiveFailed() => const SizedBox.shrink(),
            },
          ),
        ),
      ),
    );
  }
}
