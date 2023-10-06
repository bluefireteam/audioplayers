package xyz.luan.audioplayers.source

import android.media.MediaPlayer
import android.os.Build
import androidx.annotation.RequiresApi
import com.google.android.exoplayer2.ExoPlayer
import xyz.luan.audioplayers.ByteDataSource
import xyz.luan.audioplayers.player.SoundPoolPlayer

@RequiresApi(Build.VERSION_CODES.M)
data class BytesSource(
    val dataSource: ByteDataSource,
) : Source {
    constructor(bytes: ByteArray) : this(ByteDataSource(bytes))

    override fun setForMediaPlayer(mediaPlayer: MediaPlayer) {
        mediaPlayer.setDataSource(dataSource)
    }

    override fun setForSoundPool(soundPoolPlayer: SoundPoolPlayer) {
        error("Bytes sources are not supported on LOW_LATENCY mode yet.")
    }

    override fun setForExoPlayer(exoPlayer: ExoPlayer) {
        error("Bytes sources are not supported on ExoPlayer mode yet.")
    }
}
