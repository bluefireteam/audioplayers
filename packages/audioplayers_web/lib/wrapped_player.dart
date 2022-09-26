import 'dart:async';
import 'dart:html';

import 'package:audioplayers_platform_interface/api/release_mode.dart';
import 'package:audioplayers_platform_interface/streams_interface.dart';

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
    throw UnimplementedError('setBalance is not currently implemented on Web');
  }

  void setPlaybackRate(double rate) {
    currentPlaybackRate = rate;
    player?.playbackRate = rate;
  }

  void recreateNode() {
    if (currentUrl == null) {
      return;
    }
    Duration toDuration(num jsNum) => Duration(
          milliseconds:
              (1000 * (jsNum.isNaN || jsNum.isInfinite ? 0 : jsNum)).round(),
        );

    final p = player = AudioElement(currentUrl);
    p.loop = shouldLoop();
    p.volume = currentVolume;
    p.playbackRate = currentPlaybackRate;
    playerPlaySubscription = p.onPlay.listen((_) {
      streamsInterface.emitDuration(playerId, toDuration(p.duration));
    });
    playerLoadedDataSubscription = p.onLoadedData.listen((_) {
      streamsInterface.emitDuration(playerId, toDuration(p.duration));
    });
    playerTimeUpdateSubscription = p.onTimeUpdate.listen((_) {
      streamsInterface.emitPosition(playerId, toDuration(p.currentTime));
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

  void start(double position) {
    isPlaying = true;
    if (currentUrl == null) {
      return; // nothing to play yet
    }
    if (player == null) {
      recreateNode();
    }
    player?.play();
    player?.currentTime = position;
  }

  void resume() {
    start(pausedAt ?? 0);
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
