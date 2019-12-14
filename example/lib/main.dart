import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'player_widget.dart';

typedef void OnError(Exception exception);

const kUrl1 = 'https://luan.xyz/files/audio/ambient_c_motion.mp3';
const kUrl2 = 'https://luan.xyz/files/audio/nasa_on_a_mission.mp3';
const kUrl3 = 'http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio1xtra_mf_p';

void main() {
  runApp(new MaterialApp(home: new ExampleApp()));
}

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => new _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  AudioCache audioCache = AudioCache();
  AudioPlayer advancedPlayer = AudioPlayer();
  String localFilePath;

  @override
  void initState() {
    super.initState();

    if (Platform.isIOS) {
      if (audioCache.fixedPlayer != null) {
        audioCache.fixedPlayer.startHeadlessService();
      }
      advancedPlayer.startHeadlessService();
    }
  }

  Future _loadFile() async {
    final bytes = await readBytes(kUrl1);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/audio.mp3');

    await file.writeAsBytes(bytes);
    if (await file.exists()) {
      setState(() {
        localFilePath = file.path;
      });
    }
  }

  Widget remoteUrl() {
    return SingleChildScrollView(
      child: _tab(children: [
        Text(
          'Sample 1 ($kUrl1)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        PlayerWidget(url: kUrl1),
        Text(
          'Sample 2 ($kUrl2)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        PlayerWidget(url: kUrl2),
        Text(
          'Sample 3 ($kUrl3)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        PlayerWidget(url: kUrl3),
        Text(
          'Sample 4 (Low Latency mode) ($kUrl1)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        PlayerWidget(url: kUrl1, mode: PlayerMode.LOW_LATENCY),
      ]),
    );
  }

  Widget localFile() {
    return _tab(children: [
      Text('File: $kUrl1'),
      _btn(txt: 'Download File to your Device', onPressed: () => _loadFile()),
      Text('Current local file path: $localFilePath'),
      localFilePath == null ? Container() : PlayerWidget(url: localFilePath, isLocal: true),
    ]);
  }

  Widget localAsset() {
    return _tab(children: [
      Text('Play Local Asset \'audio.mp3\':'),
      _btn(txt: 'Play', onPressed: () => audioCache.play('audio.mp3')),
      Text('Loop Local Asset \'audio.mp3\':'),
      _btn(txt: 'Loop', onPressed: () => audioCache.loop('audio.mp3')),
      Text('Play Local Asset \'audio2.mp3\':'),
      _btn(txt: 'Play', onPressed: () => audioCache.play('audio2.mp3')),
      Text('Play Local Asset In Low Latency \'audio.mp3\':'),
      _btn(txt: 'Play', onPressed: () => audioCache.play('audio.mp3', mode: PlayerMode.LOW_LATENCY)),
      Text('Play Local Asset Concurrently In Low Latency \'audio.mp3\':'),
      _btn(
          txt: 'Play',
          onPressed: () async {
            await audioCache.play('audio.mp3', mode: PlayerMode.LOW_LATENCY);
            await audioCache.play('audio2.mp3', mode: PlayerMode.LOW_LATENCY);
          }),
      Text('Play Local Asset In Low Latency \'audio2.mp3\':'),
      _btn(txt: 'Play', onPressed: () => audioCache.play('audio2.mp3', mode: PlayerMode.LOW_LATENCY)),
      getLocalFileDuration(),
    ]);
  }

  Future<int> _getDuration() async {
    File audiofile = await audioCache.load('audio2.mp3');
    await advancedPlayer.setUrl(
      audiofile.path,
      isLocal: true,
    );
    int duration = await Future.delayed(Duration(seconds: 2), () => advancedPlayer.getDuration());
    return duration;
  }

  getLocalFileDuration() {
    return FutureBuilder<int>(
      future: _getDuration(),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('No Connection...');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Text('Awaiting result...');
          case ConnectionState.done:
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            return Text('audio2.mp3 duration is: ${Duration(milliseconds: snapshot.data)}');
        }
        return null; // unreachable
      },
    );
  }

  Widget notification() {
    return _tab(children: [
      Text('Play notification sound: \'messenger.mp3\':'),
      _btn(txt: 'Play', onPressed: () => audioCache.play('messenger.mp3', isNotification: true)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<Duration>.value(initialData: Duration(), value: advancedPlayer.onAudioPositionChanged),
      ],
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(text: 'Remote Url'),
                Tab(text: 'Local File'),
                Tab(text: 'Local Asset'),
                Tab(text: 'Notification'),
                Tab(text: 'Advanced'),
              ],
            ),
            title: Text('audioplayers Example'),
          ),
          body: TabBarView(
            children: [
              remoteUrl(),
              localFile(),
              localAsset(),
              notification(),
              Advanced(
                advancedPlayer: advancedPlayer,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Advanced extends StatefulWidget {
  final AudioPlayer advancedPlayer;

  const Advanced({Key key, this.advancedPlayer}) : super(key: key);

  @override
  _AdvancedState createState() => _AdvancedState();
}

class _AdvancedState extends State<Advanced> {
  bool seekDone;

  @override
  void initState() {
    widget.advancedPlayer.seekCompleteHandler = () => setState(() => seekDone = true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final audioPosition = Provider.of<Duration>(context);
    return _tab(
      children: [
        Column(children: [
          Text('Source Url'),
          Row(children: [
            _btn(txt: 'Audio 1', onPressed: () => widget.advancedPlayer.setUrl(kUrl1)),
            _btn(txt: 'Audio 2', onPressed: () => widget.advancedPlayer.setUrl(kUrl2)),
            _btn(txt: 'Stream', onPressed: () => widget.advancedPlayer.setUrl(kUrl3)),
          ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
        ]),
        Column(children: [
          Text('Release Mode'),
          Row(children: [
            _btn(txt: 'STOP', onPressed: () => widget.advancedPlayer.setReleaseMode(ReleaseMode.STOP)),
            _btn(txt: 'LOOP', onPressed: () => widget.advancedPlayer.setReleaseMode(ReleaseMode.LOOP)),
            _btn(txt: 'RELEASE', onPressed: () => widget.advancedPlayer.setReleaseMode(ReleaseMode.RELEASE)),
          ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
        ]),
        new Column(children: [
          Text('Volume'),
          Row(children: [
            _btn(txt: '0.0', onPressed: () => widget.advancedPlayer.setVolume(0.0)),
            _btn(txt: '0.5', onPressed: () => widget.advancedPlayer.setVolume(0.5)),
            _btn(txt: '1.0', onPressed: () => widget.advancedPlayer.setVolume(1.0)),
            _btn(txt: '2.0', onPressed: () => widget.advancedPlayer.setVolume(2.0)),
          ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
        ]),
        new Column(children: [
          Text('Rate'),
          Row(children: [
            _btn(
                txt: '0.5',
                onPressed: () =>
                    widget.advancedPlayer.setPlaybackRate(playbackRate: 0.5)),
            _btn(
                txt: '1.0',
                onPressed: () =>
                    widget.advancedPlayer.setPlaybackRate(playbackRate: 1.0)),
            _btn(
                txt: '1.5',
                onPressed: () =>
                    widget.advancedPlayer.setPlaybackRate(playbackRate: 1.5)),
            _btn(
                txt: '2.0',
                onPressed: () =>
                    widget.advancedPlayer.setPlaybackRate(playbackRate: 2.0)),
          ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
        ]),
        new Column(children: [
          Text('Control'),
          Row(children: [
            _btn(txt: 'resume', onPressed: () => widget.advancedPlayer.resume()),
            _btn(txt: 'pause', onPressed: () => widget.advancedPlayer.pause()),
            _btn(txt: 'stop', onPressed: () => widget.advancedPlayer.stop()),
            _btn(txt: 'release', onPressed: () => widget.advancedPlayer.release()),
          ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
        ]),
        new Column(
          children: [
            Text('Seek in milliseconds'),
            Row(children: [
              _btn(
                  txt: '100ms',
                  onPressed: () {
                    widget.advancedPlayer.seek(Duration(milliseconds: audioPosition.inMilliseconds + 100));
                    setState(() => seekDone = false);
                  }),
              _btn(
                  txt: '500ms',
                  onPressed: () {
                    widget.advancedPlayer.seek(Duration(milliseconds: audioPosition.inMilliseconds + 500));
                    setState(() => seekDone = false);
                  }),
              _btn(
                  txt: '1s',
                  onPressed: () {
                    widget.advancedPlayer.seek(Duration(seconds: audioPosition.inSeconds + 1));
                    setState(() => seekDone = false);
                  }),
              _btn(
                  txt: '1.5s',
                  onPressed: () {
                    widget.advancedPlayer.seek(Duration(milliseconds: audioPosition.inMilliseconds + 1500));
                    setState(() => seekDone = false);
                  }),
            ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
            Text('Audio Position: ${audioPosition}'),
            seekDone == null
                ? SizedBox(
                    width: 0,
                    height: 0,
                  )
                : Text(seekDone ? "Seek Done" : "Seeking..."),
          ],
        ),
      ],
    );
  }
}

class _tab extends StatelessWidget {
  final List<Widget> children;

  const _tab({Key key, this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: children.map((w) => Container(child: w, padding: EdgeInsets.all(6.0))).toList(),
        ),
      ),
    );
  }
}

class _btn extends StatelessWidget {
  final String txt;
  final VoidCallback onPressed;

  const _btn({Key key, this.txt, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(minWidth: 48.0, child: RaisedButton(child: Text(txt), onPressed: onPressed));
  }
}
