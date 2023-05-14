extension NumExtension on num {
  /// Converts [num] (expected in seconds) to the duration.
  Duration fromSecondsToDuration() => Duration(
        milliseconds: ((isNaN || isInfinite ? 0 : this) * 1000).round(),
      );
}
