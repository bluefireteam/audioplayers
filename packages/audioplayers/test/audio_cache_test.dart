import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAudioCache extends AudioCache {
  List<String> called = [];

  FakeAudioCache({super.prefix});

  @override
  Future<Uri> fetchToMemory(String fileName) async {
    called.add(fileName);
    return super.fetchToMemory(fileName);
  }

  @override
  Future<ByteData> loadAsset(String path) async {
    return ByteData.sublistView(utf8.encode(path));
  }

  @override
  Future<String> getTempDir() async => '/';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AudioCache.fileSystem = MemoryFileSystem.test();
  });

  group('AudioCache', () {
    test('sets cache', () async {
      final cache = FakeAudioCache();
      await cache.load('audio.mp3');
      expect(cache.loadedFiles['audio.mp3'], isNotNull);
      expect(cache.called, hasLength(1));
      cache.called.clear();

      await cache.load('audio.mp3');
      expect(cache.called, hasLength(0));
    });

    test('clear cache', () async {
      final cache = FakeAudioCache();
      await cache.load('audio.mp3');
      expect(cache.loadedFiles['audio.mp3'], isNotNull);
      await cache.clearAll();
      expect(cache.loadedFiles, <String, Uri>{});
      await cache.load('audio.mp3');
      expect(cache.loadedFiles.isNotEmpty, isTrue);
      await cache.clear('audio.mp3');
      expect(cache.loadedFiles, <String, Uri>{});
    });
  });
}
