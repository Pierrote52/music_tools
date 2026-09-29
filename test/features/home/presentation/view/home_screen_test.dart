import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_tools/features/home/presentation/view/home_screen.dart';
import 'package:music_tools/features/home/presentation/view/widgets/home_hero_animation.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('lists the Metronome and Tuner tools', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeHeroAnimationEnabledProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      expect(find.text('Metronome'), findsOneWidget);
      expect(find.text('Tuner'), findsOneWidget);
    });

    testWidgets('tapping Metronome navigates to the metronome screen', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeHeroAnimationEnabledProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.tap(find.text('Metronome'));
      await tester.pumpAndSettle();

      // Only the metronome screen shows a BPM value.
      expect(find.text('120 BPM'), findsOneWidget);
    });

    testWidgets('tapping Tuner navigates to the tuner screen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeHeroAnimationEnabledProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.tap(find.text('Tuner'));
      await tester.pumpAndSettle();

      // Only the tuner screen shows the "no note detected yet" placeholder.
      expect(find.text('—'), findsOneWidget);
    });
  });
}
