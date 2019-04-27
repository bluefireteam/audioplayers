import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

typedef StreamController CreateStreamController();
typedef void TimeChangeHandler(Duration duration);
typedef void ErrorHandler(String message);
typedef void AudioPlayerStateChangeHandler(AudioPlayerState state);

/// This enum contains the options that can happen after the playback finishes or the [stop] method is called.
///
/// Pass it as a parameter to [setReleaseMode] method.
enum ReleaseMode {
  /// This will release all resources when finished or stopped, just like if [release] was called.
  ///
  /// On Android, the MediaPlayer is quite resource-intensive, and this will let it go. Data will be buffered again when needed (if it's a remote file, it will be downloaded again).
  /// On iOS, works just like STOP.
  /// This is the default option.
  RELEASE,

  /// This not only keeps the data buffered, but keeps playing on loop after completion.
  ///
  /// When [stop] is called, it will not start again (obviously), but won't release either.
  LOOP,

  /// This will just stop the playback but keep all resources intact.
  ///
  /// Use it if you intend on playing again later.
  STOP
}

enum AudioPlayerState {
  STOPPED,
  PLAYING,
  PAUSED,
  COMPLETED,
}

// This enum contains the options for the player mode.
// Right now, both modes have the same backend implementation on iOS.
enum PlayerMode {
  // Use this mode for long media files or streams.
  MEDIA_PLAYER,
  // Use this mode for shorter audio files to reduce impacts on visuals or UI performance.
  // In this mode the backend won't fire any duration or position updates.
  // Also, it is not possible to use the seek method to set the audio a specific position.
  LOW_LATENCY
}

/// This represents a single AudioPlayer, that can play one audio at a time (per instance).
///
/// It features methods to play, loop, pause, stop, seek the audio, and some useful hooks for handlers and callbacks.
class AudioPlayer {
  static final MethodChannel _channel =
      const MethodChannel('xyz.luan/audioplayers')
        ..setMethodCallHandler(platformCallHandler);

  static final _uuid = new Uuid();

  final StreamController<AudioPlayerState> _playerStateController =
      createPlayerStateController();

  final StreamController<Duration> _positionController = 
      createPositionController();

  final StreamController<Duration> _durationController = 
      createDurationController();

  final StreamController<void> _completionController =
      createCompletionController();

  final StreamController<String> _errorController = 
      createErrorController();

  /// Use the variables below to provide your own [StreamController] to [AudioPlayer]. Useful to
  /// send data to the [Stream]s without really calling the native code (Android/iOS), which gives
  /// you the possibility of mocking this class.
  ///
  /// Usage example:
  ///
  /// ``` dart
  /// var myPlayerStateController = StreamController<AudioPlayerState>.broadcast();
  /// AudioPlayer.createPlayerStateController = () => myPlayerStateController;
  ///
  /// var audioPlayer = AudioPlayerMock();
  /// myPlayerStateController.add(AudioPlayerState.PLAYING);
  /// ```
  ///
  /// WARNING: You must set these variables BEFORE instantiating [AudioPlayer], since the
  /// [StreamController]s are created and assigned only once (at instantiation).

  static CreateStreamController createPlayerStateController =
      () => StreamController<AudioPlayerState>.broadcast();

  static CreateStreamController createPositionController =
      () => StreamController<Duration>.broadcast();

  static CreateStreamController createDurationController =
      () => StreamController<Duration>.broadcast();

  static CreateStreamController createCompletionController =
      () => StreamController<void>.broadcast();

  static CreateStreamController createErrorController = 
      () => StreamController<String>.broadcast();

  /// This is a reference map with all the players created by the application.
  ///
  /// This is used to route messages to and from the channel (there is only one channel).
  static final players = new Map<String, AudioPlayer>();

  /// This enables more verbose logging, if desired.
  static bool logEnabled = false;

  AudioPlayerState _audioPlayerState;

  AudioPlayerState get state => _audioPlayerState;

  set state(AudioPlayerState state) {
    _playerStateController.add(state);
    audioPlayerStateChangeHandler // ignore: deprecated_member_use_from_same_package
        ?.call(state);
    _audioPlayerState = state;
  }

  /// Stream for subscribing to player state change events.
  Stream<AudioPlayerState> get onPlayerStateChanged =>
      _playerStateController.stream;

  /// Stream for subscribing to audio position change events. Roughly fires
  /// every 200 milliseconds. Will continuously update the position of the
  /// playback if the status is [AudioPlayerState.PLAYING].
  Stream<Duration> get onAudioPositionChanged => _positionController.stream;

  /// This handler returns the duration of the file, when it's available (it might take a while because it's being downloaded or buffered).
  Stream<Duration> get onDurationChanged => _durationController.stream;

  @deprecated
  TimeChangeHandler durationHandler;

  @deprecated

  /// This handler updates the current position of the audio. You can use it to make a progress bar, for instance.
  TimeChangeHandler positionHandler;

  @deprecated
  AudioPlayerStateChangeHandler audioPlayerStateChangeHandler;

  /// This handler is called when the audio finishes playing; it's used in the loop method, for instance.
  ///
  /// It does not fire when you interrupt the audio with pause or stop.
  Stream<void> get onPlayerCompletion => _completionController.stream;
  @deprecated
  VoidCallback completionHandler;

  /// This is called when an unexpected error is thrown in the native code.
  Stream<String> get onPlayerError => _errorController.stream;
  @deprecated
  ErrorHandler errorHandler;

  /// This is a unique ID generated for this instance of audioplayer.
  ///
  /// It's used to route messages via the single channel properly.
  String playerId;

  // This is the player mode.
  PlayerMode mode;

  /// Creates a new instance and assigns it with a new random unique id.
  AudioPlayer({this.mode = PlayerMode.MEDIA_PLAYER}) {
    playerId = _uuid.v4();
    players[playerId] = this;
  }

  Future<int> _invokeMethod(String method,
      [Map<String, dynamic> arguments = const {}]) {
    Map<String, dynamic> withPlayerId = Map.of(arguments);
    withPlayerId['playerId'] = playerId;
    withPlayerId['mode'] = mode.toString();
    return _channel
        .invokeMethod(method, withPlayerId)
        .then((result) => (result as int));
  }

  /// Plays audio. Url can be a remote url (isLocal = false) or a local file system path (isLocal = true).
  Future<int> play(
    String url, {
    bool isLocal: false,
    double volume: 1.0,
    Duration position:
        null, // Must be null by default to be compatible with radio streams
    bool respectSilence: false,
  }) async {
    final int positionInMilliseconds = position?.inMilliseconds;
    int result = await _invokeMethod('play', {
      'url': url,
      'isLocal': isLocal,
      'volume': volume,
      'position': positionInMilliseconds,
      'respectSilence': respectSilence,
    });

    if (result == 1) {
      state = AudioPlayerState.PLAYING;
    }

    return result;
  }

  /// Pauses the currently playing audio (resumes from this point).
  Future<int> pause() async {
    int result = await _invokeMethod('pause');
    if (result == 1) {
      state = AudioPlayerState.PAUSED;
    }
    return result;
  }

  /// Stops the currently playing audio (resumes from the beginning).
  Future<int> stop() async {
    int result = await _invokeMethod('stop');
    if (result == 1) {
      state = AudioPlayerState.STOPPED;
    }
    return result;
  }

  /// Resumes the currently paused or stopped audio (like calling play but without changing the parameters).
  Future<int> resume() async {
    int result = await _invokeMethod('resume');
    if (result == 1) {
      state = AudioPlayerState.PLAYING;
    }
    return result;
  }

  /// Releases the resources associated with this media player.
  ///
  /// It will be prepared again if needed.
  Future<int> release() async {
    int result = await _invokeMethod('release');
    if (result == 1) {
      state = AudioPlayerState.STOPPED;
    }
    return result;
  }

  /// Moves the cursor to the desired position.
  Future<int> seek(Duration position) {
    return _invokeMethod('seek', {'position': position.inMilliseconds});
  }

  /// Sets the volume (amplitude). 0.0 is mute and 1.0 is max, the rest is linear interpolation.
  Future<int> setVolume(double volume) {
    return _invokeMethod('setVolume', {'volume': volume});
  }

  /// This configures the behavior when the playback finishes or the stop command is issued.
  ///
  /// STOP mode is the simplest, nothing happens (just stops).
  /// RELEASE mode is the default, it releases all resources on Android (like calling release method). On iOS there is no such concept.
  /// LOOP will start playing again forever, without releasing.
  Future<int> setReleaseMode(ReleaseMode releaseMode) {
    return _invokeMethod(
        'setReleaseMode', {'releaseMode': releaseMode.toString()});
  }

  /// Changes the url (source), without resuming playback (like play would do).
  ///
  /// This will keep the resource prepared (on Android) for when resume is called.
  Future<int> setUrl(String url, {bool isLocal: false}) {
    return _invokeMethod('setUrl', {'url': url, 'isLocal': isLocal});
  }

  static void _log(String param) {
    if (logEnabled) {
      print(param);
    }
  }

  static Future<void> platformCallHandler(MethodCall call) async {
    _log('_platformCallHandler call ${call.method} ${call.arguments}');
    String playerId = (call.arguments as Map)['playerId'] as String;
    AudioPlayer player = players[playerId];
    dynamic value = (call.arguments as Map)['value'];
    switch (call.method) {
      case 'audio.onDuration':
        Duration newDuration = new Duration(milliseconds: value);
        player._durationController.add(newDuration);
        player
            .durationHandler // ignore: deprecated_member_use_from_same_package
            ?.call(newDuration);
        break;
      case 'audio.onCurrentPosition':
        Duration newDuration = new Duration(milliseconds: value);
        player._positionController.add(newDuration);
        player
            .positionHandler // ignore: deprecated_member_use_from_same_package
            ?.call(newDuration);
        break;
      case 'audio.onComplete':
        player.state = AudioPlayerState.COMPLETED;
        player._completionController.add(null);
        player
            .completionHandler // ignore: deprecated_member_use_from_same_package
            ?.call();
        break;
      case 'audio.onError':
        player.state = AudioPlayerState.STOPPED;
        player._errorController.add(value);
        player.errorHandler // ignore: deprecated_member_use_from_same_package
            ?.call(value);
        break;
      default:
        _log('Unknown method ${call.method} ');
    }
  }
}
