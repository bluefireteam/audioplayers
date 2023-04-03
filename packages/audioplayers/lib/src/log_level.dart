enum LogLevel { info, error, none }

extension LogLevelExtension on LogLevel {
  int toInt() {
    switch (this) {
      case LogLevel.info:
        return 2;
      case LogLevel.error:
        return 1;
      case LogLevel.none:
        return 0;
    }
  }

  static LogLevel fromInt(int level) {
    switch (level) {
      case 2:
        return LogLevel.info;
      case 1:
        return LogLevel.error;
      case 0:
        return LogLevel.none;
      default:
        throw Exception('Invalid LogLevel value: $level');
    }
  }
}
