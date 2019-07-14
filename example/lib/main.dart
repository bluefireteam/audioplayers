import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

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

  Widget _tab(List<Widget> children) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: children.map((w) => Container(child: w, padding: EdgeInsets.all(6.0))).toList(),
        ),
      ),
    );
  }

  Widget _btn(String txt, VoidCallback onPressed) {
    return ButtonTheme(minWidth: 48.0, child: RaisedButton(child: Text(txt), onPressed: onPressed));
  }

  Widget remoteUrl() {
    return SingleChildScrollView(
      child: _tab([
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
    return _tab([
      Text('File: $kUrl1'),
      _btn('Download File to your Device', () => _loadFile()),
      Text('Current local file path: $localFilePath'),
      localFilePath == null ? Container() : PlayerWidget(url: localFilePath, isLocal: true),
    ]);
  }

  Widget localAsset() {
    return _tab([
      Text('Play Local Asset \'audio.mp3\':'),
      _btn('Play', () => audioCache.play('audio.mp3')),
      Text('Loop Local Asset \'audio.mp3\':'),
      _btn('Loop', () => audioCache.loop('audio.mp3')),
      Text('Play Local Asset In Low Latency \'audio.mp3\':'),
      _btn('Play', () => audioCache.play('audio.mp3', mode: PlayerMode.LOW_LATENCY)),
      Text('Play multiple files (default):'),
      _btn('Play parallel', () async {
        await audioCache.play('hello.mp3');
        await audioCache.play('world.mp3');
      }),
      Text('PlaySync() sequential'),
      _btn('Play sequential', () async {
        await audioCache.playSync('hello.mp3');
        await audioCache.playSync('world.mp3');
      }),
      Text('PlayAll() files:'),
      _btn('Play', () => audioCache.playAll(['hello.mp3', 'world.mp3'])),
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
    return _tab([
      Text('Play notification sound: \'messenger.mp3\':'),
      _btn('Play', () => audioCache.play('messenger.mp3', isNotification: true)),
    ]);
  }

  Widget advanced() {
    return _tab([
      Column(children: [
        Text('Source Url'),
        Row(children: [
          _btn('Audio 1', () => advancedPlayer.setUrl(kUrl1)),
          _btn('Audio 2', () => advancedPlayer.setUrl(kUrl2)),
          _btn('Stream', () => advancedPlayer.setUrl(kUrl3)),
        ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
      ]),
      Column(children: [
        Text('Release Mode'),
        Row(children: [
          _btn('STOP', () => advancedPlayer.setReleaseMode(ReleaseMode.STOP)),
          _btn('LOOP', () => advancedPlayer.setReleaseMode(ReleaseMode.LOOP)),
          _btn('RELEASE', () => advancedPlayer.setReleaseMode(ReleaseMode.RELEASE)),
        ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
      ]),
      new Column(children: [
        Text('Volume'),
        Row(children: [
          _btn('0.0', () => advancedPlayer.setVolume(0.0)),
          _btn('0.5', () => advancedPlayer.setVolume(0.5)),
          _btn('1.0', () => advancedPlayer.setVolume(1.0)),
          _btn('2.0', () => advancedPlayer.setVolume(2.0)),
        ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
      ]),
      new Column(children: [
        Text('Control'),
        Row(children: [
          _btn('resume', () => advancedPlayer.resume()),
          _btn('pause', () => advancedPlayer.pause()),
          _btn('stop', () => advancedPlayer.stop()),
          _btn('release', () => advancedPlayer.release()),
        ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
      ]),
      new Column(children: [
        Text('Seek in milliseconds'),
        Row(children: [
          _btn('100ms', () => advancedPlayer.seek(Duration(milliseconds: 100))),
          _btn('500ms', () => advancedPlayer.seek(Duration(milliseconds: 500))),
          _btn('1s', () => advancedPlayer.seek(Duration(seconds: 1))),
          _btn('1.5s', () => advancedPlayer.seek(Duration(milliseconds: 1500))),
        ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
      ]),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
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
          children: [remoteUrl(), localFile(), localAsset(), notification(), advanced()],
        ),
      ),
    );
  }
}
