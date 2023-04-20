enum AudioLogLevel implements Comparable<AudioLogLevel> {
  none(0),
  error(1),
  info(2);

  const AudioLogLevel(this.level);

  factory AudioLogLevel.fromInt(int level) {
    return values.firstWhere((e) => e.level == level);
  }

  final int level;

  @override
  int compareTo(AudioLogLevel other) => level - other.level;
}
