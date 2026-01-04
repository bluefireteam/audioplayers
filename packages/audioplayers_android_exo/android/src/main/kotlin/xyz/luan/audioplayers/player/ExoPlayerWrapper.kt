package xyz.luan.audioplayers.player

import android.content.Context
import android.net.Uri
import android.os.Build
import android.util.SparseArray
import androidx.annotation.RequiresApi
import androidx.media3.common.AudioAttributes
import androidx.media3.common.C
import androidx.media3.common.C.TIME_UNSET
import androidx.media3.common.MediaItem
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.common.audio.AudioProcessor
import androidx.media3.common.audio.AudioProcessor.UnhandledAudioFormatException
import androidx.media3.common.audio.BaseAudioProcessor
import androidx.media3.common.audio.ChannelMixingMatrix
import androidx.media3.datasource.ByteArrayDataSource
import androidx.media3.datasource.DataSource
import androidx.media3.exoplayer.DefaultRenderersFactory
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.audio.AudioSink
import androidx.media3.exoplayer.audio.DefaultAudioSink
import androidx.media3.exoplayer.source.MediaSource
import androidx.media3.exoplayer.source.ProgressiveMediaSource
import xyz.luan.audioplayers.AudioContextAndroid
import xyz.luan.audioplayers.source.BytesSource
import xyz.luan.audioplayers.source.Source
import xyz.luan.audioplayers.source.UrlSource
import java.nio.ByteBuffer

class ExoPlayerWrapper(
    private val wrappedPlayer: WrappedPlayer,
    appContext: Context,
) : PlayerWrapper {

    class ExoPlayerListener(private val wrappedPlayer: WrappedPlayer) : androidx.media3.common.Player.Listener {
        override fun onPlayerError(error: PlaybackException) {
            if (error.errorCode == PlaybackException.ERROR_CODE_PARSING_CONTAINER_UNSUPPORTED ||
                error.errorCode == PlaybackException.ERROR_CODE_IO_FILE_NOT_FOUND
            ) {
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
                Player.STATE_IDLE -> {} // TODO(gustl22): may can use or leave as no-op
                Player.STATE_BUFFERING -> wrappedPlayer.onBuffering(0)
                Player.STATE_READY -> wrappedPlayer.onPrepared()
                Player.STATE_ENDED -> wrappedPlayer.onCompletion()
            }
        }
    }

    private var player: ExoPlayer

    @androidx.annotation.OptIn(androidx.media3.common.util.UnstableApi::class)
    private var channelMixingAudioProcessor = AdaptiveChannelMixingAudioProcessor()
    private lateinit var audioSink: AudioSink

    init {
        player = createPlayer(appContext)
    }

    @androidx.annotation.OptIn(androidx.media3.common.util.UnstableApi::class)
    private fun createPlayer(appContext: Context): ExoPlayer {
        val renderersFactory = object : DefaultRenderersFactory(appContext) {
            override fun buildAudioSink(
                context: Context,
                enableFloatOutput: Boolean,
                enableAudioTrackPlaybackParams: Boolean,
            ): AudioSink {
                audioSink =
                    DefaultAudioSink.Builder(appContext).setAudioProcessors(arrayOf(channelMixingAudioProcessor))
                        .build()
                return audioSink
            }
        }

        return ExoPlayer.Builder(appContext).setRenderersFactory(renderersFactory).build().apply {
            addListener(ExoPlayerListener(wrappedPlayer))
        }
    }

    override fun getDuration(): Int? {
        if (player.isCurrentMediaItemLive) {
            return null
        }
        return (player.duration.takeUnless { it == TIME_UNSET })?.toInt()
    }

    override fun getCurrentPosition(): Int {
        return player.currentPosition.toInt()
    }

    override fun start() {
        player.play()
    }

    override fun pause() {
        player.pause()
    }

    override fun stop() {
        player.pause()
        player.seekTo(0)
    }

    override fun seekTo(position: Int) {
        player.seekTo(position.toLong())
        wrappedPlayer.onSeekComplete()
    }

    override fun release() {
        player.stop()
        player.clearMediaItems()
    }

    override fun dispose() {
        release()
        player.release()
    }

    @androidx.annotation.OptIn(androidx.media3.common.util.UnstableApi::class)
    override fun setVolume(leftVolume: Float, rightVolume: Float) {
        this.channelMixingAudioProcessor.putChannelMixingMatrix(
            ChannelMixingMatrix(2, 2, floatArrayOf(leftVolume, 0f, 0f, rightVolume)),
        )
    }

    override fun setRate(rate: Float) {
        player.setPlaybackSpeed(rate)
    }

    override fun setLooping(looping: Boolean) {
        player.repeatMode = if (looping) {
            Player.REPEAT_MODE_ONE
        } else {
            Player.REPEAT_MODE_OFF
        }
    }

    override fun updateContext(context: AudioContextAndroid) {
        val builder = AudioAttributes.Builder()
        builder.setContentType(context.contentType)
        builder.setUsage(context.usageType)

        player.setAudioAttributes(
            builder.build(),
            false,
        )
    }

    @RequiresApi(Build.VERSION_CODES.M)
    @androidx.annotation.OptIn(androidx.media3.common.util.UnstableApi::class)
    override fun setSource(source: Source) {
        if (source is UrlSource) {
            player.setMediaItem(MediaItem.fromUri(source.url))
        } else if (source is BytesSource) {
            val byteArrayDataSource = ByteArrayDataSource(source.data)
            val factory = DataSource.Factory { byteArrayDataSource; }
            val mediaSource: MediaSource = ProgressiveMediaSource.Factory(factory).createMediaSource(
                MediaItem.fromUri(Uri.EMPTY),
            )
            player.setMediaSource(mediaSource)
        }
    }

    override fun prepare() {
        player.prepare()
    }
}

/**
 * See Implementation of [androidx.media3.common.audio.ChannelMixingAudioProcessor] for reference.
 * See: https://github.com/androidx/media/blob/8ea49025aaf14c7e7d953df8ca2f08a76d9d4275/libraries/common/src/main/java/androidx/media3/common/audio/ChannelMixingAudioProcessor.java
 */
@androidx.annotation.OptIn(androidx.media3.common.util.UnstableApi::class)
class AdaptiveChannelMixingAudioProcessor : BaseAudioProcessor() {
    private val matrixByInputChannelCount: SparseArray<ChannelMixingMatrix?> = SparseArray<ChannelMixingMatrix?>()

    fun putChannelMixingMatrix(matrix: ChannelMixingMatrix) {
        matrixByInputChannelCount.put(matrix.inputChannelCount, matrix)
    }

    @Throws(UnhandledAudioFormatException::class)
    override fun onConfigure(inputAudioFormat: AudioProcessor.AudioFormat): AudioProcessor.AudioFormat {
        if (inputAudioFormat.encoding != C.ENCODING_PCM_16BIT) {
            throw UnhandledAudioFormatException(inputAudioFormat)
        } else {
            // We keep the same format; we're not altering the channel count.
            return inputAudioFormat
        }
    }

    override fun queueInput(inputBuffer: ByteBuffer) {
        val channelMixingMatrix = matrixByInputChannelCount[inputAudioFormat.channelCount]
        if (channelMixingMatrix == null || channelMixingMatrix.isIdentity) {
            // No need to transform, if balance is equalized.
            val outputBuffer = this.replaceOutputBuffer(inputBuffer.remaining())
            if (inputBuffer.hasRemaining()) {
                outputBuffer.put(inputBuffer)
            }
            outputBuffer.flip()
            return
        }

        val outputBuffer = this.replaceOutputBuffer(inputBuffer.remaining())
        val inputChannelCount = channelMixingMatrix.inputChannelCount
        val outputChannelCount = channelMixingMatrix.outputChannelCount
        val outputFrame = FloatArray(outputChannelCount)

        while (inputBuffer.hasRemaining()) {
            var inputValue: Short
            var inputChannelIndex = 0
            while (inputChannelIndex < inputChannelCount) {
                inputValue = inputBuffer.getShort()

                for (outputChannelIndex in 0 until outputChannelCount) {
                    outputFrame[outputChannelIndex] += channelMixingMatrix.getMixingCoefficient(
                        inputChannelIndex,
                        outputChannelIndex,
                    ) * inputValue.toFloat()
                }
                ++inputChannelIndex
            }

            inputChannelIndex = 0
            while (inputChannelIndex < outputChannelCount) {
                inputValue =
                    outputFrame[inputChannelIndex].toInt().coerceIn(-32768, 32767).toShort()
                outputBuffer.put((inputValue.toInt() and 255).toByte())
                outputBuffer.put((inputValue.toInt() shr 8 and 255).toByte())
                outputFrame[inputChannelIndex] = 0.0f
                ++inputChannelIndex
            }
        }
        outputBuffer.flip()
    }
}
