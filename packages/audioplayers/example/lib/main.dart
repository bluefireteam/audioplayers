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

const playerCount = 4;

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
  List<AudioPlayer> audioPlayers = List.generate(
    playerCount,
    (_) => AudioPlayer()..setReleaseMode(ReleaseMode.stop),
  );
  int selectedPlayerIdx = 0;

  AudioPlayer get selectedAudioPlayer => audioPlayers[selectedPlayerIdx];
  List<StreamSubscription> streams = [];

  @override
  void initState() {
    super.initState();
    audioPlayers.asMap().forEach((index, player) {
      streams.add(
        player.onPlayerStateChanged.listen(
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
        player.onSeekComplete.listen(
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
                options: [for (var i = 1; i <= audioPlayers.length; i++) i]
                    .asMap()
                    .map((key, val) => MapEntry('player-$key', 'P$val')),
                selected: selectedPlayerIdx,
                onChange: (v) => setState(() => selectedPlayerIdx = v),
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: selectedPlayerIdx,
              children: audioPlayers
                  .map(
                    (player) => Tabs(
                      tabs: [
                        TabData(
                          key: 'sourcesTab',
                          label: 'Src',
                          content: SourcesTab(
                            player: player,
                          ),
                        ),
                        TabData(
                          key: 'controlsTab',
                          label: 'Ctrl',
                          content: ControlsTab(
                            player: player,
                          ),
                        ),
                        TabData(
                          key: 'streamsTab',
                          label: 'Stream',
                          content: StreamsTab(
                            player: player,
                          ),
                        ),
                        TabData(
                          key: 'audioContextTab',
                          label: 'Ctx',
                          content: AudioContextTab(
                            player: player,
                          ),
                        ),
                        TabData(
                          key: 'loggerTab',
                          label: 'Log',
                          content: const LoggerTab(),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
