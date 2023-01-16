import 'dart:html';

import 'package:js/js.dart';

@JS('AudioContext')
@staticInterop
class JsAudioContext {
  external factory JsAudioContext();
}

extension JsAudioContextExtension on JsAudioContext {
  external MediaElementAudioSourceNode createMediaElementSource(
    AudioElement element,
  );

  external StereoPannerNode createStereoPanner();

  external AudioNode get destination;
}

@JS()
@staticInterop
abstract class AudioNode {
  external factory AudioNode();
}

extension AudioNodeExtension on AudioNode {
  external AudioNode connect(AudioNode audioNode);
}

@JS()
@staticInterop
class AudioParam {
  external factory AudioParam();
}

extension AudioParamExtension on AudioParam {
  external num value;
}

@JS()
@staticInterop
class StereoPannerNode implements AudioNode {
  external factory StereoPannerNode();
}

extension StereoPannerNodeExtension on StereoPannerNode {
  external AudioParam get pan;
}

@JS()
@staticInterop
class MediaElementAudioSourceNode implements AudioNode {
  external factory MediaElementAudioSourceNode();
}
