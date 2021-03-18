import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/src/foundation/constants.dart';

import 'player_widget.dart';

typedef void OnError(Exception exception);

const kUrl1 = 'https://luan.xyz/files/audio/ambient_c_motion.mp3';
const kUrl2 = 'https://luan.xyz/files/audio/nasa_on_a_mission.mp3';
const kUrl3 = 'http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio1xtra_mf_p';

void main() {
  runApp(MaterialApp(home: ExampleApp()));
}

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  AudioCache audioCache = AudioCache();
  AudioPlayer advancedPlayer = AudioPlayer();
  String? localFilePath;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      // Calls to Platform.isIOS fails on web
      return;
    }
    if (Platform.isIOS) {
      audioCache.fixedPlayer?.startHeadlessService();
      advancedPlayer.startHeadlessService();
    }
  }

  Future _loadFile() async {
    final bytes = await readBytes(Uri.parse(kUrl1));
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/audio.mp3');

    await file.writeAsBytes(bytes);
    if (await file.exists()) {
      setState(() => localFilePath = file.path);
    }
  }

  Widget remoteUrl() {
    return SingleChildScrollView(
      child: _Tab(
        children: [
          Text(
            'Sample 1 ($kUrl1)',
            key: Key('url1'),
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
        ],
      ),
    );
  }

  Widget localFile() {
    return _Tab(children: [
      Text('File: $kUrl1'),
      _Btn(txt: 'Download File to your Device', onPressed: () => _loadFile()),
      Text('Current local file path: $localFilePath'),
      localFilePath == null ? Container() : PlayerWidget(url: localFilePath!),
    ]);
  }

  Widget localAsset() {
    return SingleChildScrollView(
      child: _Tab(
        children: [
          Text('Play Local Asset \'audio.mp3\':'),
          _Btn(txt: 'Play', onPressed: () => audioCache.play('audio.mp3')),
          Text('Play Local Asset (via byte source) \'audio.mp3\':'),
          _Btn(
            txt: 'Play',
            onPressed: () async {
              var bytes =
                  await (await audioCache.load('audio.mp3')).readAsBytes();
              audioCache.playBytes(bytes);
            },
          ),
          Text('Loop Local Asset \'audio.mp3\':'),
          _Btn(txt: 'Loop', onPressed: () => audioCache.loop('audio.mp3')),
          Text('Loop Local Asset (via byte source) \'audio.mp3\':'),
          _Btn(
            txt: 'Loop',
            onPressed: () async {
              var bytes =
                  await (await audioCache.load('audio.mp3')).readAsBytes();
              audioCache.playBytes(bytes, loop: true);
            },
          ),
          Text('Play Local Asset \'audio2.mp3\':'),
          _Btn(txt: 'Play', onPressed: () => audioCache.play('audio2.mp3')),
          Text('Play Local Asset In Low Latency \'audio.mp3\':'),
          _Btn(
            txt: 'Play',
            onPressed: () =>
                audioCache.play('audio.mp3', mode: PlayerMode.LOW_LATENCY),
          ),
          Text('Play Local Asset Concurrently In Low Latency \'audio.mp3\':'),
          _Btn(
              txt: 'Play',
              onPressed: () async {
                await audioCache.play('audio.mp3',
                    mode: PlayerMode.LOW_LATENCY);
                await audioCache.play('audio2.mp3',
                    mode: PlayerMode.LOW_LATENCY);
              }),
          Text('Play Local Asset In Low Latency \'audio2.mp3\':'),
          _Btn(
            txt: 'Play',
            onPressed: () =>
                audioCache.play('audio2.mp3', mode: PlayerMode.LOW_LATENCY),
          ),
          getLocalFileDuration(),
        ],
      ),
    );
  }

  Future<int> _getDuration() async {
    File audiofile = await audioCache.load('audio2.mp3');
    await advancedPlayer.setUrl(
      audiofile.path,
    );
    int duration = await Future.delayed(
      Duration(seconds: 2),
      () => advancedPlayer.getDuration(),
    );
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
            return Text(
              'audio2.mp3 duration is: ${Duration(milliseconds: snapshot.data!)}',
            );
          default:
            return Container();
        }
      },
    );
  }

  Widget notification() {
    return _Tab(children: [
      Text('Play notification sound: \'messenger.mp3\':'),
      _Btn(
        txt: 'Play',
        onPressed: () => audioCache.play('messenger.mp3', isNotification: true),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<Duration>.value(
            initialData: Duration(),
            value: advancedPlayer.onAudioPositionChanged),
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
              Advanced(advancedPlayer: advancedPlayer),
            ],
          ),
        ),
      ),
    );
  }
}

class Advanced extends StatefulWidget {
  final AudioPlayer advancedPlayer;

  const Advanced({Key? key, required this.advancedPlayer}) : super(key: key);

  @override
  _AdvancedState createState() => _AdvancedState();
}

class _AdvancedState extends State<Advanced> {
  bool? seekDone;

  @override
  void initState() {
    widget.advancedPlayer.onSeekComplete
        .listen((event) => setState(() => seekDone = true));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final audioPosition = Provider.of<Duration>(context);
    return SingleChildScrollView(
      child: _Tab(
        children: [
          Column(
            children: [
              Text('Source Url'),
              Row(children: [
                _Btn(
                  txt: 'Audio 1',
                  onPressed: () => widget.advancedPlayer.setUrl(kUrl1),
                ),
                _Btn(
                  txt: 'Audio 2',
                  onPressed: () => widget.advancedPlayer.setUrl(kUrl2),
                ),
                _Btn(
                  txt: 'Stream',
                  onPressed: () => widget.advancedPlayer.setUrl(kUrl3),
                ),
              ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
            ],
          ),
          Column(
            children: [
              Text('Release Mode'),
              Row(children: [
                _Btn(
                  txt: 'STOP',
                  onPressed: () =>
                      widget.advancedPlayer.setReleaseMode(ReleaseMode.STOP),
                ),
                _Btn(
                  txt: 'LOOP',
                  onPressed: () =>
                      widget.advancedPlayer.setReleaseMode(ReleaseMode.LOOP),
                ),
                _Btn(
                  txt: 'RELEASE',
                  onPressed: () =>
                      widget.advancedPlayer.setReleaseMode(ReleaseMode.RELEASE),
                ),
              ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
            ],
          ),
          Column(
            children: [
              Text('Volume'),
              Row(
                children: [0.0, 0.5, 1.0, 2.0].map((e) {
                  return _Btn(
                    txt: e.toString(),
                    onPressed: () => widget.advancedPlayer.setVolume(e),
                  );
                }).toList(),
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              ),
            ],
          ),
          Column(
            children: [
              Text('Control'),
              Row(
                children: [
                  _Btn(
                    txt: 'resume',
                    onPressed: () => widget.advancedPlayer.resume(),
                  ),
                  _Btn(
                    txt: 'pause',
                    onPressed: () => widget.advancedPlayer.pause(),
                  ),
                  _Btn(
                    txt: 'stop',
                    onPressed: () => widget.advancedPlayer.stop(),
                  ),
                  _Btn(
                    txt: 'release',
                    onPressed: () => widget.advancedPlayer.release(),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              ),
            ],
          ),
          Column(
            children: [
              Text('Seek in milliseconds'),
              Row(
                children: [
                  _Btn(
                      txt: '100ms',
                      onPressed: () {
                        widget.advancedPlayer.seek(
                          Duration(
                            milliseconds: audioPosition.inMilliseconds + 100,
                          ),
                        );
                        setState(() => seekDone = false);
                      }),
                  _Btn(
                      txt: '500ms',
                      onPressed: () {
                        widget.advancedPlayer.seek(
                          Duration(
                            milliseconds: audioPosition.inMilliseconds + 500,
                          ),
                        );
                        setState(() => seekDone = false);
                      }),
                  _Btn(
                      txt: '1s',
                      onPressed: () {
                        widget.advancedPlayer.seek(
                          Duration(seconds: audioPosition.inSeconds + 1),
                        );
                        setState(() => seekDone = false);
                      }),
                  _Btn(
                      txt: '1.5s',
                      onPressed: () {
                        widget.advancedPlayer.seek(
                          Duration(
                            milliseconds: audioPosition.inMilliseconds + 1500,
                          ),
                        );
                        setState(() => seekDone = false);
                      }),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              ),
            ],
          ),
          Column(
            children: [
              Text('Rate'),
              Row(
                children: [0.5, 1.0, 1.5, 2.0].map((e) {
                  return _Btn(
                    txt: e.toString(),
                    onPressed: () {
                      widget.advancedPlayer.setPlaybackRate(playbackRate: e);
                    },
                  );
                }).toList(),
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              ),
            ],
          ),
          Text('Audio Position: ${audioPosition}'),
          if (seekDone != null) Text(seekDone! ? 'Seek Done' : 'Seeking...'),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final List<Widget> children;

  const _Tab({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: children
                .map((w) => Container(child: w, padding: EdgeInsets.all(6.0)))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String txt;
  final VoidCallback onPressed;

  const _Btn({Key? key, required this.txt, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      minWidth: 48.0,
      child: RaisedButton(child: Text(txt), onPressed: onPressed),
    );
  }
}
