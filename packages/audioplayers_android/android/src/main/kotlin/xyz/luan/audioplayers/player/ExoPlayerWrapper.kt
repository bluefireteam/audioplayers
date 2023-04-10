package xyz.luan.audioplayers.player

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.google.android.exoplayer2.C.TIME_UNSET
import com.google.android.exoplayer2.ExoPlayer
import com.google.android.exoplayer2.PlaybackException
import com.google.android.exoplayer2.Player.*
import com.google.android.exoplayer2.audio.AudioAttributes
import xyz.luan.audioplayers.AudioContextAndroid
import xyz.luan.audioplayers.source.Source

class ExoPlayerWrapper(
    private val wrappedPlayer: WrappedPlayer,
    private val appContext: Context,
) : Player {

    class ExoPlayerListener(private val wrappedPlayer: WrappedPlayer) : com.google.android.exoplayer2.Player.Listener {

        private val handler = Handler(Looper.getMainLooper())
        override fun onPlayerError(error: PlaybackException) {
            handler.post {
                println("ExoError")
                wrappedPlayer.handleError(
                    errorCode = error.errorCodeName,
                    errorMessage = error.message,
                    errorDetails = error.stackTraceToString(),
                )
            }
        }

        override fun onPlaybackStateChanged(playbackState: Int) {
            handler.post {
                println("ExoPlaybackChanged $playbackState")
                when (playbackState) {
                    STATE_ENDED -> wrappedPlayer.onCompletion()
                }
            }
        }
    }

    var player = ExoPlayer.Builder(appContext).build().apply {
//        val playerView = StyledPlayerControlView(appContext)
//        playerView.player = this
//        experimentalSetOffloadSchedulingEnabled(true);
//        setAudioSessionId();
        addListener(ExoPlayerListener(wrappedPlayer))
    }

    override fun getDuration(): Int? {
        println("Exo getDuration")
        return (player.duration.takeUnless { it == TIME_UNSET })?.toInt()
    }

    override fun getCurrentPosition(): Int {
        println("Exo getPosition")
        return player.currentPosition.toInt()
    }

    override fun isActuallyPlaying(): Boolean {
        println("Exo isPlaying")
        return player.isPlaying
    }

    override fun isLiveStream(): Boolean {
        println("Is LiveStream: ${player.isCurrentMediaItemLive}")
        return false

        // TODO(Gustl22): check if the right flag
//        return player.isCurrentMediaItemLive
    }

    override fun start() {
        println("Exo Start")
        player.play()
    }

    override fun pause() {
        println("Exo Pause")
        player.pause()
    }

    override fun stop() {
        println("Exo Stop")
        player.stop()
    }

    override fun seekTo(position: Int) {
        println("Exo Seek to")
        player.seekTo(position.toLong())
        wrappedPlayer.onSeekComplete()
    }

    override fun release() {
        println("Exo Release")
        player.release()
    }

    override fun setVolume(leftVolume: Float, rightVolume: Float) {
        println("Exo Volume")
        player.volume = (leftVolume + rightVolume) / 2
    }

    override fun setRate(rate: Float) {
        println("Exo Rate")
        player.setPlaybackSpeed(rate)
    }

    override fun setLooping(looping: Boolean) {
        println("Exo Looping")
        player.repeatMode = if (looping) {
            REPEAT_MODE_ONE
        } else {
            REPEAT_MODE_OFF
        }
    }

    override fun updateContext(context: AudioContextAndroid) {
        println("Exo Update context")
        val builder =
            AudioAttributes.Builder()
        builder.setContentType(context.contentType)
        builder.setUsage(context.usageType)

        player.setAudioAttributes(
            builder.build(),
            false,
        )

    }

    override fun setSource(source: Source) {
        println("Exo Set source")
        source.setForExoPlayer(player)
    }

    override fun prepare() {
        println("Exo Prepare")
        
        player.prepare()
        wrappedPlayer.onPrepared()
    }

    override fun reset() {
        println("Exo Reset")
        player.stop()
        player.clearMediaItems()
    }

}
