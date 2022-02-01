package xyz.luan.audioplayers.player

import android.content.Context
import android.media.AudioManager
import android.media.MediaDataSource
import android.media.MediaPlayer
import android.os.Build
import android.os.PowerManager
import xyz.luan.audioplayers.AudioContextAndroid
import xyz.luan.audioplayers.AudioplayersPlugin
import xyz.luan.audioplayers.ReleaseMode

// For some reason this cannot be accessed from MediaPlayer.MEDIA_ERROR_SYSTEM
private const val MEDIA_ERROR_SYSTEM = -2147483648

class WrappedMediaPlayer internal constructor(
    private val ref: AudioplayersPlugin,
    override val playerId: String,
    var context: AudioContextAndroid,
) : Player, MediaPlayer.OnPreparedListener, MediaPlayer.OnCompletionListener, MediaPlayer.OnSeekCompleteListener,
    MediaPlayer.OnErrorListener {
    private var player: MediaPlayer? = null
    private var url: String? = null
    private var dataSource: MediaDataSource? = null
    private var volume = 1.0
    private var rate = 1.0f
    private var releaseMode: ReleaseMode = ReleaseMode.RELEASE
    private var released = true
    private var prepared = false
    private var playing = false
    private var shouldSeekTo = -1

    private val focusManager = FocusManager(this)

    /**
     * Setter methods
     */
    override fun setUrl(url: String, isLocal: Boolean) {
        if (this.url != url) {
            this.url = url
            val player = getOrCreatePlayer()
            player.setDataSource(url)
            preparePlayer(player)
        }

        if (Build.VERSION.SDK_INT >= 23) {
            // Dispose of any old data buffer array, if we are now playing from another source.
            dataSource = null
        }
    }

    override fun setDataSource(mediaDataSource: MediaDataSource?) {
        if (Build.VERSION.SDK_INT >= 23) {
            if (dataSource != mediaDataSource) {
                dataSource = mediaDataSource
                val player = getOrCreatePlayer()
                player.setDataSource(mediaDataSource)
                preparePlayer(player)
            }
        } else {
            throw RuntimeException("setDataSource is only available on API >= 23")
        }
    }

    private fun preparePlayer(player: MediaPlayer) {
        player.setVolume(volume.toFloat(), volume.toFloat())
        player.isLooping = releaseMode == ReleaseMode.LOOP
        player.prepareAsync()
    }

    private fun getOrCreatePlayer(): MediaPlayer {
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

    override fun setVolume(volume: Double) {
        if (this.volume != volume) {
            this.volume = volume
            if (!released) {
                player?.setVolume(volume.toFloat(), volume.toFloat())
            }
        }
    }

    override fun updateAudioContext(audioContext: AudioContextAndroid) {
        if (context == audioContext) {
            return
        }
        if (context.audioFocus != null && audioContext.audioFocus == null) {
            focusManager.handleStop()
        }
        this.context = audioContext.copy()
        player?.updateAttributesFromContext()
    }

    override fun setRate(rate: Double) {
        this.rate = rate.toFloat()

        val player = this.player ?: return
        if (Build.VERSION.SDK_INT >= 23) {
            player.playbackParams = player.playbackParams.setSpeed(this.rate)
        }
    }

    override fun setReleaseMode(releaseMode: ReleaseMode) {
        if (this.releaseMode != releaseMode) {
            this.releaseMode = releaseMode
            if (!released) {
                player?.isLooping = releaseMode == ReleaseMode.LOOP
            }
        }
    }

    /**
     * Getter methods
     */
    override fun getDuration(): Int? {
        return player?.duration
    }

    override fun getCurrentPosition(): Int? {
        return player?.currentPosition
    }

    override fun isActuallyPlaying(): Boolean {
        return playing && prepared
    }

    val audioManager: AudioManager
        get() = ref.getApplicationContext().getSystemService(Context.AUDIO_SERVICE) as AudioManager

    /**
     * Playback handling methods
     */
    override fun play() {
        focusManager.maybeRequestAudioFocus(andThen = ::actuallyPlay)
    }

    private fun actuallyPlay() {
        if (!playing) {
            val currentPlayer = player
            playing = true
            if (released || currentPlayer == null) {
                released = false
                player = createPlayer().also {
                    if (Build.VERSION.SDK_INT >= 23 && dataSource != null) {
                        it.setDataSource(dataSource)
                    } else {
                        it.setDataSource(url)
                    }
                    it.prepareAsync()
                }
            } else if (prepared) {
                currentPlayer.start()
                ref.handleIsPlaying()
            }
        }
    }

    override fun stop() {
        focusManager.handleStop()
        if (released) {
            return
        }
        if (releaseMode != ReleaseMode.RELEASE) {
            if (playing) {
                playing = false
                player?.pause()
                player?.seekTo(0)
            }
        } else {
            release()
        }
    }

    override fun release() {
        focusManager.handleStop()
        if (released) {
            return
        }
        if (playing) {
            player?.stop()
        }
        player?.reset()
        player?.release()
        player = null
        prepared = false
        released = true
        playing = false
    }

    override fun pause() {
        if (playing) {
            playing = false
            player?.pause()
        }
    }

    // seek operations cannot be called until after
    // the player is ready.
    override fun seek(position: Int) {
        if (prepared) {
            player?.seekTo(position)
        } else {
            shouldSeekTo = position
        }
    }

    /**
     * MediaPlayer callbacks
     */
    override fun onPrepared(mediaPlayer: MediaPlayer) {
        prepared = true
        ref.handleDuration(this)
        if (playing) {
            player?.start()
            ref.handleIsPlaying()
        }
        if (shouldSeekTo >= 0) {
            player?.seekTo(shouldSeekTo)
            shouldSeekTo = -1
        }
    }

    override fun onCompletion(mediaPlayer: MediaPlayer) {
        if (releaseMode != ReleaseMode.LOOP) {
            stop()
        }
        ref.handleComplete(this)
    }

    override fun onError(mp: MediaPlayer, what: Int, extra: Int): Boolean {
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
        ref.handleError(this, "MediaPlayer error with what:$whatMsg extra:$extraMsg")
        return false
    }

    override fun onSeekComplete(mediaPlayer: MediaPlayer) {
        ref.handleSeekComplete(this)
    }

    /**
     * Internal logic. Private methods
     */
    private fun createPlayer(): MediaPlayer {
        val player = MediaPlayer()
        player.setOnPreparedListener(this)
        player.setOnCompletionListener(this)
        player.setOnSeekCompleteListener(this)
        player.setOnErrorListener(this)

        player.updateAttributesFromContext()
        player.setVolume(volume.toFloat(), volume.toFloat())
        player.isLooping = releaseMode == ReleaseMode.LOOP
        return player
    }

    private fun MediaPlayer.updateAttributesFromContext() {
        // TODO(luan) is this global?
        audioManager.isSpeakerphoneOn = context.isSpeakerphoneOn
        context.setAttributesOnPlayer(this)
        player?.setWakeMode(ref.getApplicationContext(), PowerManager.PARTIAL_WAKE_LOCK)
    }
}
