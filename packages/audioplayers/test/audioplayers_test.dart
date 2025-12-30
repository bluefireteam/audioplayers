import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// 1. Mock the PlatformInterface
class MockAudioplayersPlatform extends Mock
    implements AudioplayersPlatformInterface {}

class MockGlobalAudioplayersPlatform extends Mock
    implements GlobalAudioplayersPlatformInterface {}

class FakeAudioContext extends Fake implements AudioContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAudioplayersPlatform mockPlatform;
  late MockGlobalAudioplayersPlatform mockGlobalPlatform;
  late StreamController<AudioEvent> eventStreamController;

  setUpAll(() {
    registerFallbackValue(FakeAudioContext());
  });

  // Initial configuration before each test
  setUp(() {
    mockPlatform = MockAudioplayersPlatform();
    mockGlobalPlatform = MockGlobalAudioplayersPlatform();
    eventStreamController = StreamController<AudioEvent>.broadcast();

    // Inject our mocks
    AudioplayersPlatformInterface.instance = mockPlatform;
    GlobalAudioplayersPlatformInterface.instance = mockGlobalPlatform;

    // By default, assume player creation succeeds
    when(() => mockPlatform.create(any())).thenAnswer((_) async {});
    // Return our controller's stream
    when(() => mockPlatform.getEventStream(any()))
        .thenAnswer((_) => eventStreamController.stream);

    // Mock dispose to prevent errors at the end of tests
    when(() => mockPlatform.dispose(any())).thenAnswer((_) async {
      eventStreamController.close();
    });
    when(() => mockPlatform.stop(any())).thenAnswer((_) async {});
    when(() => mockPlatform.release(any())).thenAnswer((_) async {});
    when(() => mockPlatform.getCurrentPosition(any()))
        .thenAnswer((_) async => 0);

    // Mock global calls
    when(() => mockGlobalPlatform.setGlobalAudioContext(any()))
        .thenAnswer((_) async {});
    when(() => mockGlobalPlatform.getGlobalEventStream())
        .thenAnswer((_) => const Stream.empty());

    // Mock global initialization
    when(() => mockGlobalPlatform.init()).thenAnswer((_) async {});
  });

  group('AudioPlayer Logic', () {
    test('instantiation', () {
      final player = AudioPlayer();
      expect(player, isNotNull);
      player.dispose();
    });

    test('play() calls setSource and resume on platform', () async {
      final player = AudioPlayer(playerId: 'p1');
      final source = UrlSource('https://example.com/audio.mp3');

      // Mock expected calls
      when(
        () => mockPlatform.setSourceUrl(
          'p1',
          any(),
          isLocal: any(named: 'isLocal'),
          mimeType: any(named: 'mimeType'),
        ),
      ).thenAnswer((_) async {
        // IMPORTANT: Simulate platform response saying "It's ready!"
        eventStreamController.add(
          const AudioEvent(
            eventType: AudioEventType.prepared,
            isPrepared: true,
          ),
        );
      });

      when(() => mockPlatform.resume('p1')).thenAnswer((_) async {});

      // Action
      await player.play(source);

      // Verify
      verify(
        () => mockPlatform.setSourceUrl(
          'p1',
          any(), // Encoded URL
          isLocal: false,
        ),
      ).called(1);

      verify(() => mockPlatform.resume('p1')).called(1);

      // Cleanup
      await player.dispose();
    });

    test('setVolume() delegates to platform', () async {
      final player = AudioPlayer(playerId: 'p1');

      when(() => mockPlatform.setVolume('p1', 0.5)).thenAnswer((_) async {});

      await player.setVolume(0.5);

      verify(() => mockPlatform.setVolume('p1', 0.5)).called(1);
      expect(player.volume, 0.5);

      await player.dispose();
    });

    test('State is updated when calling resume/pause', () async {
      final player = AudioPlayer(playerId: 'p1');

      when(() => mockPlatform.resume('p1')).thenAnswer((_) async {});
      when(() => mockPlatform.pause('p1')).thenAnswer((_) async {});

      // Test Resume
      await player.resume();
      expect(player.state, PlayerState.playing);

      // Test Pause
      await player.pause();
      expect(player.state, PlayerState.paused);

      await player.dispose();
    });
  });
}
