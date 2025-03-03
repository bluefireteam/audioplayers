package xyz.luan.audioplayers.source

import android.media.MediaPlayer
import android.os.Build
import androidx.annotation.RequiresApi
import xyz.luan.audioplayers.BytesSource
import xyz.luan.audioplayers.player.SoundPoolPlayer

@RequiresApi(Build.VERSION_CODES.M)
data class BytesSource(
    val dataSource: BytesSource,
) : Source {
    constructor(bytes: ByteArray) : this(BytesSource(bytes))

    override fun setForMediaPlayer(mediaPlayer: MediaPlayer) {
        mediaPlayer.setDataSource(dataSource)
    }

    override fun setForSoundPool(soundPoolPlayer: SoundPoolPlayer) {
        error("Bytes sources are not supported on LOW_LATENCY mode yet.")
    }
}
