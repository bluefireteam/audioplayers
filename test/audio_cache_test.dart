import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:test/test.dart';

int trackLength = 50;
Duration trackDuration = new Duration(milliseconds: trackLength);
trackDelay() => Future.delayed(new Duration(milliseconds: trackLength + 20));

class MyAudioPlayer extends AudioPlayer {
  MyAudioPlayer({mode = PlayerMode.MEDIA_PLAYER})
    : super(mode: mode);

  final StreamController<void> _completionController =
    StreamController<void>.broadcast();

  @override
  Stream<void> get onPlayerCompletion => _completionController.stream;
}

class MyAudioCache extends AudioCache {
  List<String> called = [];

  MyAudioCache({String prefix = "", AudioPlayer fixedPlayer = null})
      : super(prefix: prefix, fixedPlayer: fixedPlayer);

  @override
  Future<File> fetchToMemory(String fileName) async {
    called.add('load $fileName');
    return new File('test/assets/' + fileName);
  }

  Future<AudioPlayer> inner_play({
    File file,        // either file object
    String fileName,  // or file name
    double volume = 1.0,
    bool isNotification,
    PlayerMode mode = PlayerMode.MEDIA_PLAYER,
    bool stayAwake,
    AudioPlayer player}) async {

    called.add('play $fileName');
    MyAudioPlayer myplayer = player ?? fixedPlayer ?? new MyAudioPlayer(mode: mode);

    // simulate track finished
    await new Timer(trackDuration, () {
      myplayer._completionController.add(null);
    });

    return Future.value(myplayer);
  }
}

void main() {
  const MethodChannel _channel =
      const MethodChannel('plugins.flutter.io/path_provider');
  _channel.setMockMethodCallHandler((c) async => '/tmp');

  const channel = const MethodChannel('xyz.luan/audioplayers');
  channel.setMockMethodCallHandler((MethodCall call) async => 1);

  group('AudioCache', () {
    test('sets cache', () async {
      MyAudioCache player = MyAudioCache();
      await player.load('audio.mp3');
      expect(player.loadedFiles['audio.mp3'], isNotNull);
      expect(player.called, hasLength(1));
      player.called.clear();

      await player.load('audio.mp3');
      expect(player.called, hasLength(0));
    });

    test('fixedPlayer vs non fixedPlayer', () async {
      MyAudioCache fixed = MyAudioCache(fixedPlayer: MyAudioPlayer());
      String fixedId = fixed.fixedPlayer.playerId;
      MyAudioCache regular = MyAudioCache();

      AudioPlayer a1 = await fixed.play('audio.mp3');
      expect(a1.playerId, fixedId);
      AudioPlayer a2 = await fixed.play('audio.mp3');
      expect(a2.playerId, fixedId);

      AudioPlayer a3 = await regular.play('audio.mp3');
      expect(a3.playerId, isNot(fixedId));
    });

    test('playSync()', () async {
      MyAudioCache player = new MyAudioCache();
      await player.playSync('foo');
      expect(player.called, hasLength(2));
    });

    test('playAll()', () async {
      MyAudioCache player = new MyAudioCache();
      await player.playAll(['foo', 'bar']);
      expect(player.called, hasLength(3)); // 2 loads + 1 play
      await trackDelay();
      expect(player.called, hasLength(4)); // +1 play
    });

    test('playAll() - interrupted', () async {
      MyAudioCache player = new MyAudioCache();
      MyAudioPlayer p = await player.playAll(['foo', 'bar']);
      expect(player.called, hasLength(3)); // 2 loads + 1 play
      // stop the player
      await p.stop();
      await trackDelay();
      expect(player.called, hasLength(3));  // did not play last one
    });
  });
}
