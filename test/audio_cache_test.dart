import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/services.dart';
import 'package:test/test.dart';

class MyAudioCache extends AudioCache {
  List<String> called = [];
  @override
  Future<File> fetchToMemory(String fileName) async {
    called.add(fileName);
    return new File('test/assets/' + fileName);
  }
}

void main() {
  const MethodChannel _channel =
      const MethodChannel('plugins.flutter.io/path_provider');
  _channel.setMockMethodCallHandler((c) async => '/tmp');

  group('AudioCache', () {
    test('sets cache', () async {
      MyAudioCache player = new MyAudioCache();
      await player.load('audio.mp3');
      expect(player.loadedFiles['audio.mp3'], isNotNull);
      expect(player.called, hasLength(1));
      player.called.clear();

      await player.load('audio.mp3');
      expect(player.called, hasLength(0));
    });
  });
}
