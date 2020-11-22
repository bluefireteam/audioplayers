package xyz.luan.audioplayers

import android.content.Context
import android.media.MediaDataSource

abstract class Player {
    abstract val playerId: String
    abstract val duration: Int
    abstract val currentPosition: Int
    abstract val isActuallyPlaying: Boolean

    abstract fun play(context: Context)
    abstract fun stop()
    abstract fun release()
    abstract fun pause()

    abstract fun configAttributes(respectSilence: Boolean, stayAwake: Boolean, duckAudio: Boolean, context: Context)
    abstract fun setUrl(url: String?, isLocal: Boolean, context: Context)
    abstract fun setDataSource(mediaDataSource: MediaDataSource?, context: Context)
    abstract fun setVolume(volume: Double)
    abstract fun setRate(rate: Double): Int
    abstract fun setReleaseMode(releaseMode: ReleaseMode)
    abstract fun setPlayingRoute(playingRoute: String, context: Context)

    /**
     * Seek operations cannot be called until after the player is ready.
     */
    abstract fun seek(position: Int)

    companion object {
        @JvmStatic
        protected fun objectEquals(o1: Any?, o2: Any?): Boolean {
            return o1 == null && o2 == null || o1 != null && o1 == o2
        }
    }
}