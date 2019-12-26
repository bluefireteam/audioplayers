import 'dart:async';
import 'dart:html';
import 'dart:web_audio';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class AudioplayersPlugin {
  static final AudioContext audioCtx = AudioContext();

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
        print('hello from backend $url $audioCtx');

        print('get the audio file');
        HttpRequest.request(url, responseType: "arraybuffer").then((HttpRequest request) {
          print('decode it');
          audioCtx.decodeAudioData(request.response).then((AudioBuffer buffer) {
            print('play it now');
            AudioBufferSourceNode source = audioCtx.createBufferSource();
            source.buffer = buffer;
            source.connectNode(audioCtx.destination);
            source.start(audioCtx.currentTime);
          });
        });


        return 1;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: "The audioplayers plugin for web doesn't implement the method '$method'",
        );
    }
  }
}
