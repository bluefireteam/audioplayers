import 'dart:async';
import 'dart:html';

import 'package:audioplayers_platform_interface/api/release_mode.dart';
import 'package:audioplayers_platform_interface/streams_interface.dart';
import 'package:audioplayers_web/num_extension.dart';
import 'package:audioplayers_web/web_audio_js.dart';

class WrappedPlayer {
  final String playerId;
  final StreamsInterface streamsInterface;

  double? pausedAt;
  double currentVolume = 1.0;
  double currentPlaybackRate = 1.0;
  ReleaseMode currentReleaseMode = ReleaseMode.release;
  String? currentUrl;
  bool isPlaying = false;

  AudioElement? player;
  StereoPannerNode? stereoPanner;
  StreamSubscription? playerTimeUpdateSubscription;
  StreamSubscription? playerEndedSubscription;
  StreamSubscription? playerLoadedDataSubscription;
  StreamSubscription? playerPlaySubscription;
  StreamSubscription? playerSeekedSubscription;

  WrappedPlayer(this.playerId, this.streamsInterface);

  void setUrl(String url) {
    if (currentUrl == url) {
      return; // nothing to do
    }
    currentUrl = url;

    stop();
    recreateNode();
    if (isPlaying) {
      resume();
    }
  }

  void setVolume(double volume) {
    currentVolume = volume;
    player?.volume = volume;
  }

  void setBalance(double balance) {
    stereoPanner?.pan.value = balance;
  }

  void setPlaybackRate(double rate) {
    currentPlaybackRate = rate;
    player?.playbackRate = rate;
  }

  void recreateNode() {
    if (currentUrl == null) {
      return;
    }

    final p = player = AudioElement(currentUrl);
    // As the AudioElement is created dynamically via script,
    // features like 'stereo panning' need the CORS header to be enabled.
    // See: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
    p.crossOrigin = 'anonymous';
    p.loop = shouldLoop();
    p.volume = currentVolume;
    p.playbackRate = currentPlaybackRate;

    // setup stereo panning
    final audioContext = JsAudioContext();
    final source = audioContext.createMediaElementSource(player!);
    stereoPanner = audioContext.createStereoPanner();
    source.connect(stereoPanner!);
    stereoPanner?.connect(audioContext.destination);

    playerPlaySubscription = p.onPlay.listen((_) {
      streamsInterface.emitDuration(
        playerId,
        p.duration.fromSecondsToDuration(),
      );
    });
    playerLoadedDataSubscription = p.onLoadedData.listen((_) {
      streamsInterface.emitDuration(
        playerId,
        p.duration.fromSecondsToDuration(),
      );
    });
    playerTimeUpdateSubscription = p.onTimeUpdate.listen((_) {
      streamsInterface.emitPosition(
        playerId,
        p.currentTime.fromSecondsToDuration(),
      );
    });
    playerSeekedSubscription = p.onSeeked.listen((_) {
      streamsInterface.emitSeekComplete(playerId);
    });
    playerEndedSubscription = p.onEnded.listen((_) {
      pausedAt = 0;
      player?.currentTime = 0;
      streamsInterface.emitComplete(playerId);
    });
  }

  bool shouldLoop() => currentReleaseMode == ReleaseMode.loop;

  void setReleaseMode(ReleaseMode releaseMode) {
    currentReleaseMode = releaseMode;
    player?.loop = shouldLoop();
  }

  void release() {
    _cancel();
    player = null;
    stereoPanner = null;

    playerLoadedDataSubscription?.cancel();
    playerLoadedDataSubscription = null;
    playerTimeUpdateSubscription?.cancel();
    playerTimeUpdateSubscription = null;
    playerEndedSubscription?.cancel();
    playerEndedSubscription = null;
    playerSeekedSubscription?.cancel();
    playerSeekedSubscription = null;
    playerPlaySubscription?.cancel();
    playerPlaySubscription = null;
  }

  Future<void> start(double position) async {
    isPlaying = true;
    if (currentUrl == null) {
      return; // nothing to play yet
    }
    if (player == null) {
      recreateNode();
    }
    await player?.play();
    player?.currentTime = position;
  }

  Future<void> resume() async {
    await start(pausedAt ?? 0);
  }

  void pause() {
    pausedAt = player?.currentTime as double?;
    isPlaying = false;
    player?.pause();
  }

  void stop() {
    _cancel();
    pausedAt = 0;
    player?.currentTime = 0;
  }

  void seek(int position) {
    final seekPosition = position / 1000.0;
    player?.currentTime = seekPosition;

    if (!isPlaying) {
      pausedAt = seekPosition;
    }
  }

  void _cancel() {
    isPlaying = false;
    player?.pause();
    if (currentReleaseMode == ReleaseMode.release) {
      player = null;
    }
  }
}
