import 'dart:async';
import 'dart:html';

import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:audioplayers_web/num_extension.dart';
import 'package:audioplayers_web/web_audio_js.dart';

class WrappedPlayer {
  final String playerId;
  final eventStreamController = StreamController<PlayerEvent>.broadcast();

  double? _pausedAt;
  double _currentVolume = 1.0;
  double _currentPlaybackRate = 1.0;
  ReleaseMode _currentReleaseMode = ReleaseMode.release;
  String? _currentUrl;
  bool _isPlaying = false;

  AudioElement? player;
  StereoPannerNode? _stereoPanner;
  StreamSubscription? _playerTimeUpdateSubscription;
  StreamSubscription? _playerEndedSubscription;
  StreamSubscription? _playerLoadedDataSubscription;
  StreamSubscription? _playerPlaySubscription;
  StreamSubscription? _playerSeekedSubscription;

  WrappedPlayer(this.playerId);

  Future<void> setUrl(String url) async {
    if (_currentUrl == url) {
      return; // nothing to do
    }
    _currentUrl = url;

    stop();
    recreateNode();
    if (_isPlaying) {
      await resume();
    }
  }

  void setVolume(double volume) {
    _currentVolume = volume;
    player?.volume = volume;
  }

  void setBalance(double balance) {
    _stereoPanner?.pan.value = balance;
  }

  void setPlaybackRate(double rate) {
    _currentPlaybackRate = rate;
    player?.playbackRate = rate;
  }

  void recreateNode() {
    if (_currentUrl == null) {
      return;
    }

    final p = player = AudioElement(_currentUrl);
    // As the AudioElement is created dynamically via script,
    // features like 'stereo panning' need the CORS header to be enabled.
    // See: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
    p.crossOrigin = 'anonymous';
    p.loop = shouldLoop();
    p.volume = _currentVolume;
    p.playbackRate = _currentPlaybackRate;

    // setup stereo panning
    final audioContext = JsAudioContext();
    final source = audioContext.createMediaElementSource(player!);
    _stereoPanner = audioContext.createStereoPanner();
    source.connect(_stereoPanner!);
    _stereoPanner?.connect(audioContext.destination);

    _playerPlaySubscription = p.onPlay.listen(
      (_) {
        eventStreamController.add(
          PlayerEvent(
            eventType: PlayerEventType.duration,
            duration: p.duration.fromSecondsToDuration(),
          ),
        );
      },
      onError: eventStreamController.addError,
    );
    _playerLoadedDataSubscription = p.onLoadedData.listen(
      (_) {
        eventStreamController.add(
          PlayerEvent(
            eventType: PlayerEventType.duration,
            duration: p.duration.fromSecondsToDuration(),
          ),
        );
      },
      onError: eventStreamController.addError,
    );
    _playerTimeUpdateSubscription = p.onTimeUpdate.listen(
      (_) {
        eventStreamController.add(
          PlayerEvent(
            eventType: PlayerEventType.position,
            duration: p.currentTime.fromSecondsToDuration(),
          ),
        );
      },
      onError: eventStreamController.addError,
    );
    _playerSeekedSubscription = p.onSeeked.listen(
      (_) {
        eventStreamController.add(
          const PlayerEvent(eventType: PlayerEventType.seekComplete),
        );
      },
      onError: eventStreamController.addError,
    );
    _playerEndedSubscription = p.onEnded.listen(
      (_) {
        _pausedAt = 0;
        player?.currentTime = 0;
        eventStreamController.add(
          const PlayerEvent(eventType: PlayerEventType.complete),
        );
      },
      onError: eventStreamController.addError,
    );
  }

  bool shouldLoop() => _currentReleaseMode == ReleaseMode.loop;

  void setReleaseMode(ReleaseMode releaseMode) {
    _currentReleaseMode = releaseMode;
    player?.loop = shouldLoop();
  }

  void release() {
    _cancel();
    player = null;
    _stereoPanner = null;

    _playerLoadedDataSubscription?.cancel();
    _playerLoadedDataSubscription = null;
    _playerTimeUpdateSubscription?.cancel();
    _playerTimeUpdateSubscription = null;
    _playerEndedSubscription?.cancel();
    _playerEndedSubscription = null;
    _playerSeekedSubscription?.cancel();
    _playerSeekedSubscription = null;
    _playerPlaySubscription?.cancel();
    _playerPlaySubscription = null;
  }

  Future<void> start(double position) async {
    _isPlaying = true;
    if (_currentUrl == null) {
      return; // nothing to play yet
    }
    if (player == null) {
      recreateNode();
    }
    await player?.play();
    player?.currentTime = position;
  }

  Future<void> resume() async {
    await start(_pausedAt ?? 0);
  }

  void pause() {
    _pausedAt = player?.currentTime as double?;
    _isPlaying = false;
    player?.pause();
  }

  void stop() {
    _cancel();
    _pausedAt = 0;
    player?.currentTime = 0;
  }

  void seek(int position) {
    final seekPosition = position / 1000.0;
    player?.currentTime = seekPosition;

    if (!_isPlaying) {
      _pausedAt = seekPosition;
    }
  }

  void _cancel() {
    _isPlaying = false;
    player?.pause();
    if (_currentReleaseMode == ReleaseMode.release) {
      player = null;
    }
  }

  void log(String message) {
    eventStreamController.add(
      PlayerEvent(eventType: PlayerEventType.log, logMessage: message),
    );
  }

  Future<void> dispose() async {
    eventStreamController.close();
  }
}
