import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  List<MethodCall> calls = [];
  const channel = const MethodChannel('xyz.luan/audioplayers');
  channel.setMockMethodCallHandler((MethodCall call) async {
    calls.add(call);
    return 0;
  });

  MethodCall popCall() {
    expect(calls, hasLength(1));
    return calls.removeAt(0);
  }

  group('AudioPlayers', () {
    test('#play', () async {
      calls.clear();
      AudioPlayer player = AudioPlayer();
      await player.play('internet.com/file.mp3');
      MethodCall call = popCall();
      expect(call.method, 'play');
      expect(call.arguments['url'], 'internet.com/file.mp3');
    });

    test('multiple players', () async {
      calls.clear();
      AudioPlayer player1 = AudioPlayer();
      AudioPlayer player2 = AudioPlayer();

      await player1.play('internet.com/file.mp3');
      MethodCall call = popCall();
      String player1Id = call.arguments['playerId'];
      expect(call.method, 'play');
      expect(call.arguments['url'], 'internet.com/file.mp3');

      await player1.play('internet.com/file.mp3');
      expect(popCall().arguments['playerId'], player1Id);

      await player2.play('internet.com/file.mp3');
      expect(popCall().arguments['playerId'], isNot(player1Id));

      await player1.play('internet.com/file.mp3');
      expect(popCall().arguments['playerId'], player1Id);
    });

    test('#resume, #pause and #duration', () async {
      calls.clear();
      AudioPlayer player = AudioPlayer();
      await player.setUrl('assets/audio.mp3');
      expect(popCall().method, 'setUrl');

      await player.resume();
      expect(popCall().method, 'resume');

      await player.getDuration();
      expect(popCall().method, 'getDuration');

      await player.pause();
      expect(popCall().method, 'pause');
    });
  });
}
