import 'package:audioplayers_platform_interface/src/api/audio_context.dart';
import 'package:audioplayers_platform_interface/src/api/global_audio_event.dart';
import 'package:audioplayers_platform_interface/src/global_audioplayers_platform_interface.dart';
import 'package:audioplayers_platform_interface/src/map_extension.dart';
import 'package:audioplayers_platform_interface/src/method_channel_extension.dart';
import 'package:flutter/services.dart';

class GlobalAudioplayersPlatform extends GlobalAudioplayersPlatformInterface
    with
        MethodChannelGlobalAudioplayersPlatform,
        EventChannelGlobalAudioplayersPlatform {
  GlobalAudioplayersPlatform();
}

mixin MethodChannelGlobalAudioplayersPlatform
    implements MethodChannelGlobalAudioplayersPlatformInterface {
  static const MethodChannel _globalMethodChannel =
      MethodChannel('xyz.luan/audioplayers.global');

  @override
  Future<void> setGlobalAudioContext(AudioContext ctx) {
    return _globalMethodChannel.call(
      'setAudioContext',
      ctx.toJson(),
    );
  }

  @override
  Future<void> emitGlobalLog(String message) {
    return _globalMethodChannel.call(
      'emitLog',
      <String, dynamic>{
        'message': message,
      },
    );
  }

  @override
  Future<void> emitGlobalError(String code, String message) {
    return _globalMethodChannel.call(
      'emitError',
      <String, dynamic>{
        'code': code,
        'message': message,
      },
    );
  }
}

mixin EventChannelGlobalAudioplayersPlatform
    implements EventChannelGlobalAudioplayersPlatformInterface {
  static const _globalEventChannel =
      EventChannel('xyz.luan/audioplayers.global/events');

  @override
  Stream<GlobalAudioEvent> getGlobalEventStream() {
    return _globalEventChannel.receiveBroadcastStream().map((dynamic event) {
      final map = event as Map<dynamic, dynamic>;
      final eventType = map.getString('event');
      switch (eventType) {
        case 'audio.onLog':
          final value = map.getString('value');
          return GlobalAudioEvent(
            eventType: GlobalAudioEventType.log,
            logMessage: value,
          );
        default:
          throw UnimplementedError(
            'Global Event Method does not exist $eventType',
          );
      }
    });
  }
}
