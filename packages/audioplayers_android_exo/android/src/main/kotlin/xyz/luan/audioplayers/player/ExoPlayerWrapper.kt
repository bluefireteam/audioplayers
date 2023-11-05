package xyz.luan.audioplayers.player

import android.content.Context
import androidx.media3.common.AudioAttributes
import androidx.media3.common.C.TIME_UNSET
import androidx.media3.common.MediaItem
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.datasource.ByteArrayDataSource
import androidx.media3.datasource.DataSource
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.source.MediaSource
import androidx.media3.exoplayer.source.ProgressiveMediaSource
import xyz.luan.audioplayers.AudioContextAndroid
import xyz.luan.audioplayers.source.BytesSource
import xyz.luan.audioplayers.source.Source
import xyz.luan.audioplayers.source.UrlSource

class ExoPlayerWrapper(
    private val wrappedPlayer: WrappedPlayer,
    private val appContext: Context,
) : PlayerWrapper {

    class ExoPlayerListener(private val wrappedPlayer: WrappedPlayer) : androidx.media3.common.Player.Listener {
        override fun onPlayerError(error: PlaybackException) {
            if (error.errorCode == PlaybackException.ERROR_CODE_PARSING_CONTAINER_UNSUPPORTED) {
                wrappedPlayer.handleError(
                    errorCode = "AndroidAudioError",
                    errorMessage = "Failed to set source. For troubleshooting, see: " +
                        "https://github.com/bluefireteam/audioplayers/blob/main/troubleshooting.md",
                    errorDetails = "${error.errorCodeName}\n${error.message}\n${error.stackTraceToString()}",
                )
                return
            }
            wrappedPlayer.handleError(
                errorCode = error.errorCodeName,
                errorMessage = error.message,
                errorDetails = error.stackTraceToString(),
            )
        }

        override fun onPlaybackStateChanged(playbackState: Int) {
            when (playbackState) {
                Player.STATE_IDLE -> {
                    // TODO()
                }

                Player.STATE_BUFFERING -> wrappedPlayer.onBuffering(0)
                Player.STATE_READY -> wrappedPlayer.onPrepared()
                Player.STATE_ENDED -> wrappedPlayer.onCompletion()
            }
        }
    }

    private var player: ExoPlayer = ExoPlayer.Builder(appContext).build().apply {
//        val playerView = PlayerControlView(appContext)
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
        return player.currentPosition.toInt()
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
        player.stop()
        player.clearMediaItems()
    }

    override fun dispose() {
        release()
        player.release()
    }

    override fun setVolume(leftVolume: Float, rightVolume: Float) {
        println("Exo Volume")
        // TODO: set volume individually
        player.volume = (leftVolume + rightVolume) / 2
    }

    override fun setRate(rate: Float) {
        println("Exo Rate")
        player.setPlaybackSpeed(rate)
    }

    override fun setLooping(looping: Boolean) {
        println("Exo Looping")
        player.repeatMode = if (looping) {
            Player.REPEAT_MODE_ONE
        } else {
            Player.REPEAT_MODE_OFF
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

    @androidx.annotation.OptIn(androidx.media3.common.util.UnstableApi::class)
    override fun setSource(source: Source) {
        println("Exo Set source")
        if (source is UrlSource) {
            player.setMediaItem(MediaItem.fromUri(source.url))
        } else if (source is BytesSource) {
            val byteArrayDataSource = ByteArrayDataSource(source.data);
            val factory = DataSource.Factory { byteArrayDataSource; }
            val mediaSource: MediaSource = ProgressiveMediaSource.Factory(factory)
                .createMediaSource(MediaItem.EMPTY)
            player.setMediaSource(mediaSource)
        }
    }

    override fun prepare() {
        println("Exo Prepare")
        player.prepare()
    }

}
