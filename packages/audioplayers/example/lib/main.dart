import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/components/tabs.dart';
import 'package:audioplayers_example/components/tgl.dart';
import 'package:audioplayers_example/tabs/audio_context.dart';
import 'package:audioplayers_example/tabs/controls.dart';
import 'package:audioplayers_example/tabs/logger.dart';
import 'package:audioplayers_example/tabs/sources.dart';
import 'package:audioplayers_example/tabs/streams.dart';
import 'package:audioplayers_example/utils.dart';
import 'package:flutter/material.dart';

typedef OnError = void Function(Exception exception);

void main() {
  runApp(const MaterialApp(home: ExampleApp()));
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  _ExampleAppState createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  List<AudioPlayerState> playerStates = List.generate(
    4,
    (_) => AudioPlayerState(AudioPlayer()..setReleaseMode(ReleaseMode.stop)),
  );
  int selectedPlayerIdx = 0;

  AudioPlayerState get selectedPlayerState => playerStates[selectedPlayerIdx];
  List<StreamSubscription> streams = [];

  @override
  void initState() {
    super.initState();
    playerStates.asMap().forEach((index, playerState) {
      streams.add(
        playerState.player.onPlayerStateChanged.listen(
          (it) {
            switch (it) {
              case PlayerState.stopped:
                toast(
                  'Player stopped!',
                  textKey: Key('toast-player-stopped-$index'),
                );
                break;
              case PlayerState.completed:
                toast(
                  'Player complete!',
                  textKey: Key('toast-player-complete-$index'),
                );
                break;
              default:
                break;
            }
          },
        ),
      );
      streams.add(
        playerState.player.onSeekComplete.listen(
          (it) => toast(
            'Seek complete!',
            textKey: Key('toast-seek-complete-$index'),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    streams.forEach((it) => it.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('audioplayers example'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Tgl(
                key: const Key('playerTgl'),
                options: ['P1', 'P2', 'P3', 'P4']
                    .asMap()
                    .map((key, value) => MapEntry('player-$key', value)),
                selected: selectedPlayerIdx,
                onChange: (v) => setState(() => selectedPlayerIdx = v),
              ),
            ),
          ),
          Expanded(
            child: Tabs(
              tabs: [
                TabData(
                  key: 'sourcesTab',
                  label: 'Src',
                  content: SourcesTab(
                    key: selectedPlayerState.sourcesKey,
                    playerState: selectedPlayerState,
                  ),
                ),
                TabData(
                  key: 'controlsTab',
                  label: 'Ctrl',
                  content: ControlsTab(
                    key: selectedPlayerState.controlsKey,
                    player: selectedPlayerState.player,
                  ),
                ),
                TabData(
                  key: 'streamsTab',
                  label: 'Stream',
                  content: StreamsTab(
                    key: selectedPlayerState.streamsKey,
                    player: selectedPlayerState.player,
                  ),
                ),
                TabData(
                  key: 'audioContextTab',
                  label: 'Ctx',
                  content: AudioContextTab(
                    key: selectedPlayerState.contextKey,
                    playerState: selectedPlayerState,
                  ),
                ),
                TabData(
                  key: 'loggerTab',
                  label: 'Log',
                  content: LoggerTab(
                    key: selectedPlayerState.loggerKey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A helper class to save the UI state of the individual players.
/// Note that not every property is saved here, such as stream values,
/// which in most cases can be initialized with player values.
class AudioPlayerState {
  final AudioPlayer player;

  AudioPlayerState(this.player);

  // Needed to force recreating tabs, if player has changed, but keep tab state.
  final sourcesKey = GlobalKey();
  final controlsKey = GlobalKey();
  final streamsKey = GlobalKey();
  final contextKey = GlobalKey();
  final loggerKey = GlobalKey();

  InitMode initMode = InitMode.setSource;

  /// Set config for all platforms
  AudioContextConfig audioContextConfig = AudioContextConfig();

  /// Set config for each platform individually
  AudioContext audioContext = const AudioContext();
}
