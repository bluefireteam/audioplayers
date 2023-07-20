/// Data of a ui test source.
abstract class SourceTestData {
  Duration duration;

  bool isLiveStream;

  SourceTestData({
    required this.duration,
    this.isLiveStream = false,
  });

  @override
  String toString() {
    return 'SourceTestData('
        'duration: $duration, '
        'isLiveStream: $isLiveStream'
        ')';
  }
}
