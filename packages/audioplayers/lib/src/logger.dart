import 'package:audioplayers/audioplayers.dart';

class Logger {
  static Logger instance = Logger();

  void log(String message) {
    // ignore: avoid_print
    print('AudioPlayers Log: $message');
  }

  void error(Object o) {
    // ignore: avoid_print
    print(errorToString(o));
  }

  static String errorToString(Object o) {
    if (o is Error) {
      return 'AudioPlayers Error: $o\n${o.stackTrace}';
    } else if (o is Exception) {
      return 'AudioPlayers Exception: $o';
    }
    return 'AudioPlayers throw: $o';
  }
}

class AudioPlayerException implements Exception {
  Object? throwable;
  AudioPlayer player;

  AudioPlayerException(this.player, {this.throwable});

  @override
  String toString() =>
      'AudioPlayerException(\n\t${player.source}, \n\t$throwable';
}
