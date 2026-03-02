package xyz.luan.audioplayers.player

import android.content.Context
import android.media.AudioManager
import xyz.luan.audioplayers.AudioContextAndroid
import xyz.luan.audioplayers.AudioplayersPlugin
import xyz.luan.audioplayers.EventHandler
import xyz.luan.audioplayers.ReleaseMode
import xyz.luan.audioplayers.source.Source
import kotlin.math.min

class WrappedPlayer internal constructor(
    private val ref: AudioplayersPlugin,
    val eventHandler: EventHandler,
    var context: AudioContextAndroid,
) {
    private var player: PlayerWrapper? = null

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

    private val focusManager = FocusManager.create(
        this,
        onGranted = {
            if (playing) {
                player?.start()
            }
        },
        onLoss = { isTransient ->
            if (isTransient) {
                player?.pause()
            } else {
                pause()
            }
        },
    )

    private fun getOrCreatePlayer(): PlayerWrapper {
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

        audioManager.mode = context.audioMode
        audioManager.isSpeakerphoneOn = context.isSpeakerphoneOn

        player?.let { p ->
            p.stop()
            prepared = false
            p.updateContext(context)
            source?.let {
                p.setSource(it)
                p.configAndPrepare()
            }
        }
    }

    fun getDuration(): Int? {
        return if (prepared) player?.getDuration() else null
    }

    fun getCurrentPosition(): Int? {
        return if (prepared) player?.getCurrentPosition() else null
    }

    val applicationContext: Context
        get() = ref.getApplicationContext()

    val audioManager: AudioManager
        get() = ref.getAudioManager()

    fun play() {
        if (!playing && !released) {
            playing = true
            if (player == null) {
                initPlayer()
            } else if (prepared) {
                requestFocusAndStart()
            }
        }
    }

    private fun requestFocusAndStart() {
        focusManager.maybeRequestAudioFocus()
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

    fun seek(position: Int) {
        shouldSeekTo = if (prepared && player?.isLiveStream() != true) {
            player?.seekTo(position)
            -1
        } else {
            position
        }
    }

    fun onPrepared() {
        prepared = true
        ref.handleDuration(this)
        if (playing) {
            requestFocusAndStart()
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

    fun onBuffering(percent: Int) {
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

    private fun createPlayer(): PlayerWrapper {
        return ExoPlayerWrapper(this, ref.getApplicationContext())
    }

    private fun initPlayer() {
        val player = createPlayer()
        this.player = player
        source?.let {
            player.setSource(it)
            player.configAndPrepare()
        }
    }

    private fun PlayerWrapper.configAndPrepare() {
        setVolumeAndBalance(volume, balance)
        setLooping(isLooping)
        prepare()
    }

    private fun PlayerWrapper.setVolumeAndBalance(volume: Float, balance: Float) {
        val leftVolume = min(1f, 1f - balance) * volume
        val rightVolume = min(1f, 1f + balance) * volume
        setVolume(leftVolume, rightVolume)
    }

    fun dispose() {
        release()
        player?.dispose()
        player = null
        eventHandler.dispose()
    }
}
