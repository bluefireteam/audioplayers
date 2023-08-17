/// Data of a ui test source.
abstract class SourceTestData {
  Duration? duration;

  bool get isLiveStream => duration == null;

  SourceTestData({
    required this.duration,
  });

  @override
  String toString() {
    return 'SourceTestData('
        'duration: $duration'
        ')';
  }
}
