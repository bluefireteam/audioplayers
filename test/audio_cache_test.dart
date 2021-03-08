import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class MyAudioCache extends AudioCache {
  List<String> called = [];

  MyAudioCache({String prefix = 'assets/', AudioPlayer? fixedPlayer})
      : super(prefix: prefix, fixedPlayer: fixedPlayer);

  @override
  Future<File> fetchToMemory(String fileName) async {
    called.add(fileName);
    return new File('test/assets/' + fileName);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
      MyAudioCache fixed = MyAudioCache(fixedPlayer: AudioPlayer());
      String fixedId = fixed.fixedPlayer!.playerId;
      MyAudioCache regular = MyAudioCache();

      AudioPlayer a1 = await fixed.play('audio.mp3');
      expect(a1.playerId, fixedId);
      AudioPlayer a2 = await fixed.play('audio.mp3');
      expect(a2.playerId, fixedId);

      AudioPlayer a3 = await regular.play('audio.mp3');
      expect(a3.playerId, isNot(fixedId));
    });
  });
}
