import 'package:audioplayers/audioplayers.dart';

class Logger {
  static LogLevel logLevel = LogLevel.error;

  static void log(String message) {
    if (LogLevel.info.level <= logLevel.level) {
      // ignore: avoid_print
      print('AudioPlayers Log: $message');
    }
  }

  static void error(Object o, [StackTrace? stacktrace]) {
    if (LogLevel.error.level <= logLevel.level) {
      // ignore: avoid_print
      print(_errorColor(errorToString(o, stacktrace)));
    }
  }

  static String errorToString(Object o, [StackTrace? stackTrace]) {
    String errStr;
    if (o is Error) {
      errStr = 'AudioPlayers Error: $o\n${o.stackTrace}';
    } else if (o is Exception) {
      errStr = 'AudioPlayers Exception: $o';
    } else {
      errStr = 'AudioPlayers throw: $o';
    }
    if (stackTrace != null && stackTrace.toString().isNotEmpty) {
      errStr += '\n$stackTrace';
    }
    return errStr;
  }

  static String _errorColor(String text) => '\x1B[31m$text\x1B[0m';
}

class AudioPlayerException implements Exception {
  Object? cause;
  AudioPlayer player;

  AudioPlayerException(this.player, {this.cause});

  @override
  String toString() => 'AudioPlayerException(\n\t${player.source}, \n\t$cause';
}
