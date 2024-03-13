import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/src/uri_ext.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// This represents a single AudioPlayer, which can play one audio at a time.
/// To play several audios at the same time, you must create several instances
/// of this class.
///
/// It holds methods to play, loop, pause, stop, seek the audio, and some useful
/// hooks for handlers and callbacks.
class AudioPlayer {
  static final global = GlobalAudioScope();
  final _platform = AudioplayersPlatformInterface.instance;

  /// This is the [AudioCache] instance used by this player.
  /// Unless you want to control multiple caches separately, you don't need to
  /// change anything as the global instance will be used by default.
  AudioCache audioCache = AudioCache.instance;

  /// An unique ID generated for this instance of [AudioPlayer].
  ///
  /// This is used to properly exchange messages with the [MethodChannel].
  final String playerId;

  Source? _source;

  Source? get source => _source;

  double _volume = 1.0;

  double get volume => _volume;

  double _balance = 0.0;

  double get balance => _balance;

  double _playbackRate = 1.0;

  double get playbackRate => _playbackRate;

  /// Current mode of the audio player. Can be updated at any time, but is going
  /// to take effect only at the next time you play the audio.
  PlayerMode _mode = PlayerMode.mediaPlayer;

  PlayerMode get mode => _mode;

  ReleaseMode _releaseMode = ReleaseMode.release;

  ReleaseMode get releaseMode => _releaseMode;

  /// Auxiliary variable to re-check the volatile player state during async
  /// operations.
  @visibleForTesting
  PlayerState desiredState = PlayerState.stopped;

  PlayerState _playerState = PlayerState.stopped;

  PlayerState get state => _playerState;

  /// The current playback state.
  /// It is only set, when the corresponding action succeeds.
  set state(PlayerState state) {
    if (_playerState == PlayerState.disposed) {
      throw Exception('AudioPlayer has been disposed');
    }
    if (!_playerStateController.isClosed) {
      _playerStateController.add(state);
    }
    _playerState = desiredState = state;
  }

  PositionUpdater? _positionUpdater;

  /// Completer to wait until the native player and its event stream are
  /// created.
  @visibleForTesting
  final creatingCompleter = Completer<void>();

  late final StreamSubscription _onPlayerCompleteStreamSubscription;

  late final StreamSubscription _onLogStreamSubscription;

  /// Stream controller to be able to get a stream on initialization, before the
  /// native event stream is ready via [_create] method.
  final _eventStreamController = StreamController<AudioEvent>.broadcast();
  late final StreamSubscription _eventStreamSubscription;

  Stream<AudioEvent> get eventStream => _eventStreamController.stream;

  final StreamController<PlayerState> _playerStateController =
      StreamController<PlayerState>.broadcast();

  /// Stream of changes on player state.
  Stream<PlayerState> get onPlayerStateChanged => _playerStateController.stream;

  /// Stream of changes on audio position.
  ///
  /// Roughly fires every 200 milliseconds. Will continuously update the
  /// position of the playback if the status is [PlayerState.playing].
  ///
  /// You can use it on a progress bar, for instance.
  Stream<Duration> get onPositionChanged =>
      _positionUpdater?.positionStream ?? const Stream.empty();

  /// Stream of changes on audio duration.
  ///
  /// An event is going to be sent as soon as the audio duration is available
  /// (it might take a while to download or buffer it).
  Stream<Duration> get onDurationChanged => eventStream
      .where((event) => event.eventType == AudioEventType.duration)
      .map((event) => event.duration!);

  /// Stream of player completions.
  ///
  /// Events are sent every time an audio is finished, therefore no event is
  /// sent when an audio is paused or stopped.
  ///
  /// [ReleaseMode.loop] also sends events to this stream.
  Stream<void> get onPlayerComplete =>
      eventStream.where((event) => event.eventType == AudioEventType.complete);

  /// Stream of seek completions.
  ///
  /// An event is going to be sent as soon as the audio seek is finished.
  Stream<void> get onSeekComplete => eventStream
      .where((event) => event.eventType == AudioEventType.seekComplete);

  Stream<bool> get _onPrepared => eventStream
      .where((event) => event.eventType == AudioEventType.prepared)
      .map((event) => event.isPrepared!);

  /// Stream of log events.
  Stream<String> get onLog => eventStream
      .where((event) => event.eventType == AudioEventType.log)
      .map((event) => event.logMessage!);

  /// Creates a new instance and assigns an unique id to it.
  AudioPlayer({String? playerId}) : playerId = playerId ?? _uuid.v4() {
    _onLogStreamSubscription = onLog.listen(
      (log) => AudioLogger.log('$log\nSource: $_source'),
      onError: (Object e, [StackTrace? stackTrace]) => AudioLogger.error(
        AudioPlayerException(this, cause: e),
        stackTrace,
      ),
    );
    _onPlayerCompleteStreamSubscription = onPlayerComplete.listen(
      (_) async {
        state = PlayerState.completed;
        if (releaseMode == ReleaseMode.release) {
          _source = null;
        }
        await _positionUpdater?.stopAndUpdate();
      },
      onError: (Object _, [StackTrace? __]) {
        /* Errors are already handled via log stream */
      },
    );
    _create();
    positionUpdater = FramePositionUpdater(
      getPosition: getCurrentPosition,
    );
  }

  Future<void> _create() async {
    try {
      await _platform.create(playerId);
      // Assign the event stream, now that the platform registered this player.
      _eventStreamSubscription = _platform.getEventStream(playerId).listen(
            _eventStreamController.add,
            onError: _eventStreamController.addError,
          );
      creatingCompleter.complete();
    } on Exception catch (e, stackTrace) {
      creatingCompleter.completeError(e, stackTrace);
    }
  }

  /// Play an audio [source].
  ///
  /// To reduce preparation latency, instead consider calling [setSource]
  /// beforehand and then [resume] separately.
  Future<void> play(
    Source source, {
    double? volume,
    double? balance,
    AudioContext? ctx,
    Duration? position,
    PlayerMode? mode,
  }) async {
    desiredState = PlayerState.playing;

    if (mode != null) {
      await setPlayerMode(mode);
    }
    if (volume != null) {
      await setVolume(volume);
    }
    if (balance != null) {
      await setBalance(balance);
    }
    if (ctx != null) {
      await setAudioContext(ctx);
    }

    await setSource(source);
    if (position != null) {
      await seek(position);
    }

    await _resume();
  }

  Future<void> setAudioContext(AudioContext ctx) async {
    await creatingCompleter.future;
    return _platform.setAudioContext(playerId, ctx);
  }

  Future<void> setPlayerMode(PlayerMode mode) async {
    _mode = mode;
    await creatingCompleter.future;
    return _platform.setPlayerMode(playerId, mode);
  }

  /// Pauses the audio that is currently playing.
  ///
  /// If you call [resume] later, the audio will resume from the point that it
  /// has been paused.
  Future<void> pause() async {
    desiredState = PlayerState.paused;
    await creatingCompleter.future;
    if (desiredState == PlayerState.paused) {
      await _platform.pause(playerId);
      state = PlayerState.paused;
      await _positionUpdater?.stopAndUpdate();
    }
  }

  /// Stops the audio that is currently playing.
  ///
  /// The position is going to be reset and you will no longer be able to resume
  /// from the last point.
  Future<void> stop() async {
    desiredState = PlayerState.stopped;
    await creatingCompleter.future;
    if (desiredState == PlayerState.stopped) {
      await _platform.stop(playerId);
      state = PlayerState.stopped;
      await _positionUpdater?.stopAndUpdate();
    }
  }

  /// Resumes the audio that has been paused or stopped.
  Future<void> resume() async {
    desiredState = PlayerState.playing;
    await _resume();
  }

  /// Resume without setting the desired state.
  Future<void> _resume() async {
    await creatingCompleter.future;
    if (desiredState == PlayerState.playing) {
      await _platform.resume(playerId);
      state = PlayerState.playing;
      _positionUpdater?.start();
    }
  }

  /// Releases the resources associated with this media player.
  ///
  /// The resources are going to be fetched or buffered again as soon as you
  /// call [resume] or change the source.
  Future<void> release() async {
    await stop();
    await _platform.release(playerId);
    // Stop state already set in stop()
    _source = null;
  }

  /// Moves the cursor to the desired position.
  Future<void> seek(Duration position) async {
    await creatingCompleter.future;

    final futureSeekComplete =
        onSeekComplete.first.timeout(const Duration(seconds: 30));
    final futureSeek = _platform.seek(playerId, position);
    // Wait simultaneously to ensure all errors are propagated through the same
    // future.
    await Future.wait([futureSeek, futureSeekComplete]);

    await _positionUpdater?.update();
  }

  /// Sets the stereo balance.
  ///
  /// -1 - The left channel is at full volume; the right channel is silent.
  ///  1 - The right channel is at full volume; the left channel is silent.
  ///  0 - Both channels are at the same volume.
  Future<void> setBalance(double balance) async {
    _balance = balance;
    await creatingCompleter.future;
    return _platform.setBalance(playerId, balance);
  }

  /// Sets the volume (amplitude).
  ///
  /// 0 is mute and 1 is the max volume. The values between 0 and 1 are linearly
  /// interpolated.
  Future<void> setVolume(double volume) async {
    _volume = volume;
    await creatingCompleter.future;
    return _platform.setVolume(playerId, volume);
  }

  /// Sets the release mode.
  ///
  /// Check [ReleaseMode]'s doc to understand the difference between the modes.
  Future<void> setReleaseMode(ReleaseMode releaseMode) async {
    _releaseMode = releaseMode;
    await creatingCompleter.future;
    return _platform.setReleaseMode(playerId, releaseMode);
  }

  /// Sets the playback rate - call this after first calling play() or resume().
  ///
  /// iOS and macOS have limits between 0.5 and 2x
  /// Android SDK version should be 23 or higher
  Future<void> setPlaybackRate(double playbackRate) async {
    _playbackRate = playbackRate;
    await creatingCompleter.future;
    return _platform.setPlaybackRate(playerId, playbackRate);
  }

  /// Sets the audio source for this player.
  ///
  /// This will delegate to one of the specific methods below depending on
  /// the source type.
  Future<void> setSource(Source source) async {
    // Implementations of setOnPlayer also call `creatingCompleter.future`
    await source.setOnPlayer(this);
  }

  /// This method helps waiting for a source to be set until it's prepared.
  /// This can happen immediately after [setSource] has finished or it needs to
  /// wait for the [AudioEvent] [AudioEventType.prepared] to arrive.
  Future<void> _completePrepared(Future<void> Function() setSource) async {
    await creatingCompleter.future;

    final futurePrepared = _onPrepared
        .firstWhere((isPrepared) => isPrepared)
        .timeout(const Duration(seconds: 30));
    // Need to await the setting the source to propagate immediate errors.
    final futureSetSource = setSource();

    // Wait simultaneously to ensure all errors are propagated through the same
    // future.
    await Future.wait([futureSetSource, futurePrepared]);

    // Share position once after finished loading
    await _positionUpdater?.update();
  }

  /// Sets the URL to a remote link.
  ///
  /// The resources will start being fetched or buffered as soon as you call
  /// this method.
  Future<void> setSourceUrl(String url, {String? mimeType}) async {
    if (!kIsWeb &&
        defaultTargetPlatform != TargetPlatform.android &&
        url.startsWith('data:')) {
      // Convert data URI's to bytes (native support for web and android).
      final uriData = UriData.fromUri(Uri.parse(url));
      mimeType ??= url.substring(url.indexOf(':') + 1, url.indexOf(';'));
      await setSourceBytes(uriData.contentAsBytes(), mimeType: mimeType);
      return;
    }

    _source = UrlSource(url, mimeType: mimeType);
    // Encode remote url to avoid unexpected failures.
    await _completePrepared(
      () => _platform.setSourceUrl(
        playerId,
        UriCoder.encodeOnce(url),
        mimeType: mimeType,
        isLocal: false,
      ),
    );
  }

  /// Sets the URL to a file in the users device.
  ///
  /// The resources will start being fetched or buffered as soon as you call
  /// this method.
  Future<void> setSourceDeviceFile(String path, {String? mimeType}) async {
    _source = DeviceFileSource(path, mimeType: mimeType);
    await _completePrepared(
      () => _platform.setSourceUrl(
        playerId,
        path,
        isLocal: true,
        mimeType: mimeType,
      ),
    );
  }

  /// Sets the URL to an asset in your Flutter application.
  /// The global instance of AudioCache will be used by default.
  ///
  /// The resources will start being fetched or buffered as soon as you call
  /// this method.
  Future<void> setSourceAsset(String path, {String? mimeType}) async {
    _source = AssetSource(path, mimeType: mimeType);
    final cachePath = await audioCache.loadPath(path);
    await _completePrepared(
      () => _platform.setSourceUrl(
        playerId,
        cachePath,
        mimeType: mimeType,
        isLocal: true,
      ),
    );
  }

  Future<void> setSourceBytes(Uint8List bytes, {String? mimeType}) async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.linux)) {
      // Convert to file as workaround
      final tempDir = (await getTemporaryDirectory()).path;
      final bytesHash = Object.hashAll(bytes)
          .toUnsigned(20)
          .toRadixString(16)
          .padLeft(5, '0');
      final file = File('$tempDir/$bytesHash');
      await file.writeAsBytes(bytes);
      await setSourceDeviceFile(file.path, mimeType: mimeType);
    } else {
      _source = BytesSource(bytes, mimeType: mimeType);
      await _completePrepared(
        () => _platform.setSourceBytes(playerId, bytes, mimeType: mimeType),
      );
    }
  }

  /// Set the PositionUpdater to control how often the position stream will be
  /// updated. You can use the [FramePositionUpdater], the
  /// [TimerPositionUpdater] or write your own implementation of the
  /// [PositionUpdater].
  set positionUpdater(PositionUpdater? positionUpdater) {
    _positionUpdater?.dispose(); // No need to wait for dispose
    _positionUpdater = positionUpdater;
  }

  /// Get audio duration after setting url.
  /// Use it in conjunction with setUrl.
  ///
  /// It will be available as soon as the audio duration is available
  /// (it might take a while to download or buffer it if file is not local).
  Future<Duration?> getDuration() async {
    await creatingCompleter.future;
    final milliseconds = await _platform.getDuration(playerId);
    if (milliseconds == null) {
      return null;
    }
    return Duration(milliseconds: milliseconds);
  }

  // Gets audio current playing position
  Future<Duration?> getCurrentPosition() async {
    await creatingCompleter.future;
    final milliseconds = await _platform.getCurrentPosition(playerId);
    if (milliseconds == null) {
      return null;
    }
    return Duration(milliseconds: milliseconds);
  }

  /// Closes all [StreamController]s.
  ///
  /// You must call this method when your [AudioPlayer] instance is not going to
  /// be used anymore. If you try to use it after this you will get errors.
  Future<void> dispose() async {
    // First stop and release all native resources.
    await release();

    state = desiredState = PlayerState.disposed;

    final futures = <Future>[
      if (_positionUpdater != null) _positionUpdater!.dispose(),
      if (!_playerStateController.isClosed) _playerStateController.close(),
      _onPlayerCompleteStreamSubscription.cancel(),
      _onLogStreamSubscription.cancel(),
      _eventStreamSubscription.cancel(),
      _eventStreamController.close(),
    ];

    _source = null;

    await Future.wait<dynamic>(futures);

    // Needs to be called after cancelling event stream subscription:
    await _platform.dispose(playerId);
  }
}
