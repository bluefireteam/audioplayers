import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

typedef void TimeChangeHandler(Duration duration);
typedef void ErrorHandler(String message);
typedef void PausedHandler();

class AudioPlayer {
  static final MethodChannel _channel = const MethodChannel('bz.rxla.flutter/audio')..setMethodCallHandler(platformCallHandler);
  static final uuid = new Uuid();
  static final players = new Map<String, AudioPlayer>();
  static var logEnabled = false;

  TimeChangeHandler durationHandler;
  TimeChangeHandler positionHandler;
  VoidCallback completionHandler;
  ErrorHandler errorHandler;
  PausedHandler pausedHandler;

  String playerId;

  AudioPlayer() {
    playerId = uuid.v4();
    players[playerId] = this;
  }

  Future<int> play(String url, {bool isLocal: false, double volume: 1.0}) =>
      _channel.invokeMethod('play', {"playerId": playerId, "url": url, "isLocal": isLocal, 'volume': volume});

  Future<int> pause() => _channel.invokeMethod('pause', {"playerId": playerId});

  Future<int> stop() => _channel.invokeMethod('stop', {"playerId": playerId});

  Future<int> seek(double seconds) => _channel.invokeMethod('seek', {"playerId": playerId, "position": seconds});

  void setDurationHandler(TimeChangeHandler handler) {
    durationHandler = handler;
  }

  void setPositionHandler(TimeChangeHandler handler) {
    positionHandler = handler;
  }

  void setCompletionHandler(VoidCallback callback) {
    completionHandler = callback;
  }

  void setErrorHandler(ErrorHandler handler) {
    errorHandler = handler;
  }

  void setPausedHandler(PausedHandler handler) {
      pausedHandler = handler;
  }

  static void log(String param) {
    if (logEnabled) {
      print(param);
    }
  }

  static Future platformCallHandler(MethodCall call) async {
    log("_platformCallHandler call ${call.method} ${call.arguments}");
    String playerId = (call.arguments as Map)['playerId'];
    AudioPlayer player = players[playerId];
    dynamic value = (call.arguments as Map)['value'];
    switch (call.method) {
      case "audio.onDuration":
        if (player.durationHandler != null) {
          player.durationHandler(new Duration(milliseconds: value));
        }
        break;
      case "audio.onCurrentPosition":
        if (player.positionHandler != null) {
          player.positionHandler(new Duration(milliseconds: value));
        }
        break;
      case "audio.onComplete":
        if (player.completionHandler != null) {
          player.completionHandler();
        }
        break;
        case "audio.onPaused":
            if (player.pausedHandler != null) {
                player.pausedHandler();
            }
            break;
      case "audio.onError":
        if (player.errorHandler != null) {
          player.errorHandler(value);
        }
        break;
      default:
        log('Unknowm method ${call.method} ');
    }
  }
}
