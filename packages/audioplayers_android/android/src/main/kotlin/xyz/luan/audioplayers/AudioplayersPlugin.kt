package xyz.luan.audioplayers

import android.content.Context
import android.os.Build
import android.os.Handler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import xyz.luan.audioplayers.player.Player
import xyz.luan.audioplayers.player.WrappedMediaPlayer
import xyz.luan.audioplayers.player.WrappedSoundPool
import java.lang.ref.WeakReference
import java.util.*

typealias FlutterHandler = (call: MethodCall, response: MethodChannel.Result) -> Unit

class AudioplayersPlugin : FlutterPlugin {
    private lateinit var channel: MethodChannel
    private lateinit var globalChannel: MethodChannel
    private lateinit var context: Context

    private val mediaPlayers = mutableMapOf<String, Player>()
    private val handler = Handler()
    private var positionUpdates: Runnable? = null

    private var defaultAudioContext: AudioContextAndroid? = null

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "xyz.luan/audioplayers")
        channel.setMethodCallHandler { call, response -> safeCall(call, response, ::handler) }
        globalChannel = MethodChannel(binding.binaryMessenger, "xyz.luan/audioplayers.global")
        globalChannel.setMethodCallHandler { call, response -> safeCall(call, response, ::globalHandler) }
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        stopPositionUpdates()
        mediaPlayers.values.forEach { it.release() }
        mediaPlayers.clear()
    }

    private fun safeCall(
        call: MethodCall,
        response: MethodChannel.Result,
        handler: FlutterHandler,
    ) {
        try {
            handler(call, response)
        } catch (e: Exception) {
            Logger.error("Unexpected error!", e)
            response.error("Unexpected error!", e.message, e)
        }
    }

    private fun globalHandler(call: MethodCall, response: MethodChannel.Result) {
        when (call.method) {
            "changeLogLevel" -> {
                val value = call.enumArgument<LogLevel>("value")
                    ?: throw error("value is required")
                Logger.logLevel = value
            }
            "setGlobalAudioContext" -> {
                defaultAudioContext = AudioContextAndroid(
                    isSpeakerphoneOn = call.argument<Boolean>("isSpeakerphoneOn")
                        ?: throw error("isSpeakerphoneOn is required"),
                    stayAwake = call.argument<Boolean>("stayAwake")
                        ?: throw error("stayAwake is required"),
                    contentType = call.argument<Int>("contentType")
                        ?: throw error("contentType is required"),
                    usageType = call.argument<Int>("usageType")
                        ?: throw error("usageType is required"),
                    audioFocus = call.argument<Int>("audioFocus"),
                )
            }
        }

        response.success(1)
    }

    private fun handler(call: MethodCall, response: MethodChannel.Result) {
        val playerId = call.argument<String>("playerId") ?: return
        val mode = call.enumArgument<PlayerMode>("mode")
        val player = getPlayer(playerId, mode)
        when (call.method) {
            "setSourceUrl" -> {
                val url = call.argument<String>("url") ?: throw error("url is required")
                val isLocal = call.argument<Boolean>("isLocal") ?: false
                player.setUrl(url, isLocal)
            }
            "setSourceBytes" -> {
                val bytes = call.argument<ByteArray>("bytes") ?: throw error("bytes are required")
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    player.setDataSource(ByteDataSource(bytes))
                } else {
                    throw error("Operation not supported on Android <= M")
                }
            }
            "resume" -> player.play()
            "pause" -> player.pause()
            "stop" -> player.stop()
            "release" -> player.release()
            "seek" -> {
                val position = call.argument<Int>("position") ?: throw error("position is required")
                player.seek(position)
            }
            "setVolume" -> {
                val volume = call.argument<Double>("volume") ?: throw error("volume is required")
                player.setVolume(volume)
            }
            "setPlaybackRate" -> {
                val rate = call.argument<Double>("playbackRate") ?: throw error("playbackRate is required")
                player.setRate(rate)
            }
            "getDuration" -> {
                response.success(player.getDuration() ?: 0)
                return
            }
            "getCurrentPosition" -> {
                response.success(player.getCurrentPosition() ?: 0)
                return
            }
            "setReleaseMode" -> {
                val releaseMode = call.enumArgument<ReleaseMode>("releaseMode")
                    ?: throw error("releaseMode is required")
                player.setReleaseMode(releaseMode)
            }
            else -> {
                response.notImplemented()
                return
            }
        }
        response.success(1)
    }

    private fun getPlayer(playerId: String, mode: PlayerMode?): Player {
        return mediaPlayers.getOrPut(playerId) {
            val audioContext = defaultAudioContext ?: AudioContextAndroid()
            when (mode) {
                null, PlayerMode.MEDIA_PLAYER -> WrappedMediaPlayer(this, playerId, audioContext)
                PlayerMode.LOW_LATENCY -> WrappedSoundPool(playerId)
            }
        }
    }

    fun getApplicationContext(): Context {
        return context.applicationContext
    }

    fun handleIsPlaying() {
        startPositionUpdates()
    }

    fun handleDuration(player: Player) {
        channel.invokeMethod("audio.onDuration", buildArguments(player.playerId, player.getDuration() ?: 0))
    }

    fun handleComplete(player: Player) {
        channel.invokeMethod("audio.onComplete", buildArguments(player.playerId))
    }

    fun handleError(player: Player, message: String) {
        channel.invokeMethod("audio.onError", buildArguments(player.playerId, message))
    }

    fun handleSeekComplete(player: Player) {
        channel.invokeMethod("audio.onSeekComplete", buildArguments(player.playerId))
    }

    private fun startPositionUpdates() {
        if (positionUpdates != null) {
            return
        }
        positionUpdates = UpdateCallback(mediaPlayers, channel, handler, this).also {
            handler.post(it)
        }
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
                if (!player.isActuallyPlaying()) {
                    continue
                }
                nonePlaying = false
                val key = player.playerId
                val duration = player.getDuration()
                val time = player.getCurrentPosition()
                channel.invokeMethod("audio.onDuration", buildArguments(key, duration ?: 0))
                channel.invokeMethod("audio.onCurrentPosition", buildArguments(key, time ?: 0))
            }
            if (nonePlaying) {
                audioplayersPlugin.stopPositionUpdates()
            } else {
                handler.postDelayed(this, 200)
            }
        }

    }

    companion object {
        private fun buildArguments(playerId: String, value: Any? = null): Map<String, Any> {
            return listOfNotNull(
                "playerId" to playerId,
                value?.let { "value" to it },
            ).toMap()
        }

        private fun error(message: String): Exception {
            return IllegalArgumentException(message)
        }
    }
}

private inline fun <reified T : Enum<T>> MethodCall.enumArgument(name: String): T? {
    val enumName = argument<String>(name) ?: return null
    return enumValueOf<T>(enumName.split('.').last().toUpperCase(Locale.ROOT))
}
