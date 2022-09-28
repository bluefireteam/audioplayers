extension NumExtension on num {
  /// converts num to the duration, if in seconds
  Duration fromSecondsToDuration() => Duration(
        seconds: (isNaN || isInfinite ? 0 : this).round(),
      );
}
