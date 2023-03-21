import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:audioplayers_platform_interface/src/map_extension.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_audioplayers_platform.dart';

import 'util.dart';

extension MethodArguments on MethodCall {
  Map<dynamic, dynamic> get mapArguments => arguments as Map<dynamic, dynamic>;

  String getString(String key) => mapArguments.getString(key);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAudioplayersPlatform platform;
  setUp(() {
    platform = FakeAudioplayersPlatform();
    AudioplayersPlatformInterface.instance = platform;
  });

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
    expect(platform.popLastCall().method, 'create');
    return player;
  }

  group('AudioPlayer Methods', () {
    late AudioPlayer player;

    setUp(() async {
      player = await createPlayer(playerId: 'p1');
      expect(player.source, null);
    });

    test('#setSource', () async {
      await player.setSource(UrlSource('internet.com/file.mp3'));
      expect(platform.popLastCall().method, 'setSourceUrl');
      expect(player.source, isInstanceOf<UrlSource>());
      final urlSource = player.source as UrlSource?;
      expect(urlSource?.url, 'internet.com/file.mp3');

      await player.release();
      expect(platform.popLastCall().method, 'release');
      expect(player.source, null);
    });

    test('#play', () async {
      await player.play(UrlSource('internet.com/file.mp3'));
      final call1 = platform.popCall();
      expect(call1.method, 'setSourceUrl');
      expect(call1.value, 'internet.com/file.mp3');
      final call2 = platform.popLastCall();
      expect(call2.method, 'resume');
    });

    test('multiple players', () async {
      final player2 = await createPlayer(playerId: 'p2');

      await player.play(UrlSource('internet.com/file.mp3'));
      final call1 = platform.popCall();
      expect(call1.id, 'p1');
      expect(call1.method, 'setSourceUrl');
      expect(call1.value, 'internet.com/file.mp3');
      final call2 = platform.popLastCall();
      expect(call2.method, 'resume');

      platform.clear();
      await player.play(UrlSource('internet.com/file.mp3'));
      expect(platform.popCall().id, 'p1');

      platform.clear();
      await player2.play(UrlSource('internet.com/file.mp3'));
      expect(platform.popCall().id, 'p2');

      platform.clear();
      await player.play(UrlSource('internet.com/file.mp3'));
      expect(platform.popCall().id, 'p1');
    });

    test('#resume, #pause and #duration', () async {
      await player.setSourceUrl('assets/audio.mp3');
      expect(platform.popLastCall().method, 'setSourceUrl');

      await player.resume();
      expect(platform.popLastCall().method, 'resume');

      await player.getDuration();
      expect(platform.popLastCall().method, 'getDuration');

      await player.pause();
      expect(platform.popLastCall().method, 'pause');
    });
  });

  group('AudioPlayers Events', () {
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
