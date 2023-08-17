import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

/// An Audio Context is a set of secondary, platform-specific aspects of audio
/// playback, typically related to how the act of playing audio interacts with
/// other features of the device. [AudioContext] is containing platform specific
/// configurations: [AudioContextAndroid] and [AudioContextIOS].
@immutable
class AudioContext {
  final AudioContextAndroid android;
  late final AudioContextIOS iOS;

  AudioContext({
    AudioContextAndroid? android,
    AudioContextIOS? iOS,
  }) : android = android ?? const AudioContextAndroid() {
    this.iOS = iOS ?? AudioContextIOS();
  }

  AudioContext copy({
    AudioContextAndroid? android,
    AudioContextIOS? iOS,
  }) {
    return AudioContext(
      android: android ?? this.android,
      iOS: iOS ?? this.iOS,
    );
  }

  Map<String, dynamic> toJson() {
    // we need to check web first because `defaultTargetPlatform` is not
    // available for web.
    if (kIsWeb) {
      return <String, dynamic>{};
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return android.toJson();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return iOS.toJson();
    } else {
      return <String, dynamic>{};
    }
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AudioContext &&
            runtimeType == other.runtimeType &&
            android == other.android &&
            iOS == other.iOS;
  }

  @override
  int get hashCode => Object.hash(
        android,
        iOS,
      );

  @override
  String toString() {
    return 'AudioContext('
        'android: $android, '
        'iOS: $iOS'
        ')';
  }
}

/// A platform-specific class to encapsulate a collection of attributes about an
/// Android audio stream.
@immutable
class AudioContextAndroid {
  /// Sets the speakerphone on or off, globally.
  ///
  /// This method should only be used by applications that replace the
  /// platform-wide management of audio settings or the main telephony
  /// application.
  final bool isSpeakerphoneOn;

  /// Sets the audio mode, globally.
  ///
  /// This method should only be used by applications that replace the
  /// platform-wide management of audio settings or the main telephony
  /// application, see [AndroidAudioMode].
  final AndroidAudioMode audioMode;

  final bool stayAwake;
  final AndroidContentType contentType;
  final AndroidUsageType usageType;
  final AndroidAudioFocus audioFocus;

  // Note when changing the defaults, it should also be changed in native code.
  const AudioContextAndroid({
    this.isSpeakerphoneOn = false,
    this.audioMode = AndroidAudioMode.normal,
    this.stayAwake = false,
    this.contentType = AndroidContentType.music,
    this.usageType = AndroidUsageType.media,
    this.audioFocus = AndroidAudioFocus.gain,
  });

  AudioContextAndroid copy({
    bool? isSpeakerphoneOn,
    AndroidAudioMode? audioMode,
    bool? stayAwake,
    AndroidContentType? contentType,
    AndroidUsageType? usageType,
    AndroidAudioFocus? audioFocus,
  }) {
    return AudioContextAndroid(
      isSpeakerphoneOn: isSpeakerphoneOn ?? this.isSpeakerphoneOn,
      audioMode: audioMode ?? this.audioMode,
      stayAwake: stayAwake ?? this.stayAwake,
      contentType: contentType ?? this.contentType,
      usageType: usageType ?? this.usageType,
      audioFocus: audioFocus ?? this.audioFocus,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isSpeakerphoneOn': isSpeakerphoneOn,
      'audioMode': audioMode.value,
      'stayAwake': stayAwake,
      'contentType': contentType.value,
      'usageType': usageType.value,
      'audioFocus': audioFocus.value,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AudioContextAndroid &&
            runtimeType == other.runtimeType &&
            isSpeakerphoneOn == other.isSpeakerphoneOn &&
            audioMode == other.audioMode &&
            stayAwake == other.stayAwake &&
            contentType == other.contentType &&
            usageType == other.usageType &&
            audioFocus == other.audioFocus;
  }

  @override
  int get hashCode => Object.hash(
        isSpeakerphoneOn,
        audioMode,
        stayAwake,
        contentType,
        usageType,
        audioFocus,
      );

  @override
  String toString() {
    return 'AudioContextAndroid('
        'isSpeakerphoneOn: $isSpeakerphoneOn, '
        'audioMode: $audioMode, '
        'stayAwake: $stayAwake, '
        'contentType: $contentType, '
        'usageType: $usageType, '
        'audioFocus: $audioFocus'
        ')';
  }
}

/// A platform-specific class to encapsulate a collection of attributes about an
/// iOS audio stream.
@immutable
class AudioContextIOS {
  final AVAudioSessionCategory category;
  final Set<AVAudioSessionOptions> options;

  // Note when changing the defaults, it should also be changed in native code.
  AudioContextIOS({
    this.category = AVAudioSessionCategory.playback,
    this.options = const {},
  })  : assert(
            category == AVAudioSessionCategory.playback ||
                category == AVAudioSessionCategory.playAndRecord ||
                category == AVAudioSessionCategory.multiRoute ||
                !options.contains(AVAudioSessionOptions.mixWithOthers),
            'You can set the option `mixWithOthers` explicitly only if the '
            'audio session category is `playAndRecord`, `playback`, or '
            '`multiRoute`.'),
        assert(
          category == AVAudioSessionCategory.playback ||
              category == AVAudioSessionCategory.playAndRecord ||
              category == AVAudioSessionCategory.multiRoute ||
              !options.contains(AVAudioSessionOptions.duckOthers),
          'You can set the option `duckOthers` explicitly only if the audio '
          'session category is `playAndRecord`, `playback`, or `multiRoute`.',
        ),
        assert(
            category == AVAudioSessionCategory.playback ||
                category == AVAudioSessionCategory.playAndRecord ||
                category == AVAudioSessionCategory.multiRoute ||
                !options.contains(
                  AVAudioSessionOptions.interruptSpokenAudioAndMixWithOthers,
                ),
            'You can set the option `interruptSpokenAudioAndMixWithOthers` '
            'explicitly only if the audio session category is `playAndRecord`, '
            '`playback`, or `multiRoute`.'),
        assert(
            category == AVAudioSessionCategory.playAndRecord ||
                category == AVAudioSessionCategory.record ||
                !options.contains(AVAudioSessionOptions.allowBluetooth),
            'You can set the option `allowBluetooth` explicitly only if the '
            'audio session category is `playAndRecord` or `record`.'),
        assert(
            category == AVAudioSessionCategory.playAndRecord ||
                category == AVAudioSessionCategory.record ||
                category == AVAudioSessionCategory.multiRoute ||
                !options.contains(AVAudioSessionOptions.allowBluetoothA2DP),
            'You can set the option `allowBluetoothA2DP` explicitly only if '
            'the audio session category is `playAndRecord`, `record`, or '
            '`multiRoute`.'),
        assert(
            category == AVAudioSessionCategory.playAndRecord ||
                !options.contains(AVAudioSessionOptions.allowAirPlay),
            'You can set the option `allowAirPlay` explicitly only if the '
            'audio session category is `playAndRecord`.'),
        assert(
            category == AVAudioSessionCategory.playAndRecord ||
                !options.contains(AVAudioSessionOptions.defaultToSpeaker),
            'You can set the option `defaultToSpeaker` explicitly only if the '
            'audio session category is `playAndRecord`.'),
        assert(
            category == AVAudioSessionCategory.playAndRecord ||
                category == AVAudioSessionCategory.record ||
                category == AVAudioSessionCategory.multiRoute ||
                !options.contains(
                  AVAudioSessionOptions.overrideMutedMicrophoneInterruption,
                ),
            'You can set the option `overrideMutedMicrophoneInterruption` '
            'explicitly only if the audio session category is `playAndRecord`, '
            '`record`, or `multiRoute`.');

  AudioContextIOS copy({
    AVAudioSessionCategory? category,
    Set<AVAudioSessionOptions>? options,
  }) {
    return AudioContextIOS(
      category: category ?? this.category,
      options: options ?? this.options,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'category': category.name,
      'options': options.map((e) => e.name).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AudioContextIOS &&
            runtimeType == other.runtimeType &&
            category == other.category &&
            const SetEquality().equals(options, other.options);
  }

  @override
  int get hashCode => Object.hash(
        category,
        options,
      );

  @override
  String toString() {
    return 'AudioContextIOS('
        'category: $category, '
        'options: $options'
        ')';
  }
}

/// "what" you are playing. The content type expresses the general category of
/// the content. This information is optional. But in case it is known (for
/// instance [movie] for a movie streaming service or [music] for a music
/// playback application) this information might be used by the audio framework
/// to selectively configure some audio post-processing blocks.
enum AndroidContentType {
  /// Content type value to use when the content type is unknown, or other than
  /// the ones defined.
  unknown(0),

  /// Content type value to use when the content type is speech.
  speech(1),

  /// Content type value to use when the content type is music.
  music(2),

  /// Content type value to use when the content type is a soundtrack, typically
  /// accompanying a movie or TV program.
  movie(3),

  /// Content type value to use when the content type is a sound used to
  /// accompany a user action, such as a beep or sound effect expressing a key
  /// click, or event, such as the type of a sound for a bonus being received in
  /// a game. These sounds are mostly synthesized or short Foley sounds.
  sonification(4);

  const AndroidContentType(this.value);

  factory AndroidContentType.fromInt(int value) {
    return values.firstWhere((e) => e.value == value);
  }

  final int value;
}

/// "why" you are playing a sound, what is this sound used for. This is achieved
/// with the "usage" information. Examples of usage are [media] and [alarm].
/// These two examples are the closest to stream types, but more detailed use
/// cases are available. Usage information is more expressive than a stream
/// type, and allows certain platforms or routing policies to use this
/// information for more refined volume or routing decisions. Usage is the most
/// important information to supply in [AudioContextAndroid] and it is
/// recommended to build any instance with this information supplied.
enum AndroidUsageType {
  /// Usage value to use when the usage is unknown.
  unknown(0),

  /// Usage value to use when the usage is media, such as music, or movie
  /// soundtracks.
  media(1),

  /// Usage value to use when the usage is voice communications, such as
  /// telephony or VoIP.
  voiceCommunication(2),

  /// Usage value to use when the usage is in-call signalling, such as with a
  /// "busy" beep, or DTMF tones.
  voiceCommunicationSignalling(3),

  /// Usage value to use when the usage is an alarm (e.g. wake-up alarm).
  alarm(4),

  /// Usage value to use when the usage is notification. See other notification
  /// usages for more specialized uses.
  notification(5),

  /// Usage value to use when the usage is telephony ringtone.
  notificationRingtone(6),

  /// Usage value to use when the usage is a request to enter/end a
  /// communication, such as a VoIP communication or video-conference.
  notificationCommunicationRequest(7),

  /// Usage value to use when the usage is notification for an "instant"
  /// communication such as a chat, or SMS.
  notificationCommunicationInstant(8),

  /// Usage value to use when the usage is notification for a non-immediate type
  /// of communication such as e-mail.
  notificationCommunicationDelayed(9),

  /// Usage value to use when the usage is to attract the user's attention, such
  /// as a reminder or low battery warning.
  notificationEvent(10),

  /// Usage value to use when the usage is for accessibility, such as with a
  /// screen reader.
  assistanceAccessibility(11),

  /// Usage value to use when the usage is driving or navigation directions.
  assistanceNavigationGuidance(12),

  /// Usage value to use when the usage is sonification, such as  with user
  /// interface sounds.
  assistanceSonification(13),

  /// Usage value to use when the usage is for game audio.
  game(14),

  /// @hide
  ///
  /// Usage value to use when feeding audio to the platform and replacing
  /// "traditional" audio source, such as audio capture devices.
  virtualSource(15),

  /// Usage value to use for audio responses to user queries, audio instructions
  /// or help utterances.
  assistant(16);

  const AndroidUsageType(this.value);

  factory AndroidUsageType.fromInt(int value) {
    return values.firstWhere((e) => e.value == value);
  }

  final int value;
}

/// There are four focus request types. A successful focus request with each
/// will yield different behaviors by the system and the other application that
/// previously held audio focus.
/// See https://developer.android.com/reference/android/media/AudioFocusRequest
enum AndroidAudioFocus {
  /// AudioManager#AUDIOFOCUS_NONE expresses that your app requests no audio
  /// focus.
  /// NOTE: Here it is used as replacement for an AudioFocus set to null, to
  /// make it more convenient to unset the focus again.
  /// Despite to the docs, AUDIOFOCUS_NONE is already present at API level 19.
  /// https://developer.android.com/reference/android/media/AudioManager#AUDIOFOCUS_NONE
  none(0),

  /// AudioManager#AUDIOFOCUS_GAIN expresses the fact that your application is
  /// now the sole source of audio that the user is listening to.
  /// The duration of the audio playback is unknown, and is possibly very long:
  /// after the user finishes interacting with your application, (s)he doesn't
  /// expect another audio stream to resume. Examples of uses of this focus gain
  /// are for music playback, for a game or a video player.
  gain(1),

  /// AudioManager#AUDIOFOCUS_GAIN_TRANSIENT is for a situation when you know
  /// your application is temporarily grabbing focus from the current owner,
  /// but the user expects playback to go back to where it was once your
  /// application no longer requires audio focus. An example is for playing an
  /// alarm, or during a VoIP call. The playback is known to be finite:
  /// the alarm will time-out or be dismissed, the VoIP call has a beginning and
  /// an end. When any of those events ends, and if the user was listening to
  /// music when it started, the user expects music to resume, but didn't wish
  /// to listen to both at the same time.
  gainTransient(2),

  /// AudioManager#AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK: this focus request type
  /// is similar to AUDIOFOCUS_GAIN_TRANSIENT for the temporary aspect of the
  /// focus request, but it also expresses the fact during the time you own
  /// focus, you allow another application to keep playing at a reduced volume,
  /// "ducked". Examples are when playing driving directions or notifications,
  /// it's ok for music to keep playing, but not loud enough that it would
  /// prevent the directions to be hard to understand. A typical attenuation by
  /// the "ducked" application is a factor of 0.2f (or -14dB), that can for
  /// instance be applied with MediaPlayer.setVolume(0.2f) when using this class
  /// for playback.
  gainTransientMayDuck(3),

  /// AudioManager#AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE is also for a temporary
  /// request, but also expresses that your application expects the device to
  /// not play anything else. This is typically used if you are doing audio
  /// recording or speech recognition, and don't want for examples notifications
  /// to be played by the system during that time.
  gainTransientExclusive(4);

  const AndroidAudioFocus(this.value);

  factory AndroidAudioFocus.fromInt(int value) {
    return values.firstWhere((e) => e.value == value);
  }

  final int value;
}

/// The audio mode encompasses audio routing AND the behavior of the telephony
/// layer. Therefore this flag should only be used by applications that
/// replace the platform-wide management of audio settings or the main telephony
/// application. In particular, the [inCall] mode should only be used by the
/// telephony application when it places a phone call, as it will cause signals
/// from the radio layer to feed the platform mixer.
enum AndroidAudioMode {
  /// Normal audio mode: not ringing and no call established.
  normal(0),

  /// Ringing audio mode. An incoming is being signaled.
  ringtone(1),

  /// In call audio mode. A telephony call is established.
  inCall(2),

  /// In communication audio mode. An audio/video chat or VoIP call is established.
  inCommunication(3),

  /// Call screening in progress. Call is connected and audio is accessible to
  /// call screening applications but other audio use cases are still possible.
  callScreening(4);

  const AndroidAudioMode(this.value);

  factory AndroidAudioMode.fromInt(int value) {
    return values.firstWhere((e) => e.value == value);
  }

  final int value;
}

/// This is a Dart representation of the equivalent enum on Swift.
///
/// Audio session category identifiers.
/// An audio session category defines a set of audio behaviors.
/// Choose a category that most accurately describes the audio behavior you
/// require.
enum AVAudioSessionCategory {
  /// Silenced by the Ring/Silent switch and by screen locking = Yes
  /// Interrupts nonmixable app’s audio = No
  /// Output only
  ambient,

  /// Silenced by the Ring/Silent switch and by screen locking = Yes
  /// Interrupts nonmixable app’s audio = Yes
  /// Output only
  /// This is the platform's default (not AP's default witch is playAndRecord).
  soloAmbient,

  /// Silenced by the Ring/Silent switch and by screen locking = No
  /// Interrupts nonmixable app’s audio = Yes by default; no by using override
  /// switch.
  /// Note: the switch is the `.mixWithOthers` option
  /// (+ other options like `.duckOthers`).
  /// Output only
  playback,

  /// Silenced by the Ring/Silent switch and by screen locking = No (recording
  /// continues with screen locked)
  /// Interrupts nonmixable app’s audio = Yes
  /// Input only
  record,

  /// Silenced by the Ring/Silent switch and by screen locking = No
  /// Interrupts nonmixable app’s audio = Yes by default; no by using override
  /// switch.
  /// Note: the switch is the `.mixWithOthers` option
  /// (+ other options like `.duckOthers`).
  /// Input and output
  playAndRecord,

  /// Silenced by the Ring/Silent switch and by screen locking = No
  /// Interrupts nonmixable app’s audio = Yes
  /// Input and output
  multiRoute,
}

/// This is a Dart representation of the equivalent enum on Swift.
///
/// Constants that specify optional audio behaviors. Each option is valid only
/// for specific audio session categories.
enum AVAudioSessionOptions {
  /// An option that indicates whether audio from this session mixes with audio
  /// from active sessions in other audio apps.
  /// You can set this option explicitly only if the audio session category is
  /// `playAndRecord`, `playback`, or `multiRoute`.
  /// If you set the audio session category to `ambient`, the session
  /// automatically sets this option. Likewise, setting the `duckOthers` or
  /// `interruptSpokenAudioAndMixWithOthers` options also enables this option.
  /// See: https://developer.apple.com/documentation/avfaudio/avaudiosession/categoryoptions/1616611-mixwithothers
  mixWithOthers,

  /// An option that reduces the volume of other audio sessions while audio from
  /// this session plays.
  /// You can set this option only if the audio session category is
  /// `playAndRecord`, `playback`, or `multiRoute`.
  /// Setting it implicitly sets the `mixWithOthers` option.
  /// https://developer.apple.com/documentation/avfaudio/avaudiosession/categoryoptions/1616618-duckothers
  duckOthers,

  /// An option that determines whether to pause spoken audio content from other
  /// sessions when your app plays its audio.
  /// You can set this option only if the audio session category is
  /// `playAndRecord`, `playback`, or `multiRoute`. Setting this option also
  /// sets `mixWithOthers`.
  /// See: https://developer.apple.com/documentation/avfaudio/avaudiosession/categoryoptions/1616534-interruptspokenaudioandmixwithot
  interruptSpokenAudioAndMixWithOthers,

  /// An option that determines whether Bluetooth hands-free devices appear as
  /// available input routes.
  /// You can set this option only if the audio session category is
  /// `playAndRecord` or `record`.
  /// See: https://developer.apple.com/documentation/avfaudio/avaudiosession/categoryoptions/1616518-allowbluetooth
  allowBluetooth,

  /// An option that determines whether you can stream audio from this session
  /// to Bluetooth devices that support the Advanced Audio Distribution Profile
  /// (A2DP).
  /// The system automatically routes to A2DP ports if you configure an app’s
  /// audio session to use the `ambient`, `soloAmbient`, or `playback`
  /// categories.
  /// See: https://developer.apple.com/documentation/avfaudio/avaudiosession/categoryoptions/1771735-allowbluetootha2dp
  allowBluetoothA2DP,

  /// An option that determines whether you can stream audio from this session
  /// to AirPlay devices.
  /// You can only explicitly set this option if the audio session’s category is
  /// set to `playAndRecord`.
  /// See: https://developer.apple.com/documentation/avfaudio/avaudiosession/categoryoptions/1771736-allowairplay
  allowAirPlay,

  /// An option that determines whether audio from the session defaults to the
  /// built-in speaker instead of the receiver.
  /// You can set this option only when using the `playAndRecord` category.
  /// See: https://developer.apple.com/documentation/avfaudio/avaudiosession/categoryoptions/1616462-defaulttospeaker
  defaultToSpeaker,

  /// An option that indicates whether the system interrupts the audio session
  /// when it mutes the built-in microphone.
  /// If your app uses an audio session category that supports input and output,
  /// such as `playAndRecord`, you can set this option to disable the default
  /// behavior and continue using the session.
  /// See: https://developer.apple.com/documentation/avfaudio/avaudiosession/categoryoptions/3727255-overridemutedmicrophoneinterrupt
  overrideMutedMicrophoneInterruption,
}
