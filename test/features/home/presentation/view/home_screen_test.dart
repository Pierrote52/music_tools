import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_tools/features/home/presentation/view/home_screen.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('lists the Metronome tool', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HomeScreen())),
      );

      expect(find.text('Metronome'), findsOneWidget);
    });

    testWidgets('tapping the Metronome tool navigates to its screen', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HomeScreen())),
      );

      await tester.tap(find.text('Metronome'));
      await tester.pumpAndSettle();

      // Only the metronome screen has a Start/Stop button.
      expect(find.text('Start'), findsOneWidget);
    });
  });
}
