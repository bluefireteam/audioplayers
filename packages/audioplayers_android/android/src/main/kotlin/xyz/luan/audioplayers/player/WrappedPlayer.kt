package xyz.luan.audioplayers.player

import android.content.Context
import android.media.AudioManager
import android.media.MediaPlayer
import xyz.luan.audioplayers.AudioContextAndroid
import xyz.luan.audioplayers.AudioplayersPlugin
import xyz.luan.audioplayers.EventHandler
import xyz.luan.audioplayers.PlayerMode
import xyz.luan.audioplayers.PlayerMode.LOW_LATENCY
import xyz.luan.audioplayers.PlayerMode.MEDIA_PLAYER
import xyz.luan.audioplayers.ReleaseMode
import xyz.luan.audioplayers.source.Source
import kotlin.math.min

// For some reason this cannot be accessed from MediaPlayer.MEDIA_ERROR_SYSTEM
private const val MEDIA_ERROR_SYSTEM = -2147483648

class WrappedPlayer internal constructor(
    private val ref: AudioplayersPlugin,
    val eventHandler: EventHandler,
    var context: AudioContextAndroid,
    private val soundPoolManager: SoundPoolManager,
) {
    private var player: Player? = null

    var source: Source? = null
        set(value) {
            if (field != value) {
                if (value != null) {
                    val player = getOrCreatePlayer()
                    player.setSource(value)
                    player.configAndPrepare()
                } else {
                    released = true
                    prepared = false
                    playing = false
                    player?.release()
                }
                field = value
            } else {
                ref.handlePrepared(this, true)
            }
        }

    var volume = 1.0f
        set(value) {
            if (field != value) {
                field = value
                if (!released) {
                    player?.setVolumeAndBalance(value, balance)
                }
            }
        }

    var balance = 0.0f
        set(value) {
            if (field != value) {
                field = value
                if (!released) {
                    player?.setVolumeAndBalance(volume, value)
                }
            }
        }

    var rate = 1.0f
        set(value) {
            if (field != value) {
                field = value
                if (playing) {
                    player?.setRate(value)
                }
            }
        }

    var releaseMode = ReleaseMode.RELEASE
        set(value) {
            if (field != value) {
                field = value
                if (!released) {
                    player?.setLooping(isLooping)
                }
            }
        }

    val isLooping: Boolean
        get() = releaseMode == ReleaseMode.LOOP

    var playerMode: PlayerMode = MEDIA_PLAYER
        set(value) {
            if (field != value) {
                field = value

                // if the player exists, we need to re-create it from scratch;
                // this will probably cause music to pause for a second
                player?.let {
                    shouldSeekTo = maybeGetCurrentPosition()
                    prepared = false
                    it.release()
                }
                initPlayer()
            }
        }

    var released = true

    var prepared: Boolean = false
        set(value) {
            if (field != value) {
                field = value
                ref.handlePrepared(this, value)
            }
        }

    var playing = false
    var shouldSeekTo = -1

    private val focusManager = FocusManager(this)

    private fun maybeGetCurrentPosition(): Int {
        // for Sound Pool, we can't get current position, so we just start over
        return runCatching { player?.getCurrentPosition().takeUnless { it == 0 } }.getOrNull() ?: -1
    }

    private fun getOrCreatePlayer(): Player {
        val currentPlayer = player
        return if (released || currentPlayer == null) {
            createPlayer().also {
                player = it
                released = false
            }
        } else if (prepared) {
            currentPlayer.also {
                it.reset()
                prepared = false
            }
        } else {
            currentPlayer
        }
    }

    fun updateAudioContext(audioContext: AudioContextAndroid) {
        if (context == audioContext) {
            return
        }
        if (context.audioFocus != AudioManager.AUDIOFOCUS_NONE &&
            audioContext.audioFocus == AudioManager.AUDIOFOCUS_NONE
        ) {
            focusManager.handleStop()
        }
        this.context = audioContext.copy()

        // AudioManager values are set globally
        audioManager.mode = context.audioMode
        audioManager.isSpeakerphoneOn = context.isSpeakerphoneOn

        player?.let { p ->
            p.stop()
            prepared = false
            // Context is only applied, once the player.reset() was called
            p.updateContext(context)
            source?.let {
                p.setSource(it)
                p.configAndPrepare()
            }
        }
    }

    // Getters

    /**
     * Returns the duration of the media in milliseconds, if available.
     */
    fun getDuration(): Int? {
        return if (prepared) player?.getDuration() else null
    }

    /**
     * Returns the current position of the playback in milliseconds, if available.
     */
    fun getCurrentPosition(): Int? {
        return if (prepared) player?.getCurrentPosition() else null
    }

    val applicationContext: Context
        get() = ref.getApplicationContext()

    val audioManager: AudioManager
        get() = ref.getAudioManager()

    /**
     * Playback handling methods
     */
    fun play() {
        focusManager.maybeRequestAudioFocus(andThen = ::actuallyPlay)
    }

    private fun actuallyPlay() {
        if (!playing && !released) {
            val currentPlayer = player
            playing = true
            if (currentPlayer == null) {
                initPlayer()
            } else if (prepared) {
                currentPlayer.start()
            }
        }
    }

    fun stop() {
        focusManager.handleStop()
        if (released) {
            return
        }
        if (releaseMode != ReleaseMode.RELEASE) {
            pause()
            if (prepared) {
                if (player?.isLiveStream() == true) {
                    player?.stop()
                    prepared = false
                    player?.prepare()
                } else {
                    // MediaPlayer does not allow to call player.seekTo after calling player.stop
                    seek(0)
                }
            }
        } else {
            release()
        }
    }

    fun release() {
        focusManager.handleStop()
        if (released) {
            return
        }
        if (playing) {
            player?.stop()
        }

        // Setting source to null will reset released, prepared and playing
        // and also calls player.release()
        source = null
        player = null
    }

    fun pause() {
        if (playing) {
            playing = false
            if (prepared) {
                player?.pause()
            }
        }
    }

    // seek operations cannot be called until after
    // the player is ready.
    fun seek(position: Int) {
        shouldSeekTo = if (prepared && player?.isLiveStream() != true) {
            player?.seekTo(position)
            -1
        } else {
            position
        }
    }

    /**
     * Player callbacks
     */
    fun onPrepared() {
        prepared = true
        ref.handleDuration(this)
        if (playing) {
            player?.start()
        }
        if (shouldSeekTo >= 0 && player?.isLiveStream() != true) {
            player?.seekTo(shouldSeekTo)
        }
    }

    fun onCompletion() {
        if (releaseMode != ReleaseMode.LOOP) {
            stop()
        }
        ref.handleComplete(this)
    }

    @Suppress("UNUSED_PARAMETER")
    fun onBuffering(percent: Int) {
        // TODO(luan): expose this as a stream
    }

    fun onSeekComplete() {
        ref.handleSeekComplete(this)
    }

    fun handleLog(message: String) {
        ref.handleLog(this, message)
    }

    fun handleError(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
        ref.handleError(this, errorCode, errorMessage, errorDetails)
    }

    fun onError(what: Int, extra: Int): Boolean {
        val whatMsg = if (what == MediaPlayer.MEDIA_ERROR_SERVER_DIED) {
            "MEDIA_ERROR_SERVER_DIED"
        } else {
            "MEDIA_ERROR_UNKNOWN {what:$what}"
        }
        val extraMsg = when (extra) {
            MEDIA_ERROR_SYSTEM -> "MEDIA_ERROR_SYSTEM"
            MediaPlayer.MEDIA_ERROR_IO -> "MEDIA_ERROR_IO"
            MediaPlayer.MEDIA_ERROR_MALFORMED -> "MEDIA_ERROR_MALFORMED"
            MediaPlayer.MEDIA_ERROR_UNSUPPORTED -> "MEDIA_ERROR_UNSUPPORTED"
            MediaPlayer.MEDIA_ERROR_TIMED_OUT -> "MEDIA_ERROR_TIMED_OUT"
            else -> "MEDIA_ERROR_UNKNOWN {extra:$extra}"
        }
        if (!prepared && extraMsg == "MEDIA_ERROR_SYSTEM") {
            handleError(
                "AndroidAudioError",
                "Failed to set source. For troubleshooting, see: " +
                    "https://github.com/bluefireteam/audioplayers/blob/main/troubleshooting.md",
                "$whatMsg, $extraMsg",
            )
        } else {
            // When an error occurs, reset player to not [prepared].
            // Then no functions will be called, which end up in an illegal player state.
            prepared = false
            handleError("AndroidAudioError", whatMsg, extraMsg)
        }
        return false
    }

    /**
     * Internal logic. Private methods
     */

    /**
     * Create new player
     */
    private fun createPlayer(): Player {
        return when (playerMode) {
            MEDIA_PLAYER -> MediaPlayerPlayer(this)
            LOW_LATENCY -> SoundPoolPlayer(this, soundPoolManager)
        }
    }

    /**
     * Create new player, assign and configure source
     */
    private fun initPlayer() {
        val player = createPlayer()
        // Need to set player before calling prepare, as onPrepared may is called before player is assigned
        this.player = player
        source?.let {
            player.setSource(it)
            player.configAndPrepare()
        }
    }

    private fun Player.configAndPrepare() {
        setVolumeAndBalance(volume, balance)
        setLooping(isLooping)
        prepare()
    }

    private fun Player.setVolumeAndBalance(volume: Float, balance: Float) {
        val leftVolume = min(1f, 1f - balance) * volume
        val rightVolume = min(1f, 1f + balance) * volume
        setVolume(leftVolume, rightVolume)
    }

    fun dispose() {
        release()
        eventHandler.dispose()
    }
}
