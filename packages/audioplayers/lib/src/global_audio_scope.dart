import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';

/// Handle global audio scope like calls and events concerning all AudioPlayers.
class GlobalAudioScope {
  final _platform = GlobalAudioplayersPlatformInterface.instance;

  LogLevel get logLevel => _platform.logLevel;

  Future<void> changeLogLevel(LogLevel level) =>
      _platform.changeLogLevel(level);

  void log(LogLevel level, String message) => _platform.log(level, message);

  void info(String message) => _platform.info(message);

  void error(String message) => _platform.error(message);

  Future<void> setAudioContext(AudioContext ctx) =>
      _platform.setGlobalAudioContext(ctx);

  @Deprecated('Use `setAudioContext()` instead.')
  Future<void> setGlobalAudioContext(AudioContext ctx) =>
      _platform.setGlobalAudioContext(ctx);
}
