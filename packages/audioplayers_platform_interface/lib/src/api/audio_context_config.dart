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
  /// built-in speakers or the earpiece, you can set this flag.
  /// See [AudioContextConfigRoute] for more details on the options.
  final AudioContextConfigRoute route;

  /// This flag determines how your audio interacts with other audio playing on
  /// the device.
  final AudioContextConfigFocus focus;

  /// Whether the "silent" mode of the device should be respected.
  ///
  /// When `false` (the default), audio will be played even if the device is in
  /// silent mode.
  /// When `true` and the device is in silent mode, audio will not be played.
  ///
  /// On Android, this will mandate the `USAGE_NOTIFICATION_RINGTONE` usage
  /// type.
  ///
  /// On iOS, setting this mandates the [AVAudioSessionCategory.ambient]
  /// category, and it will be:
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
  ///  * the category is [AVAudioSessionCategory.playAndRecord] (thus setting
  ///    this is forbidden when [respectSilence] is set)
  ///  * the UIBackgroundModes audio key has been added to your app’s
  ///    Info.plist (check our FAQ for more details on that)
  final bool stayAwake;

  AudioContextConfig({
    this.route = AudioContextConfigRoute.system,
    this.focus = AudioContextConfigFocus.gain,
    this.respectSilence = false,
    this.stayAwake = false,
  });

  AudioContextConfig copy({
    AudioContextConfigRoute? route,
    AudioContextConfigFocus? focus,
    bool? respectSilence,
    bool? stayAwake,
  }) {
    return AudioContextConfig(
      route: route ?? this.route,
      focus: focus ?? this.focus,
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
      isSpeakerphoneOn: route == AudioContextConfigRoute.speaker,
      stayAwake: stayAwake,
      usageType: respectSilence
          ? AndroidUsageType.notificationRingtone
          : (route == AudioContextConfigRoute.earpiece
              ? AndroidUsageType.voiceCommunication
              : AndroidUsageType.media),
      audioFocus: focus == AudioContextConfigFocus.gain
          ? AndroidAudioFocus.gain
          : (focus == AudioContextConfigFocus.duckOthers
              ? AndroidAudioFocus.gainTransientMayDuck
              : AndroidAudioFocus.none),
    );
  }

  AudioContextIOS? buildIOS() {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return null;
    }
    validateIOS();
    return AudioContextIOS(
      category: respectSilence
          ? AVAudioSessionCategory.ambient
          : (route == AudioContextConfigRoute.speaker
              ? AVAudioSessionCategory.playAndRecord
              : (route == AudioContextConfigRoute.earpiece
                  ? AVAudioSessionCategory.playAndRecord
                  : AVAudioSessionCategory.playback)),
      options: {
        if (focus == AudioContextConfigFocus.duckOthers)
          AVAudioSessionOptions.duckOthers,
        if (focus == AudioContextConfigFocus.mixWithOthers)
          AVAudioSessionOptions.mixWithOthers,
        if (route == AudioContextConfigRoute.speaker)
          AVAudioSessionOptions.defaultToSpeaker,
      },
    );
  }

  void validateIOS() {
    const invalidMsg =
        'Invalid AudioContextConfig: On iOS it is not possible to set';
    const tip = 'Please create a custom [AudioContextIOS] if the generic flags '
        'cannot represent your needs.';
    assert(
      !(respectSilence && focus == AudioContextConfigFocus.duckOthers),
      '$invalidMsg `respectSilence` and `duckOthers`. $tip',
    );
    assert(
      !(respectSilence && focus == AudioContextConfigFocus.mixWithOthers),
      '$invalidMsg `respectSilence` and `mixWithOthers`. $tip',
    );
    assert(
      !(respectSilence && route == AudioContextConfigRoute.speaker),
      '$invalidMsg `respectSilence` and route `speaker`. $tip',
    );
  }

  @override
  String toString() {
    return 'AudioContextConfig('
        'route: $route, '
        'focus: $focus, '
        'respectSilence: $respectSilence, '
        'stayAwake: $stayAwake'
        ')';
  }
}

enum AudioContextConfigRoute {
  /// Use the system's default route. This can be e.g. the built-in speaker, the
  /// earpiece, or a bluetooth device.
  system,

  /// On Android, this will set the usageType
  /// [AndroidUsageType.voiceCommunication].
  ///
  /// On iOS, this will set the category [AVAudioSessionCategory.playAndRecord].
  earpiece,

  /// On Android, this will set [AudioContextAndroid.isSpeakerphoneOn] to true.
  ///
  /// On iOS, this will set the option [AVAudioSessionOptions.defaultToSpeaker].
  /// Note that this forces the category to be
  /// [AVAudioSessionCategory.playAndRecord], and thus is forbidden when
  /// [AudioContextConfig.respectSilence] is set.
  speaker,
}

enum AudioContextConfigFocus {
  /// An option that expresses the fact that your application is
  /// now the sole source of audio that the user is listening to.
  ///
  /// On Android, this will set the focus [AndroidAudioFocus.gain].
  ///
  /// On iOS, this will not set any additional [AVAudioSessionOptions].
  gain,

  /// An option that reduces the volume of other audio sessions while audio from
  /// this session (like an alarm, gps, etc.) plays on top.
  ///
  /// On Android, this will make an Audio Focus request with
  /// [AndroidAudioFocus.gainTransientMayDuck] when your audio starts playing.
  ///
  /// On iOS, this will set the option [AVAudioSessionOptions.duckOthers]
  /// (the option [AVAudioSessionOptions.mixWithOthers] is set implicitly).
  /// Note that this forces the category to be
  /// [AVAudioSessionCategory.playAndRecord], and thus is forbidden when
  /// [AudioContextConfig.respectSilence] is set.
  duckOthers,

  /// An option that indicates whether audio from this session mixes with audio
  /// from active sessions in other audio apps.
  ///
  /// On Android, this will set the focus [AndroidAudioFocus.none].
  ///
  /// On iOS, this will set the option [AVAudioSessionOptions.mixWithOthers].
  mixWithOthers,
}
