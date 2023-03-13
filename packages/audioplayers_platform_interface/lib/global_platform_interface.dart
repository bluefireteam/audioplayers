import 'package:audioplayers_platform_interface/api/audio_context_config.dart';
import 'package:audioplayers_platform_interface/api/global_event.dart';
import 'package:audioplayers_platform_interface/global_platform.dart';
import 'package:meta/meta.dart';

abstract class GlobalPlatformInterface
    implements
        MethodChannelGlobalPlatformInterface,
        EventChannelGlobalPlatformInterface {
  static GlobalPlatformInterface instance = GlobalPlatform();
}

abstract class MethodChannelGlobalPlatformInterface {
  Future<void> setGlobalAudioContext(AudioContext ctx);

  @visibleForTesting
  Future<void> emitGlobalLog(String message);

  @visibleForTesting
  Future<void> emitGlobalError(String code, String message);
}

abstract class EventChannelGlobalPlatformInterface {
  Stream<GlobalEvent> getGlobalEventStream();
}
