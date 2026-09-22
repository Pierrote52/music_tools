import 'dart:async';

import 'package:music_tools/features/metronome/domain/services/metronome_ticker.dart';

/// A [MetronomeTicker] test double that only emits ticks when the test
/// explicitly calls [emitTick], instead of driving a real timer.
///
/// Shared by the ViewModel and View tests so both exercise the same,
/// single fake implementation of the domain interface.
class FakeMetronomeTicker implements MetronomeTicker {
  final StreamController<void> _controller = StreamController<void>.broadcast();

  /// Every interval passed to [start], in call order.
  final List<Duration> startedIntervals = [];

  /// How many times [stop] was called.
  int stopCallCount = 0;

  @override
  Stream<void> start({required Duration interval}) {
    startedIntervals.add(interval);
    return _controller.stream;
  }

  @override
  void stop() => stopCallCount++;

  /// Manually pushes a tick to whoever is currently listening.
  void emitTick() => _controller.add(null);

  /// Releases the underlying controller.
  Future<void> dispose() => _controller.close();
}
