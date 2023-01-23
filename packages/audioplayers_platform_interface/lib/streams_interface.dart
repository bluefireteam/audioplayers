import 'dart:async';

import 'package:audioplayers_platform_interface/api/for_player.dart';
import 'package:flutter/foundation.dart';

mixin StreamsInterface {
  void emitSeekComplete(String playerId) {
    _seekCompleteStreamController.add(ForPlayer(playerId, null));
  }

  void emitComplete(String playerId) {
    _completeStreamController.add(ForPlayer(playerId, null));
  }

  void emitDuration(String playerId, Duration value) {
    _durationStreamController.add(ForPlayer(playerId, value));
  }

  void emitPosition(String playerId, Duration value) {
    _positionStreamController.add(ForPlayer(playerId, value));
  }

  void emitLog(String playerId, String value) {
    _logStreamController.add(ForPlayer(playerId, value));
  }

  void emitGlobalLog(String value) {
    _globalLogStreamController.add(value);
  }

  void emitError(String playerId, Object value) {
    _logStreamController.addError(ForPlayer(playerId, value));
  }

  void emitGlobalError(Object value) {
    _globalLogStreamController.addError(value);
  }

  Stream<ForPlayer<void>> get seekCompleteStream =>
      _seekCompleteStreamController.stream;

  Stream<ForPlayer<void>> get completeStream =>
      _completeStreamController.stream;

  Stream<ForPlayer<Duration>> get durationStream =>
      _durationStreamController.stream;

  Stream<ForPlayer<Duration>> get positionStream =>
      _positionStreamController.stream;

  Stream<ForPlayer<String>> get logStream => _logStreamController.stream;

  Stream<String> get globalLogStream => _globalLogStreamController.stream;

  final StreamController<ForPlayer<void>> _seekCompleteStreamController =
      StreamController<ForPlayer<void>>.broadcast();

  final StreamController<ForPlayer<void>> _completeStreamController =
      StreamController<ForPlayer<void>>.broadcast();

  final StreamController<ForPlayer<Duration>> _durationStreamController =
      StreamController<ForPlayer<Duration>>.broadcast();

  final StreamController<ForPlayer<Duration>> _positionStreamController =
      StreamController<ForPlayer<Duration>>.broadcast();

  final StreamController<ForPlayer<String>> _logStreamController =
      StreamController<ForPlayer<String>>.broadcast();

  final StreamController<String> _globalLogStreamController =
      StreamController<String>.broadcast();

  @mustCallSuper
  Future<void> dispose() async {
    _seekCompleteStreamController.close();
    _completeStreamController.close();
    _durationStreamController.close();
    _positionStreamController.close();
    _logStreamController.close();
    _globalLogStreamController.close();
  }
}
