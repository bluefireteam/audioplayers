import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

import 'player_widget.dart';

typedef void OnError(Exception exception);

const kUrl1 = 'http://www.rxlabz.com/labz/audio.mp3';
const kUrl2 = 'http://www.rxlabz.com/labz/audio2.mp3';

void main() {
  runApp(new MaterialApp(home: new ExampleApp()));
}

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => new _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  AudioCache audioCache = new AudioCache();
  String localFilePath;

  Future _loadFile() async {
    final bytes = await readBytes(kUrl1);
    final dir = await getApplicationDocumentsDirectory();
    final file = new File('${dir.path}/audio.mp3');

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
        padding: EdgeInsets.all(32.0),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget remoteUrl() {
    return _tab([
      Text('Sample 1 ($kUrl1)'),
      PlayerWidget(url: kUrl1),
      Text('Sample 2 ($kUrl2)'),
      PlayerWidget(url: kUrl2),
    ]);
  }

  Widget localFile() {
    return _tab([
      Text('File: $kUrl1'),
      RaisedButton(
          child: Text('Download File to your Device'),
          onPressed: () => _loadFile()),
      Text('Current local file path: $localFilePath'),
      localFilePath == null
          ? Container()
          : PlayerWidget(url: localFilePath, isLocal: true),
    ]);
  }

  Widget localAsset() {
    return _tab([
      Text('Play Local Asset \'audio.mp3\':'),
      RaisedButton(
          child: Text('Play'), onPressed: () => audioCache.play('audio.mp3')),
      Text('Loop Local Asset \'audio.mp3\':'),
      RaisedButton(
          child: Text('Loop'), onPressed: () => audioCache.loop('audio.mp3')),
      Text('Play Local Asset \'audio2.mp3\':'),
      RaisedButton(
          child: Text('Play'), onPressed: () => audioCache.play('audio2.mp3')),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: 'Remote Url'),
              Tab(text: 'Local File'),
              Tab(text: 'Local Asset'),
            ],
          ),
          title: Text('audioplayers Example'),
        ),
        body: TabBarView(
          children: [remoteUrl(), localFile(), localAsset()],
        ),
      ),
    );
  }
}
