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
    // Avoid unpredictable position updates
    player.positionUpdater = null;
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
      expect(platform.popLastCall().method, 'resume');
    });

    test('multiple players', () async {
      final player2 = await createPlayer(playerId: 'p2');

      await player.play(UrlSource('internet.com/file.mp3'));
      final call1 = platform.popCall();
      expect(call1.id, 'p1');
      expect(call1.method, 'setSourceUrl');
      expect(call1.value, 'internet.com/file.mp3');
      expect(platform.popLastCall().method, 'resume');

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

    test('set #volume, #balance, #playbackRate, #playerMode, #releaseMode',
        () async {
      await player.setVolume(0.1);
      expect(player.volume, 0.1);
      expect(platform.popLastCall().method, 'setVolume');

      await player.setBalance(0.2);
      expect(player.balance, 0.2);
      expect(platform.popLastCall().method, 'setBalance');

      await player.setPlaybackRate(0.3);
      expect(player.playbackRate, 0.3);
      expect(platform.popLastCall().method, 'setPlaybackRate');

      await player.setPlayerMode(PlayerMode.lowLatency);
      expect(player.mode, PlayerMode.lowLatency);
      expect(platform.popLastCall().method, 'setPlayerMode');

      await player.setReleaseMode(ReleaseMode.loop);
      expect(player.releaseMode, ReleaseMode.loop);
      expect(platform.popLastCall().method, 'setReleaseMode');
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

      audioEvents.forEach(platform.eventStreamControllers['p1']!.add);
      await platform.eventStreamControllers['p1']!.close();
    });
  });
}
