import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAudioplayersPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements AudioplayersPlatformInterface {}

class MockGlobalAudioplayersPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GlobalAudioplayersPlatformInterface {}

class MockAudioCache extends Mock implements AudioCache {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(const Duration(seconds: 1));
    registerFallbackValue(PlayerMode.mediaPlayer);
    registerFallbackValue(ReleaseMode.release);
  });

  late AudioPlayer player;
  late MockAudioplayersPlatform mockPlatform;
  late MockGlobalAudioplayersPlatform mockGlobalPlatform;
  late MockAudioCache mockCache;
  late StreamController<AudioEvent> eventController;

  setUp(() {
    mockPlatform = MockAudioplayersPlatform();
    AudioplayersPlatformInterface.instance = mockPlatform;

    mockGlobalPlatform = MockGlobalAudioplayersPlatform();
    GlobalAudioplayersPlatformInterface.instance = mockGlobalPlatform;

    mockCache = MockAudioCache();

    eventController = StreamController<AudioEvent>.broadcast();

    // Stubbing global platform
    when(() => mockGlobalPlatform.init()).thenAnswer((_) async {});
    when(() => mockGlobalPlatform.getGlobalEventStream())
        .thenAnswer((_) => const Stream<GlobalAudioEvent>.empty());

    // Stubbing player platform basic methods
    when(() => mockPlatform.create(any())).thenAnswer((_) async {});
    when(() => mockPlatform.getEventStream(any()))
        .thenAnswer((_) => eventController.stream);
    when(() => mockPlatform.dispose(any())).thenAnswer((_) async {});
    when(
      () => mockPlatform.setSourceUrl(
        any(),
        any(),
        isLocal: any(named: 'isLocal'),
        mimeType: any(named: 'mimeType'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockPlatform.setSourceBytes(
        any(),
        any(),
        mimeType: any(named: 'mimeType'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockPlatform.resume(any())).thenAnswer((_) async {});
    when(() => mockPlatform.pause(any())).thenAnswer((_) async {});
    when(() => mockPlatform.stop(any())).thenAnswer((_) async {});
    when(() => mockPlatform.release(any())).thenAnswer((_) async {});
    when(() => mockPlatform.seek(any(), any())).thenAnswer((_) async {});
    when(() => mockPlatform.setVolume(any(), any())).thenAnswer((_) async {});
    when(() => mockPlatform.setBalance(any(), any())).thenAnswer((_) async {});
    when(() => mockPlatform.setPlaybackRate(any(), any()))
        .thenAnswer((_) async {});
    when(() => mockPlatform.getCurrentPosition(any()))
        .thenAnswer((_) async => 0);
    when(() => mockPlatform.getDuration(any())).thenAnswer((_) async => 0);

    player = AudioPlayer();
    player.audioCache = mockCache;
  });

  tearDown(() async {
    await eventController.close();
  });

  group('AudioPlayer Unit Tests', () {
    test('Initialization calls create on platform', () async {
      verify(() => mockPlatform.create(player.playerId)).called(1);
    });

    test('play() with UrlSource calls setSourceUrl and resume', () async {
      await player.creatingCompleter.future;

      final playFuture =
          player.play(UrlSource('https://example.com/audio.mp3'));
      await Future.delayed(const Duration(milliseconds: 100));
      eventController.add(
        const AudioEvent(
          eventType: AudioEventType.prepared,
          isPrepared: true,
        ),
      );

      await playFuture;

      verify(
        () => mockPlatform.setSourceUrl(
          player.playerId,
          'https://example.com/audio.mp3',
          isLocal: any(named: 'isLocal'),
          mimeType: any(named: 'mimeType'),
        ),
      ).called(1);
      verify(() => mockPlatform.resume(player.playerId)).called(1);
      expect(player.state, PlayerState.playing);
    });

    test('play() with AssetSource calls AudioCache and setSourceUrl', () async {
      await player.creatingCompleter.future;
      when(() => mockCache.loadPath('sounds/test.mp3'))
          .thenAnswer((_) async => 'assets/sounds/test.mp3');

      final playFuture = player.play(AssetSource('sounds/test.mp3'));
      await Future.delayed(const Duration(milliseconds: 100));
      eventController.add(
        const AudioEvent(
          eventType: AudioEventType.prepared,
          isPrepared: true,
        ),
      );

      await playFuture;

      verify(() => mockCache.loadPath('sounds/test.mp3')).called(1);
      verify(
        () => mockPlatform.setSourceUrl(
          player.playerId,
          'assets/sounds/test.mp3',
          isLocal: any(named: 'isLocal'),
          mimeType: any(named: 'mimeType'),
        ),
      ).called(1);
      verify(() => mockPlatform.resume(player.playerId)).called(1);
    });

    test('play() with BytesSource calls setSourceBytes', () async {
      await player.creatingCompleter.future;
      final bytes = Uint8List.fromList([0, 1, 2, 3]);

      final playFuture = player.play(BytesSource(bytes));
      await Future.delayed(const Duration(milliseconds: 100));
      eventController.add(
        const AudioEvent(
          eventType: AudioEventType.prepared,
          isPrepared: true,
        ),
      );

      await playFuture;

      verify(
        () => mockPlatform.setSourceBytes(
          player.playerId,
          bytes,
          mimeType: any(named: 'mimeType'),
        ),
      ).called(1);
      verify(() => mockPlatform.resume(player.playerId)).called(1);
    });

    test('pause() updates state and calls platform', () async {
      await player.pause();
      verify(() => mockPlatform.pause(player.playerId)).called(1);
      expect(player.state, PlayerState.paused);
    });

    test('stop() updates state and calls platform', () async {
      await player.stop();
      verify(() => mockPlatform.stop(player.playerId)).called(1);
      expect(player.state, PlayerState.stopped);
    });

    test('seek() calls platform and waits for completion', () async {
      await player.creatingCompleter.future;

      final seekFuture = player.seek(const Duration(seconds: 10));
      await Future.delayed(const Duration(milliseconds: 100));
      eventController.add(
        const AudioEvent(eventType: AudioEventType.seekComplete),
      );

      await seekFuture;

      verify(
        () => mockPlatform.seek(player.playerId, const Duration(seconds: 10)),
      ).called(1);
    });

    test('setVolume/Balance/Rate call platform', () async {
      await player.setVolume(0.5);
      verify(() => mockPlatform.setVolume(player.playerId, 0.5)).called(1);

      await player.setBalance(-1.0);
      verify(() => mockPlatform.setBalance(player.playerId, -1.0)).called(1);

      await player.setPlaybackRate(1.5);
      verify(() => mockPlatform.setPlaybackRate(player.playerId, 1.5))
          .called(1);
    });

    test('handles platform errors via stream', () async {
      await player.creatingCompleter.future;

      // We just want to ensure adding an error to the stream doesn't crash
      // the player
      eventController.addError(Exception('Platform Error'));

      // The error is logged asynchronously, we just verify the player is still
      // alive
      expect(player.state, isNot(PlayerState.disposed));
    });

    test('dispose() releases resources', () async {
      await player.dispose();
      verify(() => mockPlatform.release(player.playerId)).called(1);
      verify(() => mockPlatform.dispose(player.playerId)).called(1);
      expect(player.state, PlayerState.disposed);
    });
  });
}
