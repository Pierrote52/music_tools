import 'dart:async';

import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_tools/features/metronome/data/services/drift_corrected_metronome_ticker.dart';

void main() {
  group('DriftCorrectedMetronomeTicker', () {
    test('emits one tick per interval, exactly on the beat', () {
      fakeAsync((async) {
        withClock(Clock(() => async.getClock(DateTime(2024)).now()), () {
          final ticker = DriftCorrectedMetronomeTicker();
          final tickElapsedTimes = <Duration>[];
          final subscription = ticker
              .start(interval: const Duration(milliseconds: 500))
              .listen((_) => tickElapsedTimes.add(async.elapsed));

          async.elapse(const Duration(milliseconds: 2000));

          expect(tickElapsedTimes, [
            const Duration(milliseconds: 500),
            const Duration(milliseconds: 1000),
            const Duration(milliseconds: 1500),
            const Duration(milliseconds: 2000),
          ]);

          unawaited(subscription.cancel());
          ticker.stop();
        });
      });
    });

    test('stop() cancels pending ticks', () {
      fakeAsync((async) {
        withClock(Clock(() => async.getClock(DateTime(2024)).now()), () {
          final ticker = DriftCorrectedMetronomeTicker();
          var tickCount = 0;
          final subscription = ticker
              .start(interval: const Duration(milliseconds: 100))
              .listen((_) => tickCount++);

          async.elapse(const Duration(milliseconds: 250));
          expect(tickCount, 2);

          ticker.stop();
          async.elapse(const Duration(milliseconds: 500));
          expect(tickCount, 2);

          unawaited(subscription.cancel());
        });
      });
    });

    test('calling start() again restarts at the new interval', () {
      fakeAsync((async) {
        withClock(Clock(() => async.getClock(DateTime(2024)).now()), () {
          final ticker = DriftCorrectedMetronomeTicker();
          var slowTicks = 0;
          final firstSubscription = ticker
              .start(interval: const Duration(milliseconds: 500))
              .listen((_) => slowTicks++);

          async.elapse(const Duration(milliseconds: 400));

          var fastTicks = 0;
          final secondSubscription = ticker
              .start(interval: const Duration(milliseconds: 100))
              .listen((_) => fastTicks++);

          async.elapse(const Duration(milliseconds: 350));

          expect(slowTicks, 0, reason: 'the first stream must not tick after being restarted');
          expect(fastTicks, 3);

          unawaited(firstSubscription.cancel());
          unawaited(secondSubscription.cancel());
          ticker.stop();
        });
      });
    });
  });
}
