import 'package:audioplayers_platform_interface/src/audioplayers_platform_interface.dart';
import 'package:audioplayers_platform_interface/src/method_channel_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final methodCalls = <MethodCall>[];
  TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('xyz.luan/audioplayers'),
    (MethodCall methodCall) async {
      methodCalls.add(methodCall);
      return 0;
    },
  );

  void clear() {
    methodCalls.clear();
  }

  MethodCall popCall() {
    return methodCalls.removeAt(0);
  }

  MethodCall popLastCall() {
    expect(methodCalls, hasLength(1));
    return popCall();
  }

  group('AudioPlayers Method Channel', () {
    setUp(clear);

    final platform = AudioplayersPlatformInterface.instance;

    test('#setSource', () async {
      await platform.setSourceUrl('p1', 'internet.com/file.mp3');
      final call = popLastCall();
      expect(call.method, 'setSourceUrl');
      expect(call.args, {
        'playerId': 'p1',
        'url': 'internet.com/file.mp3',
        'isLocal': null,
      });
    });

    test('#resume', () async {
      await platform.resume('p1');
      final call = popLastCall();
      expect(call.method, 'resume');
      expect(call.args, {'playerId': 'p1'});
    });

    test('#pause', () async {
      await platform.pause('p1');
      final call = popLastCall();
      expect(call.method, 'pause');
      expect(call.args, {'playerId': 'p1'});
    });

    test('#getDuration', () async {
      final duration = await platform.getDuration('p1');
      final call = popLastCall();
      expect(call.method, 'getDuration');
      expect(call.args, {'playerId': 'p1'});
      expect(duration, 0);
    });

    test('#getCurrentPosition', () async {
      final position = await platform.getCurrentPosition('p1');
      final call = popLastCall();
      expect(call.method, 'getCurrentPosition');
      expect(call.args, {'playerId': 'p1'});
      expect(position, 0);
    });
  });
}
