import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

typedef void OnError(Exception exception);

const kUrl2 = "http://www.rxlabz.com/labz/audio.mp3";
const kUrl1 = "http://www.rxlabz.com/labz/audio2.mp3";

void main() {
  runApp(new MaterialApp(home: new Scaffold(body: new AudioApp())));
}

enum PlayerState { stopped, playing, paused }

class AudioApp extends StatefulWidget {
  @override
  _AudioAppState createState() => new _AudioAppState();
}

class _AudioAppState extends State<AudioApp> {
  Duration duration;
  Duration position;

  AudioPlayer audioPlayer;

  String localFilePath;

  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  get positionText =>
      position != null ? position.toString().split('.').first : '';

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
    new AudioPlayer().play(kUrl2);
  }

  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();

    audioPlayer.setDurationHandler((d) => setState(() {
          print('_AudioAppState.setDurationHandler => d ${d}');
          duration = d;
        }));

    audioPlayer.setPositionHandler((p) => setState(() {
          print('_AudioAppState.setPositionHandler => p ${p}');
          position = p;
        }));

    audioPlayer.setCompletionHandler(() {
      onComplete();
      setState(() {
        position = duration;
      });
    });

    audioPlayer.setErrorHandler((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        playerState = PlayerState.stopped;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    final result = await audioPlayer.play(kUrl1);
    if (result == 1) setState(() => playerState = PlayerState.playing);
  }

  Future _playLocal() async{
    final result = await audioPlayer.play(localFilePath, isLocal: true);
    if (result == 1) setState(() => playerState = PlayerState.playing);
  }

  Future pause() async {
    final result = await audioPlayer.pause();
    if (result == 1) setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    final result = await audioPlayer.stop();
    if (result == 1)
      setState(() {
        playerState = PlayerState.stopped;
        position = new Duration();
      });
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.stop();
  }

  Future<Uint8List> _loadFileBytes(String url, {OnError onError}) async {
    Uint8List bytes;
    try {
      bytes = await readBytes(url);
    } on ClientException {
      rethrow;
    }
    return bytes;
  }

  Future _loadFile() async {
    final bytes = await _loadFileBytes(kUrl1,
        onError: (Exception exception) =>
            print('_MyHomePageState._loadVideo => exception ${exception}'));

    final dir = await getApplicationDocumentsDirectory();
    final file = new File('${dir.path}/audio.mp3');

    await file.writeAsBytes(bytes);
    if (await file.exists())
      setState(() {
        localFilePath = file.path;
      });
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: new Material(
            elevation: 2.0,
            color: Colors.grey[200],
            child: new Column(children: [
              new Material(
                  child: new Container(
                      padding: new EdgeInsets.all(16.0),
                      child:
                          new Column(mainAxisSize: MainAxisSize.min, children: [
                        new Row(mainAxisSize: MainAxisSize.min, children: [
                          new IconButton(
                              onPressed: isPlaying ? null : () => play(),
                              iconSize: 64.0,
                              icon: new Icon(Icons.play_arrow),
                              color: Colors.cyan),
                          new IconButton(
                              onPressed: isPlaying ? () => pause() : null,
                              iconSize: 64.0,
                              icon: new Icon(Icons.pause),
                              color: Colors.cyan),
                          new IconButton(
                              onPressed:
                                  isPlaying || isPaused ? () => stop() : null,
                              iconSize: 64.0,
                              icon: new Icon(Icons.stop),
                              color: Colors.cyan),
                        ]),
                        new Row(mainAxisSize: MainAxisSize.min, children: [
                          new Padding(
                              padding: new EdgeInsets.all(12.0),
                              child: new Stack(children: [
                                new CircularProgressIndicator(
                                    value: 1.0,
                                    valueColor: new AlwaysStoppedAnimation(
                                        Colors.grey[300])),
                                new CircularProgressIndicator(
                                  value: position != null &&
                                          position.inMilliseconds > 0
                                      ? position.inMilliseconds /
                                          duration.inMilliseconds
                                      : 0.0,
                                  valueColor:
                                      new AlwaysStoppedAnimation(Colors.cyan),
                                ),
                              ])),
                          new Text(
                              position != null
                                  ? "${positionText ?? ''} / ${durationText ?? ''}"
                                  : duration != null ? durationText : '',
                              style: new TextStyle(fontSize: 24.0))
                        ])
                      ]))),
              localFilePath != null ? new Text(localFilePath) : new Container(),
              new Row(children: [
                new RaisedButton(
                  onPressed: () => _loadFile(),
                  child: new Text('Download'),
                ),
                new RaisedButton(
                  onPressed: () => _playLocal(),
                  child: new Text('play local'),
                ),
              ])
            ])));
  }
}
