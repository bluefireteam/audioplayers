import 'dart:async';

import 'package:audioplayers_platform_interface/src/api/player_event.dart';
import 'package:audioplayers_platform_interface/src/audioplayers_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = AudioplayersPlatformInterface.instance;

  final methodCalls = <MethodCall>[];
  TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('xyz.luan/audioplayers'),
    (MethodCall methodCall) async {
      methodCalls.add(methodCall);
      return 0;
    },
  );

  void clear() {
    methodCalls.clear();
  }

  MethodCall popCall() {
    return methodCalls.removeAt(0);
  }

  MethodCall popLastCall() {
    expect(methodCalls, hasLength(1));
    return popCall();
  }

  group('AudioPlayers Method Channel', () {
    setUp(clear);

    test('#setSource', () async {
      await platform.setSourceUrl('p1', 'internet.com/file.mp3');
      final call = popLastCall();
      expect(call.method, 'setSourceUrl');
      expect(call.args, {
        'playerId': 'p1',
        'url': 'internet.com/file.mp3',
        'isLocal': null,
      });
    });

    test('#resume', () async {
      await platform.resume('p1');
      final call = popLastCall();
      expect(call.method, 'resume');
      expect(call.args, {'playerId': 'p1'});
    });

    test('#pause', () async {
      await platform.pause('p1');
      final call = popLastCall();
      expect(call.method, 'pause');
      expect(call.args, {'playerId': 'p1'});
    });

    test('#getDuration', () async {
      final duration = await platform.getDuration('p1');
      final call = popLastCall();
      expect(call.method, 'getDuration');
      expect(call.args, {'playerId': 'p1'});
      expect(duration, 0);
    });

    test('#getCurrentPosition', () async {
      final position = await platform.getCurrentPosition('p1');
      final call = popLastCall();
      expect(call.method, 'getCurrentPosition');
      expect(call.args, {'playerId': 'p1'});
      expect(position, 0);
    });
  });

  group('AudioPlayers Event Channel', () {
    test('emit events', () async {
      final eventController = StreamController<ByteData>.broadcast();

      createNativeEventStream(
        channel: 'xyz.luan/audioplayers/events/p1',
        byteDataStream: eventController.stream,
      );

      expect(
        platform.getEventStream('p1'),
        emitsInOrder(<PlayerEvent>[
          const PlayerEvent(
            eventType: PlayerEventType.duration,
            duration: Duration(milliseconds: 98765),
          ),
          const PlayerEvent(
            eventType: PlayerEventType.position,
            position: Duration(milliseconds: 8765),
          ),
          const PlayerEvent(
            eventType: PlayerEventType.log,
            logMessage: 'someLogMessage',
          ),
          const PlayerEvent(
            eventType: PlayerEventType.complete,
          ),
          const PlayerEvent(
            eventType: PlayerEventType.seekComplete,
          ),
        ]),
      );

      final byteDataList = <Map<String, dynamic>>[
        <String, dynamic>{
          'event': 'audio.onDuration',
          'value': 98765,
        },
        <String, dynamic>{
          'event': 'audio.onCurrentPosition',
          'value': 8765,
        },
        <String, dynamic>{
          'event': 'audio.onLog',
          'value': 'someLogMessage',
        },
        <String, dynamic>{
          'event': 'audio.onComplete',
        },
        <String, dynamic>{
          'event': 'audio.onSeekComplete',
        },
      ];
      for (final byteData in byteDataList) {
        eventController.add(
          const StandardMethodCodec().encodeSuccessEnvelope(byteData),
        );
      }

      // Await closing controller to avoid handling events after test finishes.
      await eventController.close();
    });
  });
}
