import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

extension MethodCallParser on MethodCall {
  Map<Object?, Object?> get args => arguments as Map<Object?, Object?>;
}

void createNativeMethodHandler({
  required String channel,
  Future<Object?>? Function(MethodCall message)? handler,
}) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    MethodChannel(channel),
    handler,
  );
}

// See: https://github.com/flutter/packages/blob/12609a2abbb0a30b9d32af7b73599bfc834e609e/packages/video_player/video_player_android/test/android_video_player_test.dart#L270
void createNativeEventStream({
  required String channel,
  Stream<ByteData>? byteDataStream,
}) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(channel, (ByteData? message) async {
    final methodCall = const StandardMethodCodec().decodeMethodCall(message);
    if (methodCall.method == 'listen') {
      byteDataStream?.listen((byteData) async {
        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
          channel,
          byteData,
          (ByteData? data) {},
        );
      });
      return const StandardMethodCodec().encodeSuccessEnvelope(null);
    } else if (methodCall.method == 'cancel') {
      return const StandardMethodCodec().encodeSuccessEnvelope(null);
    } else {
      fail('Expected listen or cancel');
    }
  });
}
