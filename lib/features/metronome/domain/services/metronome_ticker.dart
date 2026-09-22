/// A source of precisely-spaced ticks, one per beat.
///
/// This is the only abstraction the ViewModel depends on for *timing*. Its
/// concrete implementation (in `data/services/`) is free to use whatever
/// timer mechanism it needs — the domain and presentation layers never see
/// it, which is what lets tests substitute a fake ticker instead of real
/// wall-clock time.
abstract class MetronomeTicker {
  /// Starts emitting one event on the returned stream every [interval],
  /// until [stop] is called. Calling [start] again while already running
  /// restarts it at the new interval.
  Stream<void> start({required Duration interval});

  /// Stops emitting ticks. Safe to call even if not currently running.
  void stop();
}
