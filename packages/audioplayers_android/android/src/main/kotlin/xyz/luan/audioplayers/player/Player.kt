package xyz.luan.audioplayers.player

import android.media.MediaDataSource
import xyz.luan.audioplayers.AudioContextAndroid
import xyz.luan.audioplayers.ReleaseMode
import xyz.luan.audioplayers.source.Source

interface Player {
    fun getDuration(): Int?
    fun getCurrentPosition(): Int?
    fun isActuallyPlaying(): Boolean

    fun start()
    fun pause()
    fun stop()
    fun seekTo(position: Int)
    fun release()

    fun setVolume(volume: Float)
    fun setRate(rate: Float)
    fun setLooping(looping: Boolean)
    fun updateContext(context: AudioContextAndroid)
    fun setSource(source: Source)

    fun prepare()
    fun reset()
}