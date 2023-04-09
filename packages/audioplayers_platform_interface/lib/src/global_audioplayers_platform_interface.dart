import 'package:audioplayers_platform_interface/src/api/audio_context.dart';
import 'package:audioplayers_platform_interface/src/api/global_audio_event.dart';
import 'package:audioplayers_platform_interface/src/global_audioplayers_platform.dart';
import 'package:meta/meta.dart';

abstract class GlobalAudioplayersPlatformInterface
    implements
        MethodChannelGlobalAudioplayersPlatformInterface,
        EventChannelGlobalAudioplayersPlatformInterface {
  static GlobalAudioplayersPlatformInterface instance =
      GlobalAudioplayersPlatform();
}

abstract class MethodChannelGlobalAudioplayersPlatformInterface {
  Future<void> setGlobalAudioContext(AudioContext ctx);

  @visibleForTesting
  Future<void> emitGlobalLog(String message);

  @visibleForTesting
  Future<void> emitGlobalError(String code, String message);
}

abstract class EventChannelGlobalAudioplayersPlatformInterface {
  Stream<GlobalAudioEvent> getGlobalEventStream();
}
