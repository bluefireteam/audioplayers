import 'package:audioplayers_platform_interface/api/log.dart';

class Logger {
  static Logger instance = Logger();

  LogLevel logLevel = LogLevel.error;

  void log(LogLevel level, String message) {
    if (level.toInt() <= logLevel.toInt()) {
      // ignore: avoid_print
      print('${level.toString()}: $message');
    }
  }

  void info(String message) => log(LogLevel.info, message);

  void error(String message) => log(LogLevel.error, message);
}
