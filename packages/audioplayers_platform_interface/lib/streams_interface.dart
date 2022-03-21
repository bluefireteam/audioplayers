import 'dart:async';

import 'package:flutter/foundation.dart';

import 'api/for_player.dart';
import 'api/player_state.dart';

mixin StreamsInterface {
  void emitSeekComplete(String playerId) {
    _seekCompleteStreamController.add(ForPlayer(playerId, null));
  }

  void emitComplete(String playerId) {
    _completeStreamController.add(ForPlayer(playerId, null));
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

  Stream<ForPlayer<void>> get seekCompleteStream =>
      _seekCompleteStreamController.stream;

  Stream<ForPlayer<void>> get completeStream =>
      _completeStreamController.stream;

  Stream<ForPlayer<Duration>> get durationStream =>
      _durationStreamController.stream;

  Stream<ForPlayer<PlayerState>> get playerStateStream =>
      _playerStateStreamController.stream;

  Stream<ForPlayer<Duration>> get positionStream =>
      _positionStreamController.stream;

  final StreamController<ForPlayer<void>> _seekCompleteStreamController =
      StreamController<ForPlayer<void>>.broadcast();

  final StreamController<ForPlayer<void>> _completeStreamController =
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
    _completeStreamController.close();
    _durationStreamController.close();
    _playerStateStreamController.close();
    _positionStreamController.close();
  }
}
