enum LogLevel implements Comparable<LogLevel> {
  none(0),
  error(1),
  info(2);

  const LogLevel(this.level);

  factory LogLevel.fromInt(int level) {
    return values.firstWhere((e) => e.level == level);
  }
  
  final int level;

  @override
  int compareTo(LogLevel other) => level - other.level;
}
