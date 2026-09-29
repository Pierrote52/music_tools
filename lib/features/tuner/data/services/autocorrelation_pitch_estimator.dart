import 'dart:math' as math;

/// Below this root-mean-square amplitude, a window of [samples] is
/// considered silence and no frequency is estimated.
const double _silenceRmsThreshold = 0.01;

/// A candidate lag must reach at least this fraction of the strongest
/// correlation found to be accepted as the fundamental.
///
/// A periodic signal correlates strongly not just at its true period but
/// also at multiples of it (harmonics), which would otherwise pick a lag
/// twice as long as the real one — i.e. half the true frequency. Preferring
/// the *shortest* local peak that clears this threshold avoids that
/// "octave error".
const double _harmonicRejectionThreshold = 0.85;

/// Estimates the fundamental frequency of a mono [samples] window (values
/// normalized to `[-1, 1]`) using time-domain autocorrelation, or returns
/// `null` if no clear periodic pitch could be found.
///
/// This is a deliberately simple, well-understood algorithm — not as
/// robust as e.g. YIN against noisy or highly harmonic signals — chosen so
/// its behavior stays easy to read, test, and reason about. See
/// `test/features/tuner/data/` for its accuracy on synthetic sine waves.
double? estimateFrequency(
  List<double> samples, {
  required int sampleRate,
  double minFrequency = 60,
  double maxFrequency = 1000,
}) {
  if (samples.length < 2) {
    return null;
  }

  if (_rootMeanSquare(samples) < _silenceRmsThreshold) {
    return null;
  }

  final minLag = (sampleRate / maxFrequency).floor().clamp(
    1,
    samples.length - 1,
  );
  final maxLag = (sampleRate / minFrequency).ceil().clamp(
    minLag + 1,
    samples.length - 1,
  );

  final correlations = [
    for (var lag = minLag; lag <= maxLag; lag++)
      _autocorrelationAt(samples, lag),
  ];

  var peakCorrelation = 0.0;
  var peakIndex = 0;
  for (var i = 0; i < correlations.length; i++) {
    if (correlations[i] > peakCorrelation) {
      peakCorrelation = correlations[i];
      peakIndex = i;
    }
  }

  if (peakCorrelation <= 0) {
    return null;
  }

  // A pure tone's correlation rises and falls smoothly around each peak
  // (it's shaped like a cosine of the lag), so simply thresholding against
  // the peak would trigger on the *rising slope* before the true period is
  // reached. Requiring a local maximum — not just "close enough" — avoids
  // that, while still preferring the shortest (fundamental) peak over its
  // harmonics by scanning from the smallest lag upward.
  for (var i = 1; i < correlations.length - 1; i++) {
    final isLocalMaximum =
        correlations[i] >= correlations[i - 1] &&
        correlations[i] >= correlations[i + 1];
    if (isLocalMaximum &&
        correlations[i] >= peakCorrelation * _harmonicRejectionThreshold) {
      return sampleRate / (minLag + i);
    }
  }

  // No interior local maximum qualified (e.g. the true peak sits right at
  // minLag or maxLag): fall back to the strongest lag found overall.
  return sampleRate / (minLag + peakIndex);
}

double _autocorrelationAt(List<double> samples, int lag) {
  final overlapCount = samples.length - lag;
  var sum = 0.0;
  for (var i = 0; i < overlapCount; i++) {
    sum += samples[i] * samples[i + lag];
  }
  // Without dividing by the overlap size, shorter lags would always score
  // higher simply for having more overlapping terms summed — regardless of
  // whether they actually align with the signal's period.
  return sum / overlapCount;
}

double _rootMeanSquare(List<double> samples) {
  var sumOfSquares = 0.0;
  for (final sample in samples) {
    sumOfSquares += sample * sample;
  }
  return math.sqrt(sumOfSquares / samples.length);
}
