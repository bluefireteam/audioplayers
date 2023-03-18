import 'package:audioplayers_platform_interface/src/api/audio_context.dart';
import 'package:flutter/foundation.dart';

/// This class contains flags to control several secondary, platform-specific
/// aspects of audio playback, like how this audio interact with other audios,
/// how is it played by the device and what happens when the app is
/// backgrounded.
/// However, note that each platform has its nuances on how to configure audio.
/// This class is a generic abstraction of some parameters that can be useful
/// across the board.
/// Its flags are simple abstractions that are then translated to an
/// [AudioContext] containing platform specific configurations:
/// [AudioContextAndroid] and [AudioContextIOS].
/// If these simplified flags cannot fully reflect your goals, you must create
/// an [AudioContext] configuring each platform separately.
class AudioContextConfig {
  /// Normally, audio played will respect the devices configured preferences.
  /// However, if you want to bypass that and flag the system to use the
  /// built-in speakers, you can set this flag.
  ///
  /// On android, it will set `audioManager.isSpeakerphoneOn`.
  ///
  /// On iOS, it will either:
  ///
  /// * set the `.defaultToSpeaker` option OR
  /// * call `overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)`
  ///
  /// Note that, on iOS, this forces the category to be `.playAndRecord`, and
  /// thus is forbidden when [respectSilence] is set.
  final bool forceSpeaker;

  /// This flag determines how your audio interacts with other audio playing on
  /// the device.
  /// If your audio is playing, and another audio plays on top (like an alarm,
  /// gps, etc), this determines what happens with your audio.
  ///
  /// On Android, this will make an Audio Focus request with
  /// AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK when your audio starts playing.
  ///
  /// On iOS, this will set the option `.duckOthers` option
  /// (the option `.mixWithOthers` is always set, regardless of these flags).
  /// Note that, on iOS, this forces the category to be `.playAndRecord`, and
  /// thus is forbidden when [respectSilence] is set.
  final bool duckAudio;

  /// Whether the "silent" mode of the device should be respect.
  /// By default (false), if the device is on silent mode, the audio will not be
  /// played.
  ///
  /// On Android, this will mandate the `USAGE_NOTIFICATION_RINGTONE` usage
  /// type.
  ///
  /// On iOS, setting this mandates the `.ambient` category, and it will be:
  ///  * silenced by rings
  ///  * silenced by the Silent switch
  ///  * silenced by screen locking (note: read [stayAwake] for details on
  ///    this).
  final bool respectSilence;

  /// By default, when the screen is locked, all the app's processing stops,
  /// including audio playback.
  /// You can set this flag to keep your audio playing even when locked.
  ///
  /// On Android, this sets the player "wake mode" to `PARTIAL_WAKE_LOCK`.
  ///
  /// On iOS, this will happen automatically as long as:
  ///  * the category is `.playAndRecord` (thus setting this is forbidden when
  ///    [respectSilence] is set)
  ///  * the UIBackgroundModes audio key has been added to your app’s
  ///    Info.plist (check our FAQ for more details on that)
  final bool stayAwake;

  AudioContextConfig({
    this.forceSpeaker = true,
    this.duckAudio = false,
    this.respectSilence = false,
    this.stayAwake = true,
  });

  AudioContextConfig copy({
    bool? forceSpeaker,
    bool? duckAudio,
    bool? respectSilence,
    bool? stayAwake,
  }) {
    return AudioContextConfig(
      forceSpeaker: forceSpeaker ?? this.forceSpeaker,
      duckAudio: duckAudio ?? this.duckAudio,
      respectSilence: respectSilence ?? this.respectSilence,
      stayAwake: stayAwake ?? this.stayAwake,
    );
  }

  AudioContext build() {
    return AudioContext(
      android: buildAndroid(),
      iOS: buildIOS(),
    );
  }

  AudioContextAndroid buildAndroid() {
    return AudioContextAndroid(
      isSpeakerphoneOn: forceSpeaker,
      stayAwake: stayAwake,
      usageType: respectSilence
          ? AndroidUsageType.notificationRingtone
          : AndroidUsageType.media,
      audioFocus: duckAudio
          ? AndroidAudioFocus.gainTransientMayDuck
          : AndroidAudioFocus.gain,
    );
  }

  AudioContextIOS buildIOS() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      validateIOS();
    }
    return AudioContextIOS(
      category: respectSilence
          ? AVAudioSessionCategory.ambient
          : AVAudioSessionCategory.playback,
      options: [AVAudioSessionOptions.mixWithOthers] +
          (duckAudio ? [AVAudioSessionOptions.duckOthers] : []) +
          (forceSpeaker ? [AVAudioSessionOptions.defaultToSpeaker] : []),
    );
  }

  void validateIOS() {
    // Please create a custom [AudioContextIOS] if the generic flags cannot
    // represent your needs.
    if (respectSilence && forceSpeaker) {
      throw 'On iOS it is impossible to set both respectSilence and '
          'forceSpeaker';
    }
  }
}
