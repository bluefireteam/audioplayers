import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_platform_interface/method_channel_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'util.dart';

extension MethodArguments on MethodCall {
  Map<dynamic, dynamic> get mapArguments => arguments as Map<dynamic, dynamic>;

  String getString(String key) => mapArguments.getString(key);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  Future<AudioPlayer> createPlayer({
    required String playerId,
    Stream<ByteData>? byteDataStream,
  }) async {
    final player = AudioPlayer(playerId: playerId);
    expect(player.source, null);
    createNativePlayerEventStream(
      playerId: playerId,
      byteDataStream: byteDataStream,
    );
    await player.creatingCompleter.future;
    expect(popLastCall().method, 'create');
    return player;
  }

  group('AudioPlayers Method Channel', () {
    late AudioPlayer player;

    setUp(() async {
      methodCalls.clear();
      const playerId = 'playerId_1';
      player = await createPlayer(playerId: playerId);
    });

    test('#setSource', () async {
      await player.setSource(UrlSource('internet.com/file.mp3'));
      expect(popLastCall().method, 'setSourceUrl');
      expect(player.source, isInstanceOf<UrlSource>());
      final urlSource = player.source as UrlSource?;
      expect(urlSource?.url, 'internet.com/file.mp3');

      await player.release();
      expect(player.source, null);
    });

    test('#play', () async {
      await player.play(UrlSource('internet.com/file.mp3'));
      final call1 = popCall();
      expect(call1.method, 'setSourceUrl');
      expect(call1.getString('url'), 'internet.com/file.mp3');
      final call2 = popLastCall();
      expect(call2.method, 'resume');
    });

    test('multiple players', () async {
      final player2 = await createPlayer(playerId: 'playerId_2');

      await player.play(UrlSource('internet.com/file.mp3'));
      final call1 = popCall();
      final player1Id = call1.getString('playerId');
      expect(call1.method, 'setSourceUrl');
      expect(call1.getString('url'), 'internet.com/file.mp3');
      final call2 = popLastCall();
      expect(call2.method, 'resume');

      clear();
      await player.play(UrlSource('internet.com/file.mp3'));
      expect(popCall().getString('playerId'), player1Id);

      clear();
      await player2.play(UrlSource('internet.com/file.mp3'));
      expect(popCall().getString('playerId'), isNot(player1Id));

      clear();
      await player.play(UrlSource('internet.com/file.mp3'));
      expect(popCall().getString('playerId'), player1Id);
    });

    test('#resume, #pause and #duration', () async {
      await player.setSourceUrl('assets/audio.mp3');
      expect(popLastCall().method, 'setSourceUrl');

      await player.resume();
      expect(popLastCall().method, 'resume');

      await player.getDuration();
      expect(popLastCall().method, 'getDuration');

      await player.pause();
      expect(popLastCall().method, 'pause');
    });
  });

  group('AudioPlayers Event Channel', () {
    late AudioPlayer player;

    setUp(() async {
      methodCalls.clear();
    });

    test('event stream', () async {
      const playerId = 'playerId_1';

      final eventController = StreamController<ByteData>.broadcast();

      player = await createPlayer(
        playerId: playerId,
        byteDataStream: eventController.stream,
      );

      expect(
        player.eventStream,
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

      eventController.close();
    });
  });
}
