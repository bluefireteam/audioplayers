import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_audioplayers_platform.dart';
import 'fake_global_audioplayers_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final globalPlatform = FakeGlobalAudioplayersPlatform();
  GlobalAudioplayersPlatformInterface.instance = globalPlatform;

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
      // "stop" isn't called, if already in stopped state.
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

      // ignore: deprecated_member_use
      await player.setPlayerMode(PlayerMode.lowLatency);
      // ignore: deprecated_member_use
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
        const AudioEvent(eventType: AudioEventType.complete),
        const AudioEvent(eventType: AudioEventType.seekComplete),
      ];

      final expected = expectLater(
        player.eventStream,
        emitsInOrder([
          ...audioEvents,
          // Playing state is emitted via stop after complete.
          const AudioEvent(
            eventType: AudioEventType.playingStateUpdate,
            isPlaying: false,
          ),
        ]),
      );

      audioEvents.forEach(platform.eventStreamControllers['p1']!.add);
      await expected;

      await platform.eventStreamControllers['p1']!.close();
    });
  });

  /// Tests in this group control every step on their own: native events are
  /// only emitted, native calls only return and position updates only finish
  /// when the test says so. [pumpEventQueue] lets the Dart side process
  /// everything up to the next step. This makes the order of events and their
  /// processing the same on every run, without depending on any timings.
  group('AudioPlayer playing state', () {
    late _StepAudioplayersPlatform platform;
    late _StepPositionUpdater positionUpdater;
    late AudioPlayer player;

    const pausedEvent = AudioEvent(
      eventType: AudioEventType.playingStateUpdate,
      isPlaying: false,
    );
    const playingEvent = AudioEvent(
      eventType: AudioEventType.playingStateUpdate,
      isPlaying: true,
    );
    const completeEvent = AudioEvent(eventType: AudioEventType.complete);

    void emit(AudioEvent event) =>
        platform.eventStreamControllers['p1']!.add(event);

    setUp(() async {
      platform = _StepAudioplayersPlatform();
      AudioplayersPlatformInterface.instance = platform;
      player = AudioPlayer(playerId: 'p1');
      await player.creatingCompleter.future;
      positionUpdater = _StepPositionUpdater();
      player.positionUpdater = positionUpdater;

      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(UrlSource('internet.com/file.mp3'));
      expect(player.state, PlayerState.playing);
      expect(player.desiredState, PlayerState.playing);
      platform.clear();
      positionUpdater.hold();
    });

    tearDown(() async {
      // Do not leave any step pending, e.g. when a test failed.
      positionUpdater.release();
      platform.pendingStop?.complete();
      await pumpEventQueue();
    });

    /// Calls [AudioPlayer.stop] and runs until the native stop was called,
    /// which is held until [_StepAudioplayersPlatform.finishStop].
    Future<bool Function()> startStop() async {
      var isStopped = false;
      player.stop().then((_) => isStopped = true);
      await pumpEventQueue();
      expect(platform.popLastCall().method, 'stop');
      expect(isStopped, isFalse);
      expect(player.desiredState, PlayerState.stopped);
      expect(player.state, PlayerState.playing);
      return () => isStopped;
    }

    /// Emits the event of the native stop and lets the native call return.
    Future<void> finishStop(bool Function() isStopped) async {
      emit(pausedEvent);
      platform.finishStop();
      await pumpEventQueue();
      positionUpdater.release();
      await pumpEventQueue();

      expect(isStopped(), isTrue, reason: 'stop() did not complete');
      expect(player.desiredState, PlayerState.stopped);
      expect(player.state, PlayerState.stopped);
    }

    test('system pause and play in quick succession keeps playing', () async {
      // The play event arrives while the pause is still being processed.
      emit(pausedEvent);
      await pumpEventQueue();
      expect(positionUpdater.pendingUpdates, 1);
      expect(player.state, PlayerState.paused);
      expect(player.desiredState, PlayerState.paused);

      emit(playingEvent);
      await pumpEventQueue();
      positionUpdater.release();
      await pumpEventQueue();

      expect(player.desiredState, PlayerState.playing);
      expect(player.state, PlayerState.playing);
      expect(platform.calls, isEmpty);
    });

    test('#stop completes when a loop restart is reported before the stop',
        () async {
      final isStopped = await startStop();

      // The loop end, which is still processed when the restart arrives.
      emit(pausedEvent);
      await pumpEventQueue();
      expect(positionUpdater.pendingUpdates, 1);
      expect(player.state, PlayerState.stopped);

      // The restart of the loop, which was emitted before the stop.
      emit(playingEvent);
      await pumpEventQueue();
      expect(player.state, PlayerState.playing);
      expect(
        player.desiredState,
        PlayerState.stopped,
        reason: 'the late restart must not override the requested stop',
      );

      await finishStop(isStopped);
    });

    test('#stop completes when the loop end is reported before the pause',
        () async {
      final isStopped = await startStop();

      emit(completeEvent);
      await pumpEventQueue();
      expect(player.state, PlayerState.playing);
      expect(
        player.desiredState,
        PlayerState.stopped,
        reason: 'the late completion must not override the requested stop',
      );

      await finishStop(isStopped);
    });

    test('#stop completes when the loop ends right before the stop', () async {
      final isStopped = await startStop();

      // The pause of the loop end, which is still processed when the
      // completion arrives.
      emit(pausedEvent);
      await pumpEventQueue();
      expect(positionUpdater.pendingUpdates, 1);
      expect(player.state, PlayerState.stopped);

      emit(completeEvent);
      await pumpEventQueue();
      expect(
        player.desiredState,
        PlayerState.stopped,
        reason: 'the late completion must not override the requested stop',
      );

      platform.finishStop();
      positionUpdater.release();
      await pumpEventQueue();

      expect(isStopped(), isTrue, reason: 'stop() did not complete');
      expect(player.desiredState, PlayerState.stopped);
      expect(player.state, PlayerState.stopped);
    });

    test('loop completion without a pending request is still reported',
        () async {
      emit(completeEvent);
      await pumpEventQueue();
      expect(player.state, PlayerState.completed);
      expect(player.desiredState, PlayerState.completed);
      // A looping player is not stopped natively.
      expect(platform.calls, isEmpty);
    });
  });
}

/// Holds every native stop call until [finishStop] is called and does not
/// emit any events on its own, so the test decides when they arrive.
class _StepAudioplayersPlatform extends FakeAudioplayersPlatform {
  Completer<void>? pendingStop;

  @override
  Future<void> stop(String playerId) {
    calls.add(FakeCall(id: playerId, method: 'stop'));
    return (pendingStop = Completer<void>()).future;
  }

  void finishStop() {
    pendingStop!.complete();
    pendingStop = null;
  }
}

/// Holds every position update between [hold] and [release]. A player event
/// listener waits for the position update before completing a requested state
/// update, which keeps the listener suspended at this point.
class _StepPositionUpdater extends PositionUpdater {
  final _pending = <Completer<Duration?>>[];
  var _isHeld = false;

  _StepPositionUpdater() : super(getPosition: _noPosition);

  static Future<Duration?> _noPosition() async => null;

  int get pendingUpdates => _pending.length;

  @override
  Future<void> update() {
    if (!_isHeld) {
      return Future.value();
    }
    final completer = Completer<Duration?>();
    _pending.add(completer);
    return completer.future;
  }

  /// Holds all following position updates.
  void hold() => _isHeld = true;

  /// Finishes all pending and following position updates.
  void release() {
    _isHeld = false;
    for (final completer in _pending) {
      completer.complete();
    }
    _pending.clear();
  }

  @override
  void start() {}

  @override
  void stop() {}
}
