import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'components/tabs.dart';
import 'components/tgl.dart';
import 'tabs/audio_context.dart';
import 'tabs/controls.dart';
import 'tabs/logger.dart';
import 'tabs/sources.dart';
import 'tabs/streams.dart';
import 'utils.dart';

typedef OnError = void Function(Exception exception);

void main() {
  runApp(MaterialApp(home: ExampleApp()));
}

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  List<AudioPlayer> players = List.generate(4, (_) => AudioPlayer());
  int selectedPlayerIdx = 0;

  AudioPlayer get selectedPlayer => players[selectedPlayerIdx];

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
                options: const ['P1', 'P2', 'P3', 'P4'],
                selected: selectedPlayerIdx,
                onChange: (v) => setState(() => selectedPlayerIdx = v),
              ),
            ),
          ),
          Expanded(
            child: Tabs(
              tabs: {
                'Src': SourcesTab(setSourceUrl: setSourceUrl),
                'Ctrl': ControlsTab(player: selectedPlayer),
                'Stream': StreamsTab(player: selectedPlayer),
                'Ctx': const AudioContextTab(),
                'Log': const LoggerTab(),
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> setSourceUrl(String url, {bool isLocal = false}) async {
    await selectedPlayer.setSourceUrl(url, isLocal: isLocal);
    toast('Successfully setted URL');
  }
}
