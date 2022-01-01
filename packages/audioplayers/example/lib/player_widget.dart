import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PlayerWidget extends StatefulWidget {
  final String url;
  final PlayerMode mode;

  const PlayerWidget({
    Key? key,
    required this.url,
    this.mode = PlayerMode.mediaPlayer,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState(url, mode);
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  String url;
  PlayerMode mode;

  late AudioPlayer _audioPlayer;
  PlayerState? _audioPlayerState;
  Duration? _duration;
  Duration? _position;

  PlayerState _playerState = PlayerState.stopped;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerErrorSubscription;
  StreamSubscription? _playerStateSubscription;

  bool get _isPlaying => _playerState == PlayerState.playing;
  bool get _isPaused => _playerState == PlayerState.paused;
  String get _durationText => _duration?.toString().split('.').first ?? '';
  String get _positionText => _position?.toString().split('.').first ?? '';

  _PlayerWidgetState(this.url, this.mode);

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: const Key('play_button'),
              onPressed: _isPlaying ? null : _play,
              iconSize: 64.0,
              icon: const Icon(Icons.play_arrow),
              color: Colors.cyan,
            ),
            IconButton(
              key: const Key('pause_button'),
              onPressed: _isPlaying ? _pause : null,
              iconSize: 64.0,
              icon: const Icon(Icons.pause),
              color: Colors.cyan,
            ),
            IconButton(
              key: const Key('stop_button'),
              onPressed: _isPlaying || _isPaused ? _stop : null,
              iconSize: 64.0,
              icon: const Icon(Icons.stop),
              color: Colors.cyan,
            ),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Stack(
                children: [
                  Slider(
                    onChanged: (v) {
                      final duration = _duration;
                      if (duration == null) {
                        return;
                      }
                      final Position = v * duration.inMilliseconds;
                      _audioPlayer
                          .seek(Duration(milliseconds: Position.round()));
                    },
                    value: (_position != null &&
                            _duration != null &&
                            _position!.inMilliseconds > 0 &&
                            _position!.inMilliseconds <
                                _duration!.inMilliseconds)
                        ? _position!.inMilliseconds / _duration!.inMilliseconds
                        : 0.0,
                  ),
                ],
              ),
            ),
            Text(
              _position != null
                  ? '$_positionText / $_durationText'
                  : _duration != null
                      ? _durationText
                      : '',
              style: const TextStyle(fontSize: 24.0),
            ),
          ],
        ),
        Text('State: $_audioPlayerState'),
      ],
    );
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer(mode: mode);

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen(
      (p) => setState(() => _position = p),
    );

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() {
        _position = _duration;
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _audioPlayerState = state;
        });
      }
    });
  }

  Future<int> _play() async {
    final playPosition = (_position != null &&
            _duration != null &&
            _position!.inMilliseconds > 0 &&
            _position!.inMilliseconds < _duration!.inMilliseconds)
        ? _position
        : null;
    final result = await _audioPlayer.play(url, position: playPosition);
    if (result == 1) {
      setState(() => _playerState = PlayerState.playing);
    }

    return result;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) {
      setState(() => _playerState = PlayerState.paused);
    }
    return result;
  }

  Future<int> _stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = const Duration();
      });
    }
    return result;
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);
  }
}
