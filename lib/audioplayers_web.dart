import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class AudioplayersPlugin {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'xyz.luan/audioplayers',
      const StandardMethodCodec(),
      registrar.messenger,
    );

    final AudioplayersPlugin instance = AudioplayersPlugin();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    final method = call.method;
    switch (method) {
      case 'play':
        final String url = call.arguments['url'];
        print('hello from backend $url');
        return 1;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: "The audioplayers plugin for web doesn't implement the method '$method'",
        );
    }
  }
}
