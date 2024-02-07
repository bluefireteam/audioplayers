package xyz.luan.audioplayers.player

import android.media.MediaPlayer
import android.os.Build
import android.os.PowerManager
import xyz.luan.audioplayers.AudioContextAndroid
import xyz.luan.audioplayers.source.Source

class MediaPlayerPlayer(
    private val wrappedPlayer: WrappedPlayer,
) : Player {
    private val mediaPlayer = createMediaPlayer(wrappedPlayer)

    private fun createMediaPlayer(wrappedPlayer: WrappedPlayer): MediaPlayer {
        val mediaPlayer = MediaPlayer().apply {
            setOnPreparedListener { wrappedPlayer.onPrepared() }
            setOnCompletionListener { wrappedPlayer.onCompletion() }
            setOnSeekCompleteListener { wrappedPlayer.onSeekComplete() }
            setOnErrorListener { _, what, extra -> wrappedPlayer.onError(what, extra) }
            setOnBufferingUpdateListener { _, percent -> wrappedPlayer.onBuffering(percent) }
        }
        wrappedPlayer.context.setAttributesOnPlayer(mediaPlayer)
        return mediaPlayer
    }

    override fun getDuration(): Int? {
        // media player returns -1 if the duration is unknown
        if (isReleased) return -1
        return try {
            mediaPlayer.duration.takeUnless { it == -1 }
        } catch (e: Exception) {
            wrappedPlayer.handleError("AndroidAudioError", e.message, "This could be caused by calling start after release.")
            e.printStackTrace()
            -1
        }
    }

    override fun getCurrentPosition(): Int {
        return mediaPlayer.currentPosition
    }

    override fun setVolume(leftVolume: Float, rightVolume: Float) {
        mediaPlayer.setVolume(leftVolume, rightVolume)
    }

    override fun setRate(rate: Float) {
        if (isReleased) return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                mediaPlayer.playbackParams = mediaPlayer.playbackParams.setSpeed(rate)
            } catch (e: Exception) {
                wrappedPlayer.handleError("AndroidAudioError", e.message, "This could be caused by calling start after release.")
                e.printStackTrace()
            }
        } else if (rate == 1.0f) {
            try {
                mediaPlayer.start()
            } catch (e: Exception) {
                wrappedPlayer.handleError("AndroidAudioError", e.message, "This could be caused by calling start after release.")
                e.printStackTrace()
            }
        } else {
            error("Changing the playback rate is only available for Android M/23+ or using LOW_LATENCY mode.")
        }
    }

    override fun setSource(source: Source) {
        if (isReleased) return
        reset()
        source.setForMediaPlayer(mediaPlayer)
    }

    override fun setLooping(looping: Boolean) {
        mediaPlayer.isLooping = looping
    }

    override fun start() {
        // Setting playback rate instead of mediaPlayer.start().
        setRate(wrappedPlayer.rate)
    }

    override fun pause() {
        if (isReleased) return
        mediaPlayer.pause()
    }

    override fun stop() {
        if (isReleased) return
        mediaPlayer.stop()
    }

    private var isReleased = false

    override fun release() {
        if (isReleased) return
        isReleased = true
        try {
            mediaPlayer.reset()
            mediaPlayer.release()
        } catch (e: Exception) {
            wrappedPlayer.handleError("AndroidAudioError", e.message, "This could be caused by calling release twice.")
            e.printStackTrace()
        }
    }

    override fun seekTo(position: Int) {
        if (isReleased) return
        mediaPlayer.seekTo(position)
    }

    override fun updateContext(context: AudioContextAndroid) {
        context.setAttributesOnPlayer(mediaPlayer)
        if (context.stayAwake) {
            mediaPlayer.setWakeMode(wrappedPlayer.applicationContext, PowerManager.PARTIAL_WAKE_LOCK)
        }
    }

    override fun prepare() {
        mediaPlayer.prepareAsync()
    }

    override fun reset() {
        if (isReleased) return
        try {
            mediaPlayer.reset()
        } catch (e: Exception) {
            wrappedPlayer.handleError("AndroidAudioError", e.message, "This could be caused by calling reset after release.")
            e.printStackTrace()
        }
    }

    override fun isLiveStream(): Boolean {
        val duration = getDuration()
        return duration == null || duration == 0
    }
}
