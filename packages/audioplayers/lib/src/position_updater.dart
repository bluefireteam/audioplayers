import 'dart:async';

import 'package:flutter/scheduler.dart';

abstract class PositionUpdater {
  /// You can use `player.getCurrentPosition` as the [getPosition] parameter.
  PositionUpdater({
    required this.getPosition,
  });

  final Future<Duration?> Function() getPosition;
  final _streamController = StreamController<Duration>.broadcast();

  Stream<Duration> get positionStream => _streamController.stream;

  Future<void> update() async {
    final position = await getPosition();
    if (position != null) {
      _streamController.add(position);
    }
  }

  void start();

  void stop();

  Future<void> stopAndUpdate() async {
    stop();
    await update();
  }

  Future<void> dispose() async {
    stop();
    await _streamController.close();
  }
}

class TimerPositionUpdater extends PositionUpdater {
  Timer? _positionStreamTimer;
  final Duration interval;

  /// Position stream will be updated in the according [interval].
  TimerPositionUpdater({
    required super.getPosition,
    required this.interval,
  });

  @override
  void start() {
    _positionStreamTimer?.cancel();
    _positionStreamTimer = Timer.periodic(interval, (timer) async {
      await update();
    });
  }

  @override
  void stop() {
    _positionStreamTimer?.cancel();
    _positionStreamTimer = null;
  }
}

class FramePositionUpdater extends PositionUpdater {
  int? _frameCallbackId;
  bool _isRunning = false;

  /// Position stream will be updated at every new frame.
  FramePositionUpdater({
    required super.getPosition,
  });

  void _tick(Duration? timestamp) {
    if (_isRunning) {
      update();
      _frameCallbackId = SchedulerBinding.instance.scheduleFrameCallback(_tick);
    }
  }

  @override
  void start() {
    _isRunning = true;
    _tick(null);
  }

  @override
  void stop() {
    _isRunning = false;
    if (_frameCallbackId != null) {
      SchedulerBinding.instance.cancelFrameCallbackWithId(_frameCallbackId!);
    }
  }
}
