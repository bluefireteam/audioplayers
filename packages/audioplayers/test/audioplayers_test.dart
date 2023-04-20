import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_audioplayers_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAudioplayersPlatform platform;
  setUp(() {
    platform = FakeAudioplayersPlatform();
    AudioplayersPlatformInterface.instance = platform;
  });

  Future<AudioPlayer> createPlayer({
    required String playerId,
  }) async {
    final player = AudioPlayer(playerId: playerId);
    expect(player.source, null);
    await player.creatingCompleter.future;
    expect(platform.popCall().method, 'create');
    expect(platform.popLastCall().method, 'getEventStream');
    return player;
  }

  group('AudioPlayer Methods', () {
    late AudioPlayer player;

    setUp(() async {
      player = await createPlayer(playerId: 'p1');
      expect(player.source, null);
    });

    test('#setSource and #dispose', () async {
      await player.setSource(UrlSource('internet.com/file.mp3'));
      expect(platform.popLastCall().method, 'setSourceUrl');
      expect(player.source, isInstanceOf<UrlSource>());
      final urlSource = player.source as UrlSource?;
      expect(urlSource?.url, 'internet.com/file.mp3');

      await player.dispose();
      expect(platform.popCall().method, 'stop');
      expect(platform.popCall().method, 'release');
      expect(platform.popLastCall().method, 'dispose');
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
      player = await createPlayer(playerId: 'p1');
      expect(player.source, null);
    });

    test('event stream', () async {
      final audioEvents = <AudioEvent>[
        const AudioEvent(
          eventType: AudioEventType.duration,
          duration: Duration(milliseconds: 98765),
        ),
        const AudioEvent(
          eventType: AudioEventType.position,
          position: Duration(milliseconds: 8765),
        ),
        const AudioEvent(
          eventType: AudioEventType.log,
          logMessage: 'someLogMessage',
        ),
        const AudioEvent(
          eventType: AudioEventType.complete,
        ),
        const AudioEvent(
          eventType: AudioEventType.seekComplete,
        ),
      ];

      expect(
        player.eventStream,
        emitsInOrder(audioEvents),
      );

      audioEvents.forEach(platform.eventStreamController.add);
      await platform.eventStreamController.close();
    });
  });
}
