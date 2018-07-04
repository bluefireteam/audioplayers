import 'package:flutter/services.dart';
import 'package:test/test.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  List<MethodCall> calls = [];
  const channel = const MethodChannel('xyz.luan/audioplayers');
  channel.setMockMethodCallHandler((MethodCall call) {
    calls.add(call);
  });

  group('AudioPlayer', () {
    test('#play', () async {
      calls.clear();
      AudioPlayer player = new AudioPlayer();
      await player.play('internet.com/file.mp3');
      expect(calls, hasLength(1));
      expect(calls[0].method, 'play');
      expect(calls[0].arguments['url'], 'internet.com/file.mp3');
    });

    test('multiple players', () async {
      calls.clear();
      AudioPlayer player1 = new AudioPlayer();
      AudioPlayer player2 = new AudioPlayer();

      await player1.play('internet.com/file.mp3');
      String player1Id = calls[0].arguments['playerId'];

      expect(calls, hasLength(1));
      expect(calls[0].method, 'play');
      expect(calls[0].arguments['url'], 'internet.com/file.mp3');
      calls.clear();

      await player1.play('internet.com/file.mp3');
      expect(calls[0].arguments['playerId'], player1Id);
      calls.clear();

      await player2.play('internet.com/file.mp3');
      expect(calls[0].arguments['playerId'], isNot(player1Id));
      calls.clear();

      await player1.play('internet.com/file.mp3');
      expect(calls[0].arguments['playerId'], player1Id);
      calls.clear();
    });

    test('#loop', () async {
      calls.clear();
      AudioPlayer player = new AudioPlayer();

      await player.loop('music');
      String playerId = calls[0].arguments['playerId'];

      expect(calls, hasLength(1));
      expect(calls[0].method, 'play');
      calls.clear();

      await AudioPlayer.platformCallHandler(
          new MethodCall('audio.onComplete', {'playerId': playerId}));

      expect(calls, hasLength(1));
      expect(calls[0].method, 'play');
      calls.clear();
    });
  });
}
