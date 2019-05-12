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
      AudioPlayer player = AudioPlayer();
      await player.play('internet.com/file.mp3');
      expect(calls, hasLength(1));
      expect(calls[0].method, 'play');
      expect(calls[0].arguments['url'], 'internet.com/file.mp3');
    });

    test('multiple players', () async {
      calls.clear();
      AudioPlayer player1 = AudioPlayer();
      AudioPlayer player2 = AudioPlayer();

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
  });
}
