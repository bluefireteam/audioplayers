import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';

import 'audio_cache_test.dart';
import 'fake_audioplayers_platform.dart';
import 'fake_global_audioplayers_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioPool', () {
    setUp(() {
      AudioplayersPlatformInterface.instance = FakeAudioplayersPlatform();
      GlobalAudioplayersPlatformInterface.instance =
          FakeGlobalAudioplayersPlatform();
      AudioCache.fileSystem = MemoryFileSystem.test();
    });

    test('creates instance', () async {
      final pool = await AudioPool.createFromAsset(
        path: 'audio.mp3',
        maxPlayers: 3,
        audioCache: FakeAudioCache(),
      );
      final stop = await pool.start();

      expect((pool.source as AssetSource).path, 'audio.mp3');
      expect(pool.audioCache.loadedFiles.keys.first, 'audio.mp3');
      stop();
      expect((pool.source as AssetSource).path, 'audio.mp3');
    });

    test('multiple players running', () async {
      final pool = await AudioPool.createFromAsset(
        path: 'audio.mp3',
        maxPlayers: 3,
        audioCache: FakeAudioCache(),
      );
      final stop1 = await pool.start();
      final stop2 = await pool.start();
      final stop3 = await pool.start();

      expect((pool.source as AssetSource).path, 'audio.mp3');
      expect(pool.audioCache.loadedFiles.keys.first, 'audio.mp3');
      expect(pool.availablePlayers.isEmpty, isTrue);
      expect(pool.currentPlayers.length, 3);

      await stop1();
      await stop2();
      await stop3();
      expect(pool.availablePlayers.length, 3);
      expect(pool.currentPlayers.isEmpty, isTrue);
    });

    test('keeps the minPlayers/maxPlayers contract', () async {
      final pool = await AudioPool.createFromAsset(
        path: 'audio.mp3',
        maxPlayers: 3,
        audioCache: FakeAudioCache(),
      );
      final stopFunctions =
          await Future.wait(List.generate(5, (_) => pool.start()));

      expect(pool.availablePlayers.isEmpty, isTrue);
      expect(pool.currentPlayers.length, 5);

      await stopFunctions[0]();
      await stopFunctions[1]();

      expect(pool.availablePlayers.length, 2);
      expect(pool.currentPlayers.length, 3);

      await stopFunctions[2]();
      await stopFunctions[3]();
      await stopFunctions[4]();

      expect(pool.availablePlayers.length, 3);
      expect(pool.currentPlayers.isEmpty, isTrue);
    });

    test('gets duration', () async {
      final pool = await AudioPool.createFromAsset(
        path: 'audio.mp3',
        maxPlayers: 3,
        audioCache: FakeAudioCache(),
      );
      final duration = await pool.getDuration();
      expect(duration, isA<Duration>());
    });

    test('getDuration adds an available player to the pool', () async {
      final pool = await AudioPool.createFromAsset(
        path: 'audio.mp3',
        maxPlayers: 3,
        audioCache: FakeAudioCache(),
      );

      final stop = await pool.start();
      await Future.wait([
        pool.getDuration(),
        stop(),
      ]);

      expect(pool.availablePlayers.length, 2);
      expect(pool.currentPlayers.isEmpty, isTrue);
    });

    test(
        'Consecutive getDuration returns from cache and does not create player',
        () async {
      final pool = await AudioPool.createFromAsset(
        path: 'audio.mp3',
        maxPlayers: 3,
        audioCache: FakeAudioCache(),
      );

      expect(pool.duration, isNull);

      final durations = await Future.wait([
        pool.getDuration(),
        pool.getDuration(),
      ]);

      final durationFromNewPlayer = durations[0];
      final durationFromCache = durations[1];

      expect(pool.duration, isNotNull);
      expect(durationFromNewPlayer, durationFromCache);

      expect(pool.availablePlayers.length, 1);
      expect(pool.currentPlayers.isEmpty, isTrue);
    });

    test('getDuration keeps the minPlayers/maxPlayers contract', () async {
      final pool = await AudioPool.createFromAsset(
        path: 'audio.mp3',
        maxPlayers: 3,
        audioCache: FakeAudioCache(),
      );

      final stopFunctions =
          await Future.wait(List.generate(3, (_) => pool.start()));

      await pool.getDuration();
      await Future.wait(stopFunctions.map((f) => f()));

      expect(pool.availablePlayers.length, 3);
      expect(pool.currentPlayers.isEmpty, isTrue);
    });
  });
}
