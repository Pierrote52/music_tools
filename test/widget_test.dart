// Smoke test verifying the app boots and shows its home screen.
//
// This intentionally stays minimal: as soon as the Tuner and Metronome
// features exist, their own ViewModel/View tests live under
// test/features/<feature>/, mirroring the lib/ structure.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:music_tools/app/music_tools_app.dart';
import 'package:music_tools/features/home/presentation/view/widgets/home_hero_animation.dart';
import 'package:music_tools/features/splash/presentation/view/splash_screen.dart';

void main() {
  testWidgets('App boots and displays the home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeHeroAnimationEnabledProvider.overrideWithValue(false),
          splashScreenEnabledProvider.overrideWithValue(false),
        ],
        child: const MusicToolsApp(),
      ),
    );

    expect(find.text('Music Tools'), findsOneWidget);
  });
}
