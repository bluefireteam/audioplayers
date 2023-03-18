import 'package:audioplayers_platform_interface/src/api/audio_context.dart';
import 'package:audioplayers_platform_interface/src/api/log_level.dart';
import 'package:audioplayers_platform_interface/src/global_audioplayers_platform.dart';

abstract class GlobalAudioplayersPlatformInterface {
  static GlobalAudioplayersPlatformInterface instance =
      GlobalAudioplayersPlatform();

  LogLevel get logLevel;

  Future<void> changeLogLevel(LogLevel value);

  Future<void> setGlobalAudioContext(AudioContext ctx);

  void log(LogLevel level, String message) {
    if (level.getLevel() <= logLevel.getLevel()) {
      // ignore: avoid_print
      print(message);
    }
  }

  void info(String message) => log(LogLevel.info, message);

  void error(String message) => log(LogLevel.error, message);
}
