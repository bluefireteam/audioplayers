TODO(luan): figure this stuff out for web!

# Android

Android has 3 configuration attributes:

```kotlin
val respectSilence = call.argument<Boolean>("respectSilence") ?: false
val stayAwake = call.argument<Boolean>("stayAwake") ?: false
val duckAudio = call.argument<Boolean>("duckAudio") ?: false
```

And of course the `playingRoute` enum.

## stayAwake

When set, call set the `setWakeMode` method on the player:

```kotlin
player?.setWakeMode(ref.getApplicationContext(), PowerManager.PARTIAL_WAKE_LOCK)
```

## duckAudio

When start playing, make a focus request with `AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK`:

```kotlin
override fun play() {
    if (duckAudio) {
        val audioManager = audioManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val audioFocusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
                    .setAudioAttributes(
                            AudioAttributes.Builder()
                                    .setUsage(if (respectSilence) AudioAttributes.USAGE_NOTIFICATION_RINGTONE else AudioAttributes.USAGE_MEDIA)
                                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                                    .build()
                    )
                    .setOnAudioFocusChangeListener { actuallyPlay() }.build()
            this.audioFocusRequest = audioFocusRequest
            audioManager.requestAudioFocus(audioFocusRequest)
        } else {
            // Request audio focus for playback
            @Suppress("DEPRECATION")
            val result = audioManager.requestAudioFocus(audioFocusChangeListener,  // Use the music stream.
                    AudioManager.STREAM_MUSIC,  // Request permanent focus.
                    AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
            if (result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
                actuallyPlay()
            }
        }
    } else {
        actuallyPlay()
    }
}
```

## respectSilence & playingRoute

These are considered together when set and have very different method calls for current and obsolete android:

### Current Android

Configuration method:

```kotlin
val usage = when {
    // Works with bluetooth headphones
    // automatically switch to earpiece when disconnect bluetooth headphones
    playingRoute != "speakers" -> AudioAttributes.USAGE_VOICE_COMMUNICATION
    respectSilence -> AudioAttributes.USAGE_NOTIFICATION_RINGTONE
    else -> AudioAttributes.USAGE_MEDIA
}
player.setAudioAttributes(
        AudioAttributes.Builder()
                .setUsage(usage)
                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                .build()
)
if (usage == AudioAttributes.USAGE_VOICE_COMMUNICATION) {
    audioManager.isSpeakerphoneOn = false
}
```

#### audioManager.isSpeakerphoneOn

Boolean

#### Content Type

```
    /**
     * Content type value to use when the content type is unknown, or other than the ones defined.
     */
    public final static int CONTENT_TYPE_UNKNOWN = 0;
    /**
     * Content type value to use when the content type is speech.
     */
    public final static int CONTENT_TYPE_SPEECH = 1;
    /**
     * Content type value to use when the content type is music.
     */
    public final static int CONTENT_TYPE_MUSIC = 2;
    /**
     * Content type value to use when the content type is a soundtrack, typically accompanying
     * a movie or TV program.
     */
    public final static int CONTENT_TYPE_MOVIE = 3;
    /**
     * Content type value to use when the content type is a sound used to accompany a user
     * action, such as a beep or sound effect expressing a key click, or event, such as the
     * type of a sound for a bonus being received in a game. These sounds are mostly synthesized
     * or short Foley sounds.
     */
    public final static int CONTENT_TYPE_SONIFICATION = 4;
```

#### Usage Type

```java
    /**
     * Usage value to use when the usage is unknown.
     */
    public final static int USAGE_UNKNOWN = 0;
    /**
     * Usage value to use when the usage is media, such as music, or movie
     * soundtracks.
     */
    public final static int USAGE_MEDIA = 1;
    /**
     * Usage value to use when the usage is voice communications, such as telephony
     * or VoIP.
     */
    public final static int USAGE_VOICE_COMMUNICATION = 2;
    /**
     * Usage value to use when the usage is in-call signalling, such as with
     * a "busy" beep, or DTMF tones.
     */
    public final static int USAGE_VOICE_COMMUNICATION_SIGNALLING = 3;
    /**
     * Usage value to use when the usage is an alarm (e.g. wake-up alarm).
     */
    public final static int USAGE_ALARM = 4;
    /**
     * Usage value to use when the usage is notification. See other
     * notification usages for more specialized uses.
     */
    public final static int USAGE_NOTIFICATION = 5;
    /**
     * Usage value to use when the usage is telephony ringtone.
     */
    public final static int USAGE_NOTIFICATION_RINGTONE = 6;
    /**
     * Usage value to use when the usage is a request to enter/end a
     * communication, such as a VoIP communication or video-conference.
     */
    public final static int USAGE_NOTIFICATION_COMMUNICATION_REQUEST = 7;
    /**
     * Usage value to use when the usage is notification for an "instant"
     * communication such as a chat, or SMS.
     */
    public final static int USAGE_NOTIFICATION_COMMUNICATION_INSTANT = 8;
    /**
     * Usage value to use when the usage is notification for a
     * non-immediate type of communication such as e-mail.
     */
    public final static int USAGE_NOTIFICATION_COMMUNICATION_DELAYED = 9;
    /**
     * Usage value to use when the usage is to attract the user's attention,
     * such as a reminder or low battery warning.
     */
    public final static int USAGE_NOTIFICATION_EVENT = 10;
    /**
     * Usage value to use when the usage is for accessibility, such as with
     * a screen reader.
     */
    public final static int USAGE_ASSISTANCE_ACCESSIBILITY = 11;
    /**
     * Usage value to use when the usage is driving or navigation directions.
     */
    public final static int USAGE_ASSISTANCE_NAVIGATION_GUIDANCE = 12;
    /**
     * Usage value to use when the usage is sonification, such as  with user
     * interface sounds.
     */
    public final static int USAGE_ASSISTANCE_SONIFICATION = 13;
    /**
     * Usage value to use when the usage is for game audio.
     */
    public final static int USAGE_GAME = 14;
    /**
     * @hide
     * Usage value to use when feeding audio to the platform and replacing "traditional" audio
     * source, such as audio capture devices.
     */
    public final static int USAGE_VIRTUAL_SOURCE = 15;
    /**
     * Usage value to use for audio responses to user queries, audio instructions or help
     * utterances.
     */
    public final static int USAGE_ASSISTANT = 16;
```

#### Audio Focus

```java
/**
 * Used to indicate no audio focus has been gained or lost, or requested.
 */
public static final int AUDIOFOCUS_NONE = 0;

/**
 * Used to indicate a gain of audio focus, or a request of audio focus, of unknown duration.
 * @see OnAudioFocusChangeListener#onAudioFocusChange(int)
 * @see #requestAudioFocus(OnAudioFocusChangeListener, int, int)
 */
public static final int AUDIOFOCUS_GAIN = 1;
/**
 * Used to indicate a temporary gain or request of audio focus, anticipated to last a short
 * amount of time. Examples of temporary changes are the playback of driving directions, or an
 * event notification.
 * @see OnAudioFocusChangeListener#onAudioFocusChange(int)
 * @see #requestAudioFocus(OnAudioFocusChangeListener, int, int)
 */
public static final int AUDIOFOCUS_GAIN_TRANSIENT = 2;
/**
 * Used to indicate a temporary request of audio focus, anticipated to last a short
 * amount of time, and where it is acceptable for other audio applications to keep playing
 * after having lowered their output level (also referred to as "ducking").
 * Examples of temporary changes are the playback of driving directions where playback of music
 * in the background is acceptable.
 * @see OnAudioFocusChangeListener#onAudioFocusChange(int)
 * @see #requestAudioFocus(OnAudioFocusChangeListener, int, int)
 */
public static final int AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK = 3;
/**
 * Used to indicate a temporary request of audio focus, anticipated to last a short
 * amount of time, during which no other applications, or system components, should play
 * anything. Examples of exclusive and transient audio focus requests are voice
 * memo recording and speech recognition, during which the system shouldn't play any
 * notifications, and media playback should have paused.
 * @see #requestAudioFocus(OnAudioFocusChangeListener, int, int)
 */
public static final int AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE = 4;
```

### Old Android

#### Stream Type

```java
    /** Used to identify the volume of audio streams for phone calls */
    public static final int STREAM_VOICE_CALL = AudioSystem.STREAM_VOICE_CALL;
    /** Used to identify the volume of audio streams for system sounds */
    public static final int STREAM_SYSTEM = AudioSystem.STREAM_SYSTEM;
    /** Used to identify the volume of audio streams for the phone ring */
    public static final int STREAM_RING = AudioSystem.STREAM_RING;
    /** Used to identify the volume of audio streams for music playback */
    public static final int STREAM_MUSIC = AudioSystem.STREAM_MUSIC;
    /** Used to identify the volume of audio streams for alarms */
    public static final int STREAM_ALARM = AudioSystem.STREAM_ALARM;
    /** Used to identify the volume of audio streams for notifications */
    public static final int STREAM_NOTIFICATION = AudioSystem.STREAM_NOTIFICATION;
    /** @hide Used to identify the volume of audio streams for phone calls when connected
     *        to bluetooth */
    public static final int STREAM_BLUETOOTH_SCO = AudioSystem.STREAM_BLUETOOTH_SCO;
    /** @hide Used to identify the volume of audio streams for enforced system sounds
     *        in certain countries (e.g camera in Japan) */
    public static final int STREAM_SYSTEM_ENFORCED = AudioSystem.STREAM_SYSTEM_ENFORCED;
    /** Used to identify the volume of audio streams for DTMF Tones */
    public static final int STREAM_DTMF = AudioSystem.STREAM_DTMF;
    /** @hide Used to identify the volume of audio streams exclusively transmitted through the
     *        speaker (TTS) of the device */
    public static final int STREAM_TTS = AudioSystem.STREAM_TTS;
    /** Used to identify the volume of audio streams for accessibility prompts */
    public static final int STREAM_ACCESSIBILITY = AudioSystem.STREAM_ACCESSIBILITY;
```

# iOS

In iOS `respectSilence` is called `isNotification`. It also has no `stayAwake` but has a new `recordingActive` parameter.

```swift
    isNotification: respectSilence,
    recordingActive: recordingActive,
    duckAudio: duckAudio
```

And of course the `playingRoute` enum.

```swift
    func updateCategory(
        recordingActive: Bool,
        isNotification: Bool,
        playingRoute: String,
        duckAudio: Bool
    ) {
        #if os(iOS)
        // When using AVAudioSessionCategoryPlayback, by default, this implies that your app’s audio is nonmixable—activating your session
        // will interrupt any other audio sessions which are also nonmixable. AVAudioSessionCategoryPlayback should not be used with
        // AVAudioSessionCategoryOptionMixWithOthers option. If so, it prevents infoCenter from working correctly.
        let category = (playingRoute == "earpiece" || recordingActive) ? AVAudioSession.Category.playAndRecord : (
            isNotification ? AVAudioSession.Category.ambient : AVAudioSession.Category.playback
        )
        let options = isNotification || duckAudio ? AVAudioSession.CategoryOptions.mixWithOthers : []
        
        configureAudioSession(category: category, options: options)
        if isNotification {
            UIApplication.shared.beginReceivingRemoteControlEvents()
        }
        #endif
    }
```

```swift
    func maybeDeactivateAudioSession() {
        let hasPlaying = players.values.contains { player in player.isPlaying }
        if !hasPlaying {
            #if os(iOS)
            configureAudioSession(active: false)
            #endif
        }
    }
```

```swift
    func setPlayingRoute(playerId: String, playingRoute: String) {
        let wrappedPlayer = players[playerId]!
        wrappedPlayer.playingRoute = playingRoute
        
        let category = playingRoute == "earpiece" ? AVAudioSession.Category.playAndRecord : AVAudioSession.Category.playback
        configureAudioSession(category: category)
    }
    
    private func configureAudioSession(
        category: AVAudioSession.Category? = nil,
        options: AVAudioSession.CategoryOptions = [],
        active: Bool? = nil
    ) {
        do {
            let session = AVAudioSession.sharedInstance()
            if let category = category {
                try session.setCategory(category, options: options)
            }
            if let active = active {
                try session.setActive(active)
            }
        } catch {
            Logger.error("Error configuring audio session: %@", error)
        }
    }
```