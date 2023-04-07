import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAudioCache extends AudioCache {
  List<String> called = [];

  FakeAudioCache({super.prefix});

  @override
  Future<Uri> fetchToMemory(String fileName) async {
    called.add(fileName);
    return Uri.parse('test/assets/$fileName');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
      cache.clear('audio.mp3');
      expect(cache.loadedFiles, <String, Uri>{});
    });
  });
}
