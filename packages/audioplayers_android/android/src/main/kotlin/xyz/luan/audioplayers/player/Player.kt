package xyz.luan.audioplayers.player

import xyz.luan.audioplayers.AudioContextAndroid
import xyz.luan.audioplayers.source.Source

interface Player {
    fun getDuration(): Int?
    fun getCurrentPosition(): Int?
    fun isLiveStream(): Boolean

    fun start()
    fun pause()
    fun stop()
    fun seekTo(position: Int)
    fun release()

    fun setVolume(leftVolume: Float, rightVolume: Float)
    fun setRate(rate: Float)
    fun setLooping(looping: Boolean)
    fun updateContext(context: AudioContextAndroid)
    fun setSource(source: Source)

    fun prepare()
    fun reset()
}
