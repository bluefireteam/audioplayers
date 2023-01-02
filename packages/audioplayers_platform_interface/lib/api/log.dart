class Log {
  Log(this.message, {this.level = LogLevel.info});

  final LogLevel level;
  final String message;
}

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
      default:
        return LogLevel.none;
    }
  }
}
