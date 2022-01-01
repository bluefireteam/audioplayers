import 'playing_route.dart';

class AudioContextConfig {
  bool respectSilence = false;
  bool stayAwake = false;
  bool duckAudio = false;
  bool recordingActive = false;
  PlayingRoute playingRoute = PlayingRoute.speakers;
}
