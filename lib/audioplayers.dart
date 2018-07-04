import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

typedef void TimeChangeHandler(Duration duration);
typedef void ErrorHandler(String message);

/// This represents a single AudioPlayer, that can play one audio at a time (per instance).
/// 
/// It features methods to play, loop, pause, stop, seek the audio, and some useful hooks for handlers and callbacks.
class AudioPlayer {

  static final MethodChannel _channel = const MethodChannel('xyz.luan/audioplayers')..setMethodCallHandler(platformCallHandler);

  static final _uuid = new Uuid();

  /// This is a reference map with all the players created by the application.
  /// 
  /// This is used to route messages to and from the channel (there is only one channel).
  static final players = new Map<String, AudioPlayer>();

  /// This enables more verbose logging, if desired.
  static bool logEnabled = false;

  /// This handler returns the duration of the file, when it's available (it might take a while because it's being downloaded or buffered).
  TimeChangeHandler durationHandler;

  /// This handler updates the current position of the audio. You can use it to make a progress bar, for instance.
  TimeChangeHandler positionHandler;

  /// This handler is called when the audio finishes playing; it's used in the loop method, for instance.
  /// 
  /// It does not fire when you interrupt the audio with pause or stop.
  VoidCallback completionHandler;

  /// This is called when an unexpected error is thrown in the native code.
  ErrorHandler errorHandler;

  /// This is a unique ID generated for this instance of audioplayer.
  /// 
  /// It's used to route messages via the single channel properly.
  String playerId;

  /// Creates a new instance and assigns it with a new random unique id.
  AudioPlayer() {
    playerId = _uuid.v4();
    players[playerId] = this;
  }

  Future<int> _invokeMethod(String method, [Map<String, dynamic> arguments = const {}]) {
    Map<String, dynamic> withPlayerId = Map.of(arguments);
    withPlayerId['playerId'] = playerId;
    return _channel.invokeMethod(method, withPlayerId).then((result) => (result as int));
  }

  /// Play audio on a loop.
  /// 
  /// It will actually set a Completion Handler to replay your audio (so don't forget to clear it if you use the same player for something else!).
  Future<int> loop(String url, {bool isLocal: false, double volume: 1.0}) {
    completionHandler = () => play(url, isLocal: isLocal, volume: volume);
    return play(url, isLocal: true);
  }

  /// Play audio. Url can be a remote url (isLocal = false) or a local file system path (isLocal = true).
  Future<int> play(String url, {bool isLocal: false, double volume: 1.0}) {
    return _invokeMethod('play', {
      'url': url,
      'isLocal': isLocal,
      'volume': volume
    });
  }

  /// Pause the currently playing audio (resumes from this point).
  Future<int> pause() => _invokeMethod('pause');

  /// Stop the currently playing audio (resumes from the beginning).
  Future<int> stop() => _invokeMethod('stop');

  /// Move the cursor to the desired position.
  Future<int> seek(Duration position) {
    double positionInSeconds = position.inMicroseconds / Duration.microsecondsPerSecond;
    return _invokeMethod('seek', {'position': positionInSeconds});
  }

  static void _log(String param) {
    if (logEnabled) {
      print(param);
    }
  }

  static Future platformCallHandler(MethodCall call) async {
    _log('_platformCallHandler call ${call.method} ${call.arguments}');
    String playerId = (call.arguments as Map)['playerId'];
    AudioPlayer player = players[playerId];
    dynamic value = (call.arguments as Map)['value'];
    switch (call.method) {
      case 'audio.onDuration':
        if (player.durationHandler != null) {
          await player.durationHandler(new Duration(milliseconds: value));
        }
        break;
      case 'audio.onCurrentPosition':
        if (player.positionHandler != null) {
          await player.positionHandler(new Duration(milliseconds: value));
        }
        break;
      case 'audio.onComplete':
        if (player.completionHandler != null) {
          await player.completionHandler();
        }
        break;
      case 'audio.onError':
        if (player.errorHandler != null) {
          await player.errorHandler(value);
        }
        break;
      default:
        _log('Unknowm method ${call.method} ');
    }
  }
}
