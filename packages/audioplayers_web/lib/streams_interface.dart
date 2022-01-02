import 'dart:async';

import 'package:audioplayers_platform_interface/api/for_player.dart';
import 'package:audioplayers_platform_interface/api/player_state.dart';
import 'package:flutter/foundation.dart';

mixin StreamsInterface {
  void emitSeekComplete(String playerId, bool value) {
    _seekCompleteStreamController.add(ForPlayer(playerId, value));
  }

  void emitCompletion(String playerId) {
    _completionStreamController.add(ForPlayer(playerId, null));
  }

  void emitPlayerState(String playerId, PlayerState value) {
    _playerStateStreamController.add(ForPlayer(playerId, value));
  }

  void emitDuration(String playerId, Duration value) {
    _durationStreamController.add(ForPlayer(playerId, value));
  }

  void emitPosition(String playerId, Duration value) {
    _positionStreamController.add(ForPlayer(playerId, value));
  }

  Stream<ForPlayer<bool>> get seekCompleteStream =>
      _seekCompleteStreamController.stream;

  Stream<ForPlayer<void>> get completionStream =>
      _completionStreamController.stream;

  Stream<ForPlayer<Duration>> get durationStream =>
      _durationStreamController.stream;

  Stream<ForPlayer<PlayerState>> get playerStateStream =>
      _playerStateStreamController.stream;

  Stream<ForPlayer<Duration>> get positionStream =>
      _positionStreamController.stream;

  final StreamController<ForPlayer<bool>> _seekCompleteStreamController =
      StreamController<ForPlayer<bool>>.broadcast();

  final StreamController<ForPlayer<void>> _completionStreamController =
      StreamController<ForPlayer<void>>.broadcast();

  final StreamController<ForPlayer<Duration>> _durationStreamController =
      StreamController<ForPlayer<Duration>>.broadcast();

  final StreamController<ForPlayer<PlayerState>> _playerStateStreamController =
      StreamController<ForPlayer<PlayerState>>.broadcast();

  final StreamController<ForPlayer<Duration>> _positionStreamController =
      StreamController<ForPlayer<Duration>>.broadcast();

  @mustCallSuper
  Future<void> dispose() async {
    _seekCompleteStreamController.close();
    _completionStreamController.close();
    _durationStreamController.close();
    _playerStateStreamController.close();
    _positionStreamController.close();
  }
}
