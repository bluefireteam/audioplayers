import 'dart:io';

import 'package:flutter/foundation.dart';

/// Specify supported features for a platform.
class PlatformFeatures {
  static const webPlatformFeatures = PlatformFeatures(
    hasBytesSource: false,
    hasPlaylistSourceType: false,
    hasLowLatency: false,
    hasReleaseMode: false,
    hasSeek: false,
    hasDuckAudio: false,
    hasRespectSilence: false,
    hasStayAwake: false,
    hasRecordingActive: false,
    hasPlayingRoute: false,
    hasDurationEvent: false,
    hasCompletionEvent: false,
    hasErrorEvent: false,
  );

  static const androidPlatformFeatures = PlatformFeatures(
    hasRecordingActive: false,
  );

  static const iosPlatformFeatures = PlatformFeatures(
    hasBytesSource: false,
    hasPlaylistSourceType: false,
    hasLowLatency: false,
    hasDuckAudio: false,
  );

  static const macPlatformFeatures = PlatformFeatures(
    hasBytesSource: false,
    hasPlaylistSourceType: false,
    hasLowLatency: false,
    hasDuckAudio: false,
    hasRespectSilence: false,
    hasStayAwake: false,
    hasRecordingActive: false,
    hasPlayingRoute: false,
  );

  static const linuxPlatformFeatures = PlatformFeatures(
    hasBytesSource: false,
    hasLowLatency: false,
    hasMp3Duration: false,
    hasDuckAudio: false,
    hasRespectSilence: false,
    hasStayAwake: false,
    hasRecordingActive: false,
    hasPlayingRoute: false,
  );

  static const windowsPlatformFeatures = PlatformFeatures(
    hasBytesSource: false,
    hasLowLatency: false,
    hasDuckAudio: false,
    hasRespectSilence: false,
    hasStayAwake: false,
    hasRecordingActive: false,
    hasPlayingRoute: false,
  );

  final bool hasUrlSource;
  final bool hasAssetSource;
  final bool hasBytesSource;

  final bool hasPlaylistSourceType;

  final bool hasLowLatency; // Not yet tested
  final bool hasReleaseMode; // Not yet tested
  final bool hasVolume; // Not yet tested
  final bool hasSeek; // Not yet tested
  final bool hasMp3Duration; // Not yet tested

  final bool hasPlaybackRate; // Not yet tested
  final bool hasDuckAudio; // Not yet tested
  final bool hasRespectSilence; // Not yet tested
  final bool hasStayAwake; // Not yet tested
  final bool hasRecordingActive; // Not yet tested
  final bool hasPlayingRoute; // Not yet tested

  final bool hasDurationEvent;
  final bool hasPositionEvent;
  final bool hasCompletionEvent; // Not yet tested
  final bool hasErrorEvent; // Not yet tested

  const PlatformFeatures({
    this.hasUrlSource = true,
    this.hasAssetSource = true,
    this.hasBytesSource = true,
    this.hasPlaylistSourceType = true,
    this.hasLowLatency = true,
    this.hasReleaseMode = true,
    this.hasMp3Duration = true,
    this.hasVolume = true,
    this.hasSeek = true,
    this.hasPlaybackRate = true,
    this.hasDuckAudio = true,
    this.hasRespectSilence = true,
    this.hasStayAwake = true,
    this.hasRecordingActive = true,
    this.hasPlayingRoute = true,
    this.hasDurationEvent = true,
    this.hasPositionEvent = true,
    this.hasCompletionEvent = true,
    this.hasErrorEvent = true,
  });

  factory PlatformFeatures.instance() {
    return kIsWeb
        ? webPlatformFeatures
        : Platform.isAndroid
            ? androidPlatformFeatures
            : Platform.isIOS
                ? iosPlatformFeatures
                : Platform.isMacOS
                    ? macPlatformFeatures
                    : Platform.isLinux
                        ? linuxPlatformFeatures
                        : Platform.isWindows
                            ? windowsPlatformFeatures
                            : const PlatformFeatures();
  }
}
