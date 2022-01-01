import 'package:flutter/services.dart';

import 'api/log_level.dart';
import 'method_channel_interface.dart';

abstract class LoggerPlatformInterface {
  static LoggerPlatformInterface instance = MethodChannelLoggerPlatform();

  LogLevel get logLevel;

  Future<int> changeLogLevel(LogLevel value);

  void log(LogLevel level, String message) {
    if (level.getLevel() <= logLevel.getLevel()) {
      print(message);
    }
  }

  void info(String message) => log(LogLevel.info, message);

  void error(String message) => log(LogLevel.error, message);
}

class MethodChannelLoggerPlatform extends LoggerPlatformInterface {
  static const MethodChannel _channel =
      MethodChannel('xyz.luan/audioplayers.logger');

  static LogLevel _logLevel = LogLevel.error;

  @override
  Future<int> changeLogLevel(LogLevel value) {
    _logLevel = value;
    return _channel.invoke(
      'changeLogLevel',
      <String, dynamic>{'value': value.toString()},
    );
  }

  @override
  LogLevel get logLevel => _logLevel;
}
