import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/metronome_ticker.dart';

/// A [MetronomeTicker] that stays accurate over time by scheduling each
/// tick against an absolute target time instead of chaining fixed delays.
///
/// A naive `Timer.periodic(interval, ...)` drifts: each callback takes a
/// small, variable amount of time to run, and that overhead accumulates
/// tick after tick, so the metronome would slowly fall behind the
/// requested tempo. This implementation instead tracks how much time has
/// passed using [Clock.now] and computes, before scheduling the next
/// [Timer], exactly how long to wait to land on `interval * tickCount` —
/// correcting for any drift introduced by the previous tick. Reading the
/// time through [clock] (rather than `DateTime.now()`/`Stopwatch`
/// directly) is what lets tests drive this with a virtual clock (see
/// `test/features/metronome/data/`).
class DriftCorrectedMetronomeTicker implements MetronomeTicker {
  Timer? _timer;
  StreamController<void>? _controller;
  DateTime? _startTime;
  int _tickCount = 0;

  @override
  Stream<void> start({required Duration interval}) {
    stop();

    final controller = StreamController<void>();
    _controller = controller;
    _startTime = clock.now();
    _tickCount = 0;
    _scheduleNextTick(interval);
    return controller.stream;
  }

  @override
  void stop() {
    _timer?.cancel();
    _timer = null;
    _startTime = null;
    unawaited(_controller?.close());
    _controller = null;
  }

  void _scheduleNextTick(Duration interval) {
    final startTime = _startTime;
    final controller = _controller;
    if (startTime == null || controller == null) {
      return;
    }

    _tickCount++;
    final target = interval * _tickCount;
    final elapsed = clock.now().difference(startTime);
    final delay = target - elapsed;

    _timer = Timer(delay.isNegative ? Duration.zero : delay, () {
      controller.add(null);
      _scheduleNextTick(interval);
    });
  }
}

/// Provides the [MetronomeTicker] implementation used by the app.
///
/// The ViewModel depends on the [MetronomeTicker] interface, never on
/// [DriftCorrectedMetronomeTicker] directly, so tests can override this
/// provider with a fake ticker instead of scheduling real timers.
final metronomeTickerProvider = Provider<MetronomeTicker>((ref) {
  return DriftCorrectedMetronomeTicker();
});
