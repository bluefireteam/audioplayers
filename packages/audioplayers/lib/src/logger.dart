import 'package:audioplayers/audioplayers.dart';

class Logger {
  static Logger instance = Logger();

  void log(String message) {
    // ignore: avoid_print
    print('AudioPlayers Log: $message');
  }

  void error(Object o, [StackTrace? stacktrace]) {
    // ignore: avoid_print
    print(errorToString(o, stacktrace));
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
}

class AudioPlayerException implements Exception {
  Object? cause;
  AudioPlayer player;

  AudioPlayerException(this.player, {this.cause});

  @override
  String toString() =>
      'AudioPlayerException(\n\t${player.source}, \n\t$cause';
}
