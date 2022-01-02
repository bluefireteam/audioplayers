import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers_platform_interface/api/audio_context_config.dart';
import 'package:audioplayers_platform_interface/api/for_player.dart';
import 'package:audioplayers_platform_interface/api/player_mode.dart';
import 'package:audioplayers_platform_interface/api/player_state.dart';
import 'package:audioplayers_platform_interface/api/release_mode.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// This represents a single AudioPlayer, which can play one audio at a time.
/// To play several audios at the same time, you must create several instances
/// of this class.
///
/// It holds methods to play, loop, pause, stop, seek the audio, and some useful
/// hooks for handlers and callbacks.
class AudioPlayer {
  static final _platform = AudioplayersPlatform.instance;

  PlayerState _playerState = PlayerState.stopped;

  PlayerState get state => _playerState;

  set state(PlayerState state) {
    _playerStateController.add(state);
    _playerState = state;
  }

  final StreamController<PlayerState> _playerStateController =
      StreamController<PlayerState>.broadcast();

  /// Stream of changes on player state.
  Stream<PlayerState> get onPlayerStateChanged => _playerStateController.stream;

  /// Stream of changes on audio position.
  ///
  /// Roughly fires every 200 milliseconds. Will continuously update the
  /// position of the playback if the status is [PlayerState.playing].
  ///
  /// You can use it on a progress bar, for instance.
  Stream<Duration> get onPositionChanged =>
      _platform.positionStream.filter(playerId);

  /// Stream of changes on audio duration.
  ///
  /// An event is going to be sent as soon as the audio duration is available
  /// (it might take a while to download or buffer it).
  Stream<Duration> get onDurationChanged =>
      _platform.durationStream.filter(playerId);

  /// Stream of player completions.
  ///
  /// Events are sent every time an audio is finished, therefore no event is
  /// sent when an audio is paused or stopped.
  ///
  /// [ReleaseMode.loop] also sends events to this stream.
  Stream<void> get onPlayerComplete =>
      _platform.completeStream.filter(playerId);

  /// Stream of seek completions.
  ///
  /// An event is going to be sent as soon as the audio seek is finished.
  Stream<void> get onSeekComplete =>
      _platform.seekCompleteStream.filter(playerId);

  /// An unique ID generated for this instance of [AudioPlayer].
  ///
  /// This is used to properly exchange messages with the [MethodChannel].
  final String playerId;

  /// Current mode of the audio player. Can be updated at any time, but is going
  /// to take effect only at the next time you play the audio.
  final PlayerMode mode;

  /// Creates a new instance and assigns an unique id to it.
  AudioPlayer({this.mode = PlayerMode.mediaPlayer, String? playerId})
      : playerId = playerId ?? _uuid.v4();

  Future<void> play(
    String url, {
    bool? isLocal,
    double? volume,
    AudioContextConfig? config,
    Duration? position,
  }) async {
    if (volume != null) {
      await setVolume(volume);
    }
    if (config != null) {
      await setAudioContextConfig(config);
    }
    if (position != null) {
      await seek(position);
    }
    await setSourceUrl(url, isLocal: isLocal);
    return resume();
  }

  /// Plays audio in the form of a byte array.
  ///
  /// This is only supported on Android (SDK >= 23) currently.
  Future<void> playBytes(
    Uint8List bytes, {
    double? volume,
    AudioContextConfig? config,
  }) async {
    if (volume != null) {
      await setVolume(volume);
    }
    if (config != null) {
      await setAudioContextConfig(config);
    }
    await setSourceBytes(bytes);
    return resume();
  }

  Future<void> setAudioContextConfig(AudioContextConfig config) {
    return _platform.setAudioContextConfig(playerId, config);
  }

  /// Pauses the audio that is currently playing.
  ///
  /// If you call [resume] later, the audio will resume from the point that it
  /// has been paused.
  Future<void> pause() async {
    await _platform.pause(playerId);
    state = PlayerState.paused;
  }

  /// Stops the audio that is currently playing.
  ///
  /// The position is going to be reset and you will no longer be able to resume
  /// from the last point.
  Future<void> stop() async {
    await _platform.stop(playerId);
    state = PlayerState.stopped;
  }

  /// Resumes the audio that has been paused or stopped, just like calling
  /// [play], but without changing the parameters.
  Future<void> resume() async {
    await _platform.resume(playerId);
    state = PlayerState.playing;
  }

  /// Releases the resources associated with this media player.
  ///
  /// The resources are going to be fetched or buffered again as soon as you
  /// call [play] or [setSourceUrl].
  Future<void> release() async {
    await _platform.release(playerId);
    state = PlayerState.stopped;
  }

  /// Moves the cursor to the desired position.
  Future<void> seek(Duration position) {
    return _platform.seek(playerId, position);
  }

  /// Sets the volume (amplitude).
  ///
  /// 0 is mute and 1 is the max volume. The values between 0 and 1 are linearly
  /// interpolated.
  Future<void> setVolume(double volume) {
    return _platform.setVolume(playerId, volume);
  }

  /// Sets the release mode.
  ///
  /// Check [ReleaseMode]'s doc to understand the difference between the modes.
  Future<void> setReleaseMode(ReleaseMode releaseMode) {
    return _platform.setReleaseMode(playerId, releaseMode);
  }

  /// Sets the playback rate - call this after first calling play() or resume().
  ///
  /// iOS and macOS have limits between 0.5 and 2x
  /// Android SDK version should be 23 or higher
  Future<void> setPlaybackRate(double playbackRate) {
    return _platform.setPlaybackRate(playerId, playbackRate);
  }

  /// Sets the URL.
  ///
  /// Unlike [play], the playback will not resume.
  ///
  /// The resources will start being fetched or buffered as soon as you call
  /// this method.
  ///
  /// respectSilence is not implemented on macOS.
  Future<void> setSourceUrl(
    String url, {
    bool? isLocal,
  }) {
    return _platform.setSourceUrl(playerId, url, isLocal: isLocal);
  }

  Future<void> setSourceBytes(
    Uint8List bytes,
  ) {
    return _platform.setSourceBytes(playerId, bytes);
  }

  /// Get audio duration after setting url.
  /// Use it in conjunction with setUrl.
  ///
  /// It will be available as soon as the audio duration is available
  /// (it might take a while to download or buffer it if file is not local).
  Future<int?> getDuration() {
    return _platform.getDuration(playerId);
  }

  // Gets audio current playing position
  Future<int?> getCurrentPosition() async {
    return _platform.getCurrentPosition(playerId);
  }

  /// Closes all [StreamController]s.
  ///
  /// You must call this method when your [AudioPlayer] instance is not going to
  /// be used anymore. If you try to use it after this you will get errors.
  Future<void> dispose() async {
    // First stop and release all native resources.
    await release();

    final futures = <Future>[];
    if (!_playerStateController.isClosed) {
      futures.add(_playerStateController.close());
    }
    await Future.wait<dynamic>(futures);
  }

  bool isLocalUrl(String url) {
    return url.startsWith('/') ||
        url.startsWith('file://') ||
        url.substring(1).startsWith(':\\');
  }
}
