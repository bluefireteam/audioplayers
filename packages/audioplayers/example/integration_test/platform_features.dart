import 'package:flutter/foundation.dart';

/// Specify supported features for a platform.
class PlatformFeatures {
  static const webPlatformFeatures = PlatformFeatures(
    hasPlaylistSourceType: false,
    hasLowLatency: false,
    hasReleaseModeRelease: false,
    hasForceSpeaker: false,
    hasDuckAudio: false,
    hasRespectSilence: false,
    hasStayAwake: false,
    hasRecordingActive: false,
    hasPlayingRoute: false,
    hasErrorEvent: false,
  );

  static const androidPlatformFeatures = PlatformFeatures(
    hasRecordingActive: false,
  );

  static const iosPlatformFeatures = PlatformFeatures(
    hasDataUriSource: false,
    hasBytesSource: false,
    hasPlaylistSourceType: false,
    hasReleaseModeRelease: false,
    hasLowLatency: false,
    hasBalance: false,
  );

  static const macPlatformFeatures = PlatformFeatures(
    hasDataUriSource: false,
    hasBytesSource: false,
    hasPlaylistSourceType: false,
    hasLowLatency: false,
    hasReleaseModeRelease: false,
    hasForceSpeaker: false,
    hasDuckAudio: false,
    hasRespectSilence: false,
    hasStayAwake: false,
    hasRecordingActive: false,
    hasPlayingRoute: false,
    hasBalance: false,
  );

  static const linuxPlatformFeatures = PlatformFeatures(
    hasDataUriSource: false,
    hasBytesSource: false,
    hasLowLatency: false,
    hasReleaseModeRelease: false,
    // MP3 duration is estimated: https://bugzilla.gnome.org/show_bug.cgi?id=726144
    // Use GstDiscoverer to get duration before playing: https://gstreamer.freedesktop.org/documentation/pbutils/gstdiscoverer.html?gi-language=c
    hasMp3Duration: false,
    hasForceSpeaker: false,
    hasDuckAudio: false,
    hasRespectSilence: false,
    hasStayAwake: false,
    hasRecordingActive: false,
    hasPlayingRoute: false,
  );

  static const windowsPlatformFeatures = PlatformFeatures(
    hasDataUriSource: false,
    hasPlaylistSourceType: false,
    hasLowLatency: false,
    hasReleaseModeRelease: false,
    hasForceSpeaker: false,
    hasDuckAudio: false,
    hasRespectSilence: false,
    hasStayAwake: false,
    hasRecordingActive: false,
    hasPlayingRoute: false,
  );

  final bool hasUrlSource;
  final bool hasDataUriSource;
  final bool hasAssetSource;
  final bool hasBytesSource;

  final bool hasPlaylistSourceType;

  final bool hasLowLatency;
  final bool hasReleaseModeRelease;
  final bool hasReleaseModeLoop;
  final bool hasVolume;
  final bool hasBalance;
  final bool hasSeek;
  final bool hasMp3Duration;

  final bool hasPlaybackRate;
  final bool hasForceSpeaker; // Not yet tested
  final bool hasDuckAudio; // Not yet tested
  final bool hasRespectSilence;
  final bool hasStayAwake; // Not yet tested
  final bool hasRecordingActive; // Not yet tested
  final bool hasPlayingRoute; // Not yet tested

  final bool hasDurationEvent;
  final bool hasPlayerStateEvent;
  final bool hasErrorEvent; // Not yet tested

  const PlatformFeatures({
    this.hasUrlSource = true,
    this.hasDataUriSource = true,
    this.hasAssetSource = true,
    this.hasBytesSource = true,
    this.hasPlaylistSourceType = true,
    this.hasLowLatency = true,
    this.hasReleaseModeRelease = true,
    this.hasReleaseModeLoop = true,
    this.hasMp3Duration = true,
    this.hasVolume = true,
    this.hasBalance = true,
    this.hasSeek = true,
    this.hasPlaybackRate = true,
    this.hasForceSpeaker = true,
    this.hasDuckAudio = true,
    this.hasRespectSilence = true,
    this.hasStayAwake = true,
    this.hasRecordingActive = true,
    this.hasPlayingRoute = true,
    this.hasDurationEvent = true,
    this.hasPlayerStateEvent = true,
    this.hasErrorEvent = true,
  });

  factory PlatformFeatures.instance() {
    return kIsWeb
        ? webPlatformFeatures
        : defaultTargetPlatform == TargetPlatform.android
            ? androidPlatformFeatures
            : defaultTargetPlatform == TargetPlatform.iOS
                ? iosPlatformFeatures
                : defaultTargetPlatform == TargetPlatform.macOS
                    ? macPlatformFeatures
                    : defaultTargetPlatform == TargetPlatform.linux
                        ? linuxPlatformFeatures
                        : defaultTargetPlatform == TargetPlatform.windows
                            ? windowsPlatformFeatures
                            : const PlatformFeatures();
  }
}
