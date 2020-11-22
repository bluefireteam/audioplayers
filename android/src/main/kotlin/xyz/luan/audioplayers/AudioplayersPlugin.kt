package xyz.luan.audioplayers

import android.content.Context
import android.os.Handler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.lang.ref.WeakReference
import java.util.logging.Level
import java.util.logging.Logger

class AudioplayersPlugin : MethodCallHandler, FlutterPlugin {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    private val mediaPlayers = mutableMapOf<String, Player>()
    private val handler = Handler()
    private var positionUpdates: Runnable? = null

    private var seekFinish = false

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "xyz.luan/audioplayers")
        context = binding.applicationContext
        seekFinish = false
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {}
    override fun onMethodCall(call: MethodCall, response: MethodChannel.Result) {
        try {
            handleMethodCall(call, response)
        } catch (e: Exception) {
            LOGGER.log(Level.SEVERE, "Unexpected error!", e)
            response.error("Unexpected error!", e.message, e)
        }
    }

    private fun handleMethodCall(call: MethodCall, response: MethodChannel.Result) {
        val playerId = call.argument<String>("playerId") ?: return
        val mode = call.argument<String>("mode")
        val player = getPlayer(playerId, mode)
        when (call.method) {
            "play" -> {
                val url = call.argument<String>("url")
                val isLocal = call.argument<Boolean>("isLocal")!!

                val volume = call.argument<Double>("volume")!!
                val position = call.argument<Int>("position")

                val respectSilence = call.argument<Boolean>("respectSilence") ?: false
                val stayAwake = call.argument<Boolean>("stayAwake") ?: false
                val duckAudio = call.argument<Boolean>("duckAudio") ?: false

                player.configAttributes(respectSilence, stayAwake, duckAudio, context.applicationContext)
                player.setVolume(volume)
                player.setUrl(url, isLocal, context.applicationContext)
                if (position != null && mode != "PlayerMode.LOW_LATENCY") {
                    player.seek(position)
                }
                player.play(context.applicationContext)
            }
            "playBytes" -> {
                val bytes = call.argument<ByteArray>("bytes")!!
                val volume = call.argument<Double>("volume")!!
                val position = call.argument<Int>("position")
                val respectSilence = call.argument<Boolean>("respectSilence")!!
                val stayAwake = call.argument<Boolean>("stayAwake")!!
                val duckAudio = call.argument<Boolean>("duckAudio")!!
                player.configAttributes(respectSilence, stayAwake, duckAudio, context.applicationContext)
                player.setVolume(volume)
                player.setDataSource(ByteDataSource(bytes), context.applicationContext)
                if (position != null && mode != "PlayerMode.LOW_LATENCY") {
                    player.seek(position)
                }
                player.play(context.applicationContext)
            }
            "resume" -> player.play(context.applicationContext)
            "pause" -> player.pause()
            "stop" -> player.stop()
            "release" -> player.release()
            "seek" -> {
                val position = call.argument<Int>("position")
                player.seek(position!!)
            }
            "setVolume" -> {
                val volume = call.argument<Double>("volume")!!
                player.setVolume(volume)
            }
            "setUrl" -> {
                val url = call.argument<String>("url")
                val isLocal = call.argument<Boolean>("isLocal")!!
                player.setUrl(url, isLocal, context.applicationContext)
            }
            "setPlaybackRate" -> {
                val rate = call.argument<Double>("playbackRate")!!
                response.success(player.setRate(rate))
                return
            }
            "getDuration" -> {
                response.success(player.duration)
                return
            }
            "getCurrentPosition" -> {
                response.success(player.currentPosition)
                return
            }
            "setReleaseMode" -> {
                val releaseModeName = call.argument<String>("releaseMode")
                val releaseMode = ReleaseMode.valueOf(releaseModeName!!.substring("ReleaseMode.".length))
                player.setReleaseMode(releaseMode)
            }
            "earpieceOrSpeakersToggle" -> {
                val playingRoute = call.argument<String>("playingRoute")!!
                player.setPlayingRoute(playingRoute, context.applicationContext)
            }
            else -> {
                response.notImplemented()
                return
            }
        }
        response.success(1)
    }

    private fun getPlayer(playerId: String, mode: String?): Player {
        return mediaPlayers.getOrPut(playerId) {
            if (mode.equals("PlayerMode.MEDIA_PLAYER", ignoreCase = true)) {
                WrappedMediaPlayer(this, playerId)
            } else {
                WrappedSoundPool(playerId)
            }
        }
    }

    fun handleIsPlaying() {
        startPositionUpdates()
    }

    fun handleDuration(player: Player) {
        channel.invokeMethod("audio.onDuration", buildArguments(player.playerId, player.duration))
    }

    fun handleCompletion(player: Player) {
        channel.invokeMethod("audio.onComplete", buildArguments(player.playerId, true))
    }

    fun handleError(player: Player, message: String) {
        channel.invokeMethod("audio.onError", buildArguments(player.playerId, message))
    }

    fun handleSeekComplete() {
        seekFinish = true
    }

    private fun startPositionUpdates() {
        if (positionUpdates != null) {
            return
        }
        positionUpdates = UpdateCallback(mediaPlayers, channel, handler, this)
        handler.post(positionUpdates)
    }

    private fun stopPositionUpdates() {
        positionUpdates = null
        handler.removeCallbacksAndMessages(null)
    }

    private class UpdateCallback(
            mediaPlayers: Map<String, Player>,
            channel: MethodChannel,
            handler: Handler,
            audioplayersPlugin: AudioplayersPlugin,
    ) : Runnable {
        private val mediaPlayers = WeakReference(mediaPlayers)
        private val channel = WeakReference(channel)
        private val handler = WeakReference(handler)
        private val audioplayersPlugin = WeakReference(audioplayersPlugin)

        override fun run() {
            val mediaPlayers = mediaPlayers.get()
            val channel = channel.get()
            val handler = handler.get()
            val audioplayersPlugin = audioplayersPlugin.get()
            if (mediaPlayers == null || channel == null || handler == null || audioplayersPlugin == null) {
                audioplayersPlugin?.stopPositionUpdates()
                return
            }
            var nonePlaying = true
            for (player in mediaPlayers.values) {
                if (!player.isActuallyPlaying) {
                    continue
                }
                try {
                    nonePlaying = false
                    val key = player.playerId
                    val duration = player.duration
                    val time = player.currentPosition
                    channel.invokeMethod("audio.onDuration", buildArguments(key, duration))
                    channel.invokeMethod("audio.onCurrentPosition", buildArguments(key, time))
                    if (audioplayersPlugin.seekFinish) {
                        channel.invokeMethod("audio.onSeekComplete", buildArguments(player.playerId, true))
                        audioplayersPlugin.seekFinish = false
                    }
                } catch (e: UnsupportedOperationException) {
                }
            }
            if (nonePlaying) {
                audioplayersPlugin.stopPositionUpdates()
            } else {
                handler.postDelayed(this, 200)
            }
        }

    }

    companion object {
        private val LOGGER = Logger.getLogger(AudioplayersPlugin::class.java.canonicalName)

        private fun buildArguments(playerId: String, value: Any): Map<String, Any> {
            return mapOf(
                    "playerId" to playerId,
                    "value" to value,
            )
        }
    }
}