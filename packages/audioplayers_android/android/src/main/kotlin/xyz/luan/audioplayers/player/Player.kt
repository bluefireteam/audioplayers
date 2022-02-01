package xyz.luan.audioplayers.player

import android.media.MediaDataSource
import xyz.luan.audioplayers.AudioContextAndroid
import xyz.luan.audioplayers.ReleaseMode

interface Player {
    val playerId: String

    fun getDuration(): Int?
    fun getCurrentPosition(): Int?
    fun isActuallyPlaying(): Boolean

    fun play()
    fun stop()
    fun release()
    fun pause()

    fun updateAudioContext(audioContext: AudioContextAndroid)
    fun setUrl(url: String, isLocal: Boolean)
    fun setDataSource(mediaDataSource: MediaDataSource?)
    fun setVolume(volume: Double)
    fun setRate(rate: Double)
    fun setReleaseMode(releaseMode: ReleaseMode)

    fun seek(position: Int)
}