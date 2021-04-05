import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'audioplayers_notifications.dart';
import 'player_mode.dart';
import 'player_state.dart';
import 'playing_route.dart';
import 'release_mode.dart';

/// This represents a single AudioPlayer, which can play one audio at a time.
/// To play several audios at the same time, you must create several instances
/// of this class.
///
/// It holds methods to play, loop, pause, stop, seek the audio, and some useful
/// hooks for handlers and callbacks.
class AudioPlayer {
  static final MethodChannel _channel =
      const MethodChannel('xyz.luan/audioplayers')
        ..setMethodCallHandler(platformCallHandler);

  static final _uuid = Uuid();

  final StreamController<PlayerState> _playerStateController =
      StreamController<PlayerState>.broadcast();

  final StreamController<PlayerState> _notificationPlayerStateController =
      StreamController<PlayerState>.broadcast();

  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();

  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();

  final StreamController<void> _completionController =
      StreamController<void>.broadcast();

  final StreamController<bool> _seekCompleteController =
      StreamController<bool>.broadcast();

  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  final StreamController<PlayerControlCommand> _commandController =
      StreamController<PlayerControlCommand>.broadcast();

  PlayingRoute _playingRouteState = PlayingRoute.SPEAKERS;

  /// Reference [Map] with all the players created by the application.
  ///
  /// This is used to exchange messages with the [MethodChannel]
  /// (because there is only one channel for all players).
  static final players = Map<String, AudioPlayer>();

  /// Enables more verbose logging.
  ///
  /// TODO(luan): there are still some logs on the android native side that we
  /// should get rid of.
  static bool logEnabled = false;

  late NotificationService notificationService;

  PlayerState _playerState = PlayerState.STOPPED;

  PlayerState get state => _playerState;

  set state(PlayerState state) {
    _playerStateController.add(state);
    _playerState = state;
  }

  set playingRouteState(PlayingRoute routeState) {
    _playingRouteState = routeState;
  }

  // TODO(luan) why do we need two methods for setting state?
  set notificationState(PlayerState state) {
    _notificationPlayerStateController.add(state);
    _playerState = state;
  }

  /// Stream of changes on player state.
  Stream<PlayerState> get onPlayerStateChanged => _playerStateController.stream;

  /// Stream of changes on player state coming from notification area in iOS.
  Stream<PlayerState> get onNotificationPlayerStateChanged =>
      _notificationPlayerStateController.stream;

  /// Stream of changes on audio position.
  ///
  /// Roughly fires every 200 milliseconds. Will continuously update the
  /// position of the playback if the status is [PlayerState.PLAYING].
  ///
  /// You can use it on a progress bar, for instance.
  Stream<Duration> get onAudioPositionChanged => _positionController.stream;

  /// Stream of changes on audio duration.
  ///
  /// An event is going to be sent as soon as the audio duration is available
  /// (it might take a while to download or buffer it).
  Stream<Duration> get onDurationChanged => _durationController.stream;

  /// Stream of player completions.
  ///
  /// Events are sent every time an audio is finished, therefore no event is
  /// sent when an audio is paused or stopped.
  ///
  /// [ReleaseMode.LOOP] also sends events to this stream.
  Stream<void> get onPlayerCompletion => _completionController.stream;

  /// Stream of seek completions.
  ///
  /// An event is going to be sent as soon as the audio seek is finished.
  Stream<void> get onSeekComplete => _seekCompleteController.stream;

  /// Stream of player errors.
  ///
  /// Events are sent when an unexpected error is thrown in the native code.
  Stream<String> get onPlayerError => _errorController.stream;

  /// Stream of remote player command send by native side
  ///
  /// Events are sent user tap system remote control command.
  Stream<PlayerControlCommand> get onPlayerCommand => _commandController.stream;

  /// An unique ID generated for this instance of [AudioPlayer].
  ///
  /// This is used to properly exchange messages with the [MethodChannel].
  final String playerId;

  /// Current mode of the audio player. Can be updated at any time, but is going
  /// to take effect only at the next time you play the audio.
  final PlayerMode mode;

  /// Creates a new instance and assigns an unique id to it.
  AudioPlayer({this.mode = PlayerMode.MEDIA_PLAYER, String? playerId})
      : this.playerId = playerId ?? _uuid.v4() {
    players[this.playerId] = this;
    notificationService = NotificationService(_invokeMethod);
  }

  Future<int> _invokeMethod(
    String method, [
    Map<String, dynamic> arguments = const {},
  ]) {
    final Map<String, dynamic> withPlayerId = Map.of(arguments)
      ..['playerId'] = playerId
      ..['mode'] = mode.toString();

    return _channel
        .invokeMethod(method, withPlayerId)
        .then((result) => (result as int));
  }

  /// Plays an audio.
  ///
  /// If [isLocal] is true, [url] must be a local file system path.
  /// If [isLocal] is false, [url] must be a remote URL.
  ///
  /// respectSilence and stayAwake are not implemented on macOS.
  Future<int> play(
    String url, {
    bool? isLocal,
    double volume = 1.0,
    // position must be null by default to be compatible with radio streams
    Duration? position,
    bool respectSilence = false,
    bool stayAwake = false,
    bool duckAudio = false,
    bool recordingActive = false,
  }) async {
    isLocal ??= isLocalUrl(url);

    final int result = await _invokeMethod('play', {
      'url': url,
      'isLocal': isLocal,
      'volume': volume,
      'position': position?.inMilliseconds,
      'respectSilence': respectSilence,
      'stayAwake': stayAwake,
      'duckAudio': duckAudio,
      'recordingActive': recordingActive,
    });

    if (result == 1) {
      state = PlayerState.PLAYING;
    }

    return result;
  }

  /// Plays audio in the form of a byte array.
  ///
  /// This is only supported on Android (SDK >= 23) currently.
  Future<int> playBytes(
    Uint8List bytes, {
    double volume = 1.0,
    // position must be null by default to be compatible with radio streams
    Duration? position,
    bool respectSilence = false,
    bool stayAwake = false,
    bool duckAudio = false,
    bool recordingActive = false,
  }) async {
    if (!Platform.isAndroid) {
      throw PlatformException(
        code: 'Not supported',
        message: 'Only Android is currently supported',
      );
    }

    final int result = await _invokeMethod('playBytes', {
      'bytes': bytes,
      'volume': volume,
      'position': position?.inMilliseconds,
      'respectSilence': respectSilence,
      'stayAwake': stayAwake,
      'duckAudio': duckAudio,
      'recordingActive': recordingActive,
    });

    if (result == 1) {
      state = PlayerState.PLAYING;
    }

    return result;
  }

  /// Pauses the audio that is currently playing.
  ///
  /// If you call [resume] later, the audio will resume from the point that it
  /// has been paused.
  Future<int> pause() async {
    final result = await _invokeMethod('pause');

    if (result == 1) {
      state = PlayerState.PAUSED;
    }

    return result;
  }

  /// Stops the audio that is currently playing.
  ///
  /// The position is going to be reset and you will no longer be able to resume
  /// from the last point.
  Future<int> stop() async {
    final result = await _invokeMethod('stop');

    if (result == 1) {
      state = PlayerState.STOPPED;
    }

    return result;
  }

  /// Resumes the audio that has been paused or stopped, just like calling
  /// [play], but without changing the parameters.
  Future<int> resume() async {
    final result = await _invokeMethod('resume');

    if (result == 1) {
      state = PlayerState.PLAYING;
    }

    return result;
  }

  /// Releases the resources associated with this media player.
  ///
  /// The resources are going to be fetched or buffered again as soon as you
  /// call [play] or [setUrl].
  Future<int> release() async {
    final result = await _invokeMethod('release');

    if (result == 1) {
      state = PlayerState.STOPPED;
    }

    return result;
  }

  /// Moves the cursor to the desired position.
  Future<int> seek(Duration position) {
    _positionController.add(position);
    return _invokeMethod('seek', {'position': position.inMilliseconds});
  }

  /// Sets the volume (amplitude).
  ///
  /// 0 is mute and 1 is the max volume. The values between 0 and 1 are linearly
  /// interpolated.
  Future<int> setVolume(double volume) {
    return _invokeMethod('setVolume', {'volume': volume});
  }

  /// Sets the release mode.
  ///
  /// Check [ReleaseMode]'s doc to understand the difference between the modes.
  Future<int> setReleaseMode(ReleaseMode releaseMode) {
    return _invokeMethod(
      'setReleaseMode',
      {'releaseMode': releaseMode.toString()},
    );
  }

  /// Sets the playback rate - call this after first calling play() or resume().
  ///
  /// iOS and macOS have limits between 0.5 and 2x
  /// Android SDK version should be 23 or higher.
  /// not sure if that's changed recently.
  Future<int> setPlaybackRate({double playbackRate = 1.0}) {
    return _invokeMethod('setPlaybackRate', {'playbackRate': playbackRate});
  }

  /// Sets the URL.
  ///
  /// Unlike [play], the playback will not resume.
  ///
  /// The resources will start being fetched or buffered as soon as you call
  /// this method.
  ///
  /// respectSilence is not implemented on macOS.
  Future<int> setUrl(
    String url, {
    bool isLocal: false,
    bool respectSilence = false,
  }) {
    isLocal = isLocalUrl(url);
    return _invokeMethod(
      'setUrl',
      {'url': url, 'isLocal': isLocal, 'respectSilence': respectSilence},
    );
  }

  /// Get audio duration after setting url.
  /// Use it in conjunction with setUrl.
  ///
  /// It will be available as soon as the audio duration is available
  /// (it might take a while to download or buffer it if file is not local).
  Future<int> getDuration() {
    return _invokeMethod('getDuration');
  }

  // Gets audio current playing position
  Future<int> getCurrentPosition() async {
    return _invokeMethod('getCurrentPosition');
  }

  static Future<void> platformCallHandler(MethodCall call) async {
    try {
      _doHandlePlatformCall(call);
    } catch (ex) {
      _log('Unexpected error: $ex');
    }
  }

  static Future<void> _doHandlePlatformCall(MethodCall call) async {
    final Map<dynamic, dynamic> callArgs = call.arguments as Map;
    _log('_platformCallHandler call ${call.method} $callArgs');

    final playerId = callArgs['playerId'] as String;
    final AudioPlayer? player = players[playerId];

    if (!kReleaseMode && Platform.isAndroid && player == null) {
      final oldPlayer = AudioPlayer(playerId: playerId);
      await oldPlayer.release();
      oldPlayer.dispose();
      players.remove(playerId);
      return;
    }
    if (player == null) return;

    final value = callArgs['value'];

    switch (call.method) {
      case 'audio.onNotificationPlayerStateChanged':
        final bool isPlaying = value;
        player.notificationState =
            isPlaying ? PlayerState.PLAYING : PlayerState.PAUSED;
        break;
      case 'audio.onDuration':
        Duration newDuration = Duration(milliseconds: value);
        player._durationController.add(newDuration);
        break;
      case 'audio.onCurrentPosition':
        Duration newDuration = Duration(milliseconds: value);
        player._positionController.add(newDuration);
        break;
      case 'audio.onComplete':
        player.state = PlayerState.COMPLETED;
        player._completionController.add(null);
        break;
      case 'audio.onSeekComplete':
        player._seekCompleteController.add(value);
        break;
      case 'audio.onError':
        player.state = PlayerState.STOPPED;
        player._errorController.add(value);
        break;
      case 'audio.onGotNextTrackCommand':
        player._commandController.add(PlayerControlCommand.NEXT_TRACK);
        break;
      case 'audio.onGotPreviousTrackCommand':
        player._commandController.add(PlayerControlCommand.PREVIOUS_TRACK);
        break;
      default:
        _log('Unknown method ${call.method} ');
    }
  }

  static void _log(String param) {
    if (logEnabled) {
      print(param);
    }
  }

  /// Closes all [StreamController]s.
  ///
  /// You must call this method when your [AudioPlayer] instance is not going to
  /// be used anymore. If you try to use it after this you will get errors.
  Future<void> dispose() async {
    // First stop and release all native resources.
    await this.release();

    List<Future> futures = [];

    if (!_playerStateController.isClosed)
      futures.add(_playerStateController.close());
    if (!_notificationPlayerStateController.isClosed)
      futures.add(_notificationPlayerStateController.close());
    if (!_positionController.isClosed) futures.add(_positionController.close());
    if (!_durationController.isClosed) futures.add(_durationController.close());
    if (!_completionController.isClosed)
      futures.add(_completionController.close());
    if (!_seekCompleteController.isClosed)
      futures.add(_seekCompleteController.close());
    if (!_errorController.isClosed) futures.add(_errorController.close());
    if (!_commandController.isClosed) futures.add(_commandController.close());

    await Future.wait(futures);
    players.remove(playerId);
  }

  Future<int> earpieceOrSpeakersToggle() async {
    final playingRoute = _playingRouteState.toggle();
    final result = await _invokeMethod(
      'earpieceOrSpeakersToggle',
      {'playingRoute': playingRoute.name()},
    );

    if (result == 1) {
      playingRouteState = playingRoute;
    }

    return result;
  }

  bool isLocalUrl(String url) {
    return url.startsWith("/") ||
        url.startsWith("file://") ||
        url.substring(1).startsWith(':\\');
  }
}
