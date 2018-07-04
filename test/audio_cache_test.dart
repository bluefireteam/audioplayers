import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/services.dart';
import 'package:test/test.dart';

class MyAudioCache extends AudioCache {
  @override
  Future<File> fetchToMemory(String fileName) async {
    return new File('test/assets/' + fileName);
  }
}

void main() {
  const MethodChannel _channel = const MethodChannel('plugins.flutter.io/path_provider');
  _channel.setMockMethodCallHandler((c) async => '/tmp');

  group('AudioCache', () {
    test('sets cache', () async {
      AudioCache player = new MyAudioCache();
      await player.load('audio.mp3');
      expect(player.loadedFiles['audio.mp3'], isNotNull);
    });
  });
}
